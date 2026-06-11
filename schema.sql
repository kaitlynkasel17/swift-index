-- The Swift Index — Supabase schema
-- Run this in your Supabase project:  Dashboard → SQL Editor → New query → paste → Run.
-- It is safe to re-run.

-- ============================================================
-- 1. votes — the log of every head-to-head pick (powers rankings)
-- ============================================================
create table if not exists public.votes (
  id            uuid primary key default gen_random_uuid(),
  room          text not null,
  player_id     text not null,
  player_name   text not null,
  player_color  text,
  winner        text not null,
  loser         text not null,
  created_at    timestamptz not null default now()
);
-- decision timing (ms it took to choose) + season label (for freeze/snapshot)
alter table public.votes add column if not exists decided_ms integer;
alter table public.votes add column if not exists season text not null default 'current';

create index if not exists votes_room_idx       on public.votes (room, created_at);
create index if not exists votes_room_player_idx on public.votes (room, player_id, season);

alter table public.votes enable row level security;
drop policy if exists "read votes"   on public.votes;
drop policy if exists "insert votes" on public.votes;
drop policy if exists "update votes" on public.votes;
drop policy if exists "delete votes" on public.votes;
create policy "read votes"   on public.votes for select using (true);
create policy "insert votes" on public.votes for insert with check (true);
create policy "update votes" on public.votes for update using (true) with check (true);
create policy "delete votes" on public.votes for delete using (true);

-- ============================================================
-- 2. duels — settled clashes from live Duel mode (kept separate from rankings)
-- ============================================================
create table if not exists public.duels (
  id            uuid primary key default gen_random_uuid(),
  room          text not null,
  song_a        text not null,
  song_b        text not null,
  winner        text,            -- song id; null = draw
  winner_lyric  text,
  player_a      text,
  player_b      text,
  mode          text,            -- 'lyric' | 'together' | 'draw'
  rounds        int,
  created_at    timestamptz not null default now()
);
create index if not exists duels_room_idx on public.duels (room, created_at);

alter table public.duels enable row level security;
drop policy if exists "read duels"   on public.duels;
drop policy if exists "insert duels" on public.duels;
drop policy if exists "delete duels" on public.duels;
create policy "read duels"   on public.duels for select using (true);
create policy "insert duels" on public.duels for insert with check (true);
create policy "delete duels" on public.duels for delete using (true);

-- ============================================================
-- 3. saved_duels — paused/parked live duels you can resume later
-- ============================================================
create table if not exists public.saved_duels (
  id          uuid primary key default gen_random_uuid(),
  room        text not null,
  label       text,
  state       jsonb not null,   -- full in-progress duel state
  created_at  timestamptz not null default now()
);
create index if not exists saved_duels_room_idx on public.saved_duels (room, created_at);

alter table public.saved_duels enable row level security;
drop policy if exists "read saved_duels"   on public.saved_duels;
drop policy if exists "insert saved_duels" on public.saved_duels;
drop policy if exists "delete saved_duels" on public.saved_duels;
create policy "read saved_duels"   on public.saved_duels for select using (true);
create policy "insert saved_duels" on public.saved_duels for insert with check (true);
create policy "delete saved_duels" on public.saved_duels for delete using (true);

-- ============================================================
-- 4. guesses — "read your friends" mini-game scores (mind-reader leaderboard)
-- ============================================================
create table if not exists public.guesses (
  id           uuid primary key default gen_random_uuid(),
  room         text not null,
  guesser_id   text not null,
  guesser_name text,
  target_name  text,
  correct      int not null,
  total        int not null,
  created_at   timestamptz not null default now()
);
create index if not exists guesses_room_idx on public.guesses (room, created_at);

alter table public.guesses enable row level security;
drop policy if exists "read guesses"   on public.guesses;
drop policy if exists "insert guesses" on public.guesses;
drop policy if exists "delete guesses" on public.guesses;
create policy "read guesses"   on public.guesses for select using (true);
create policy "insert guesses" on public.guesses for insert with check (true);
create policy "delete guesses" on public.guesses for delete using (true);

-- ============================================================
-- 5. Realtime — let everyone see new rows instantly
--    (the live Duel session itself uses ephemeral broadcast, no table needed)
-- ============================================================
do $$
begin
  begin execute 'alter publication supabase_realtime add table public.votes';       exception when duplicate_object then null; end;
  begin execute 'alter publication supabase_realtime add table public.duels';       exception when duplicate_object then null; end;
  begin execute 'alter publication supabase_realtime add table public.saved_duels'; exception when duplicate_object then null; end;
  begin execute 'alter publication supabase_realtime add table public.guesses';     exception when duplicate_object then null; end;
end $$;
