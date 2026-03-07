create table if not exists public.contribution_events (
  id bigint generated always as identity primary key,
  user_id uuid references auth.users(id),
  event_id text unique not null,
  module_id text not null,
  occurred_at timestamptz not null,
  payload jsonb not null,
  created_at timestamptz not null default now()
);

create index idx_contribution_events_user_id on public.contribution_events(user_id);
create index idx_contribution_events_module_id on public.contribution_events(module_id);

alter table public.contribution_events enable row level security;

create policy "users_read_own_events"
on public.contribution_events for select
to authenticated
using (user_id = auth.uid());

create policy "users_insert_own_events"
on public.contribution_events for insert
to authenticated
with check (user_id = auth.uid());

-- Anon-Insert für User die noch nicht eingeloggt sind
create policy "anon_insert_events"
on public.contribution_events for insert
to anon
with check (true);
