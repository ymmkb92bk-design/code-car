create policy "anon can log searches"
  on search_logs for insert
  to anon
  with check (true);
