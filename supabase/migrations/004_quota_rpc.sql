-- Server-side quota enforcement (PROJECT_SPEC.md Section 5, 6).
-- Implemented as SECURITY DEFINER Postgres functions rather than an Edge
-- Function — same "never trust the client" guarantee, and the whole
-- rate-limit/quota-check/lookup/log sequence runs atomically in one
-- transaction instead of several round trips.

alter table daily_usage add column if not exists rewarded_ad_count integer default 0;

-- Single entry point the client calls for every search. Replaces direct
-- client access to dtc_codes/search_logs (revoked below).
create or replace function search_dtc(p_device_id text, p_code text, p_brand text default null)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_recent_count integer;
  v_is_subscriber boolean;
  v_today date := current_date;
  v_usage_count integer;
  v_row dtc_codes%rowtype;
  v_found boolean;
  v_brand text := coalesce(nullif(p_brand, ''), 'غير محدد');
begin
  -- Rate limit: cap requests per device at a sane ceiling regardless of
  -- daily quota, to block scripted/bot abuse (Section 6).
  select count(*) into v_recent_count
  from search_logs
  where device_id = p_device_id and created_at > now() - interval '1 minute';

  if v_recent_count >= 10 then
    return jsonb_build_object('error', 'rate_limited');
  end if;

  -- Subscribers skip the quota entirely.
  select (subscription_status = 'active') into v_is_subscriber
  from users where device_id = p_device_id;
  v_is_subscriber := coalesce(v_is_subscriber, false);

  if not v_is_subscriber then
    select search_count into v_usage_count
    from daily_usage where device_id = p_device_id and usage_date = v_today;
    v_usage_count := coalesce(v_usage_count, 0);

    -- Quota is checked BEFORE performing the lookup: once the 3rd free
    -- search of the day is used, further attempts hit the paywall
    -- immediately, without even querying dtc_codes.
    if v_usage_count >= 3 then
      return jsonb_build_object('quota_exceeded', true);
    end if;
  end if;

  select * into v_row from dtc_codes where code = p_code;
  v_found := found;

  -- Log the attempt regardless of outcome (Section 4.2).
  insert into search_logs (code, brand, device_id, found)
  values (p_code, v_brand, p_device_id, v_found);

  -- Critical rule (Section 5): only found searches count against the free
  -- quota. Not-found searches never decrement it.
  if v_found and not v_is_subscriber then
    insert into daily_usage (device_id, usage_date, search_count)
    values (p_device_id, v_today, 1)
    on conflict (device_id, usage_date)
    do update set search_count = daily_usage.search_count + 1;
  end if;

  if v_found then
    return jsonb_build_object(
      'found', true,
      'code', v_row.code,
      'meaning', v_row.meaning,
      'severity', v_row.severity,
      'causes', to_jsonb(v_row.causes),
      'action', v_row.action,
      'symptoms', v_row.symptoms
    );
  else
    return jsonb_build_object('found', false);
  end if;
end;
$$;

-- Rewarded-ad abuse cap (Section 6): a safety margin on top of AdMob's own
-- fraud detection, since excessive rewarded-ad-watching from one device
-- risks the whole AdMob account being flagged for invalid traffic.
create or replace function register_ad_view(p_device_id text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_today date := current_date;
  v_count integer;
begin
  select rewarded_ad_count into v_count
  from daily_usage where device_id = p_device_id and usage_date = v_today;
  v_count := coalesce(v_count, 0);

  if v_count >= 15 then
    return jsonb_build_object('allowed', false);
  end if;

  insert into daily_usage (device_id, usage_date, rewarded_ad_count)
  values (p_device_id, v_today, 1)
  on conflict (device_id, usage_date)
  do update set rewarded_ad_count = daily_usage.rewarded_ad_count + 1;

  return jsonb_build_object('allowed', true);
end;
$$;

-- Lock down direct table access now that the RPCs above handle it
-- server-side with elevated privilege. Leaving the old direct policies in
-- place would let a client bypass the quota entirely by calling
-- /rest/v1/dtc_codes directly instead of going through search_dtc.
drop policy if exists "dtc_codes are publicly readable" on dtc_codes;
revoke select on public.dtc_codes from anon, authenticated;

drop policy if exists "anon can log searches" on search_logs;
revoke insert on public.search_logs from anon, authenticated;

grant execute on function search_dtc(text, text, text) to anon;
grant execute on function register_ad_view(text) to anon;
