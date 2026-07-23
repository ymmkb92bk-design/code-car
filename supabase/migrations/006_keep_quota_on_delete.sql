-- Revised: deleting a user's data must not reset their daily_usage quota
-- counter — otherwise "delete my data" becomes a free way to bypass the
-- 3/day limit (Section 5/6 anti-abuse). daily_usage is retained; it's a
-- rate-limiting counter, not personal search content, so keeping it is a
-- defensible, disclosed exception to the deletion request (documented in
-- Privacy_Policy_and_Terms.md / docs/privacy-policy.html).
create or replace function delete_my_data(p_device_id text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_search_logs_deleted integer;
  v_users_deleted integer;
begin
  delete from search_logs where device_id = p_device_id;
  get diagnostics v_search_logs_deleted = row_count;

  delete from users where device_id = p_device_id;
  get diagnostics v_users_deleted = row_count;

  return jsonb_build_object(
    'success', true,
    'search_logs_deleted', v_search_logs_deleted,
    'users_deleted', v_users_deleted
  );
end;
$$;

grant execute on function delete_my_data(text) to anon;
