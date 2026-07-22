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

grant execute on function delete_my_data(text) to anon;
