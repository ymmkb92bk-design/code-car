-- DTC Lookup App — schema (PROJECT_SPEC.md Section 3)
-- Consolidated to reflect the current state, including server-side quota
-- enforcement (Section 5, 6) added via migrations/004_quota_rpc.sql.

create extension if not exists pgcrypto;

create table dtc_codes (
  code text primary key,              -- e.g. 'P0420'
  meaning text not null,
  severity text not null check (severity in ('بسيط','متوسط','خطير')),
  causes text[] not null,             -- split the bulleted cause field into an array, one item per bullet
  action text not null,
  symptoms text not null
);

create table users (
  user_id uuid primary key default gen_random_uuid(),
  device_id text unique,              -- used for free-tier daily limit tracking
  subscription_status text default 'free' check (subscription_status in ('free','active','expired')),
  subscription_expiry timestamptz,
  created_at timestamptz default now()
);

create table daily_usage (
  device_id text not null,
  usage_date date not null,
  search_count integer default 0,
  rewarded_ad_count integer default 0, -- Section 6 rewarded-ad abuse cap
  primary key (device_id, usage_date)
);

create table search_logs (
  id bigserial primary key,
  code text not null,
  brand text,                         -- optional, from the vehicle brand dropdown
  device_id text,
  found boolean not null,
  created_at timestamptz default now()
);

-- Row Level Security — no anon policies on ANY table. All client access goes
-- through the search_dtc / register_ad_view RPC functions below, which run
-- as SECURITY DEFINER (elevated privilege) and enforce rate limiting +
-- quota + logging atomically server-side (Section 6: "never trust the
-- client for quota enforcement"). Direct table access would let a client
-- bypass the quota entirely by calling /rest/v1/dtc_codes directly.

alter table dtc_codes enable row level security;
alter table users enable row level security;
alter table daily_usage enable row level security;
alter table search_logs enable row level security;

-- Helpful indexes for the analytics queries in Section 7
create index idx_search_logs_code on search_logs (code);
create index idx_search_logs_found on search_logs (found) where found = false;

grant usage on schema public to anon, authenticated;

-- Single entry point the client calls for every search.
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

-- Self-service data deletion (Saudi PDPL "right to deletion" — a real working
-- mechanism, not just a promise handled manually over email).
create or replace function delete_my_data(p_device_id text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_search_logs_deleted integer;
  v_daily_usage_deleted integer;
  v_users_deleted integer;
begin
  delete from search_logs where device_id = p_device_id;
  get diagnostics v_search_logs_deleted = row_count;

  delete from daily_usage where device_id = p_device_id;
  get diagnostics v_daily_usage_deleted = row_count;

  delete from users where device_id = p_device_id;
  get diagnostics v_users_deleted = row_count;

  return jsonb_build_object(
    'success', true,
    'search_logs_deleted', v_search_logs_deleted,
    'daily_usage_deleted', v_daily_usage_deleted,
    'users_deleted', v_users_deleted
  );
end;
$$;

grant execute on function search_dtc(text, text, text) to anon;
grant execute on function register_ad_view(text) to anon;
grant execute on function delete_my_data(text) to anon;
