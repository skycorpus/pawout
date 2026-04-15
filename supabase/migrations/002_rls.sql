-- ============================================================
-- PawOut — Row Level Security Policies
-- 실행 순서: 001_schema.sql → 002_rls.sql
-- Supabase SQL Editor에서 순서대로 실행하세요.
-- ============================================================


-- ── profiles ─────────────────────────────────────────────────
alter table profiles enable row level security;

create policy "profiles: anyone can read"
  on profiles for select
  to authenticated
  using (true);

create policy "profiles: owner can insert"
  on profiles for insert
  to authenticated
  with check (auth.uid() = id);

create policy "profiles: owner can update"
  on profiles for update
  to authenticated
  using (auth.uid() = id);


-- ── dogs ─────────────────────────────────────────────────────
alter table dogs enable row level security;

create policy "dogs: anyone can read"
  on dogs for select
  to authenticated
  using (true);

create policy "dogs: owner can insert"
  on dogs for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "dogs: owner can update"
  on dogs for update
  to authenticated
  using (auth.uid() = user_id);

create policy "dogs: owner can delete"
  on dogs for delete
  to authenticated
  using (auth.uid() = user_id);


-- ── walks ─────────────────────────────────────────────────────
alter table walks enable row level security;

create policy "walks: anyone can read completed"
  on walks for select
  to authenticated
  using (
    end_time is not null
    or dog_id in (select id from dogs where user_id = auth.uid())
  );

create policy "walks: owner can insert"
  on walks for insert
  to authenticated
  with check (
    dog_id in (select id from dogs where user_id = auth.uid())
  );

create policy "walks: owner can update"
  on walks for update
  to authenticated
  using (
    dog_id in (select id from dogs where user_id = auth.uid())
  );

create policy "walks: owner can delete"
  on walks for delete
  to authenticated
  using (
    dog_id in (select id from dogs where user_id = auth.uid())
  );


-- ── walk_dogs ─────────────────────────────────────────────────
alter table walk_dogs enable row level security;

create policy "walk_dogs: anyone can read"
  on walk_dogs for select
  to authenticated
  using (true);

create policy "walk_dogs: owner can insert"
  on walk_dogs for insert
  to authenticated
  with check (
    dog_id in (select id from dogs where user_id = auth.uid())
  );

create policy "walk_dogs: owner can delete"
  on walk_dogs for delete
  to authenticated
  using (
    dog_id in (select id from dogs where user_id = auth.uid())
  );


-- ── daily_rankings ────────────────────────────────────────────
alter table daily_rankings enable row level security;

create policy "daily_rankings: anyone can read"
  on daily_rankings for select
  to authenticated
  using (true);

create policy "daily_rankings: owner can upsert"
  on daily_rankings for all
  to authenticated
  using (dog_id in (select id from dogs where user_id = auth.uid()))
  with check (dog_id in (select id from dogs where user_id = auth.uid()));


-- ── likes ─────────────────────────────────────────────────────
alter table likes enable row level security;

create policy "likes: anyone can read"
  on likes for select
  to authenticated
  using (true);

create policy "likes: owner can insert"
  on likes for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "likes: owner can delete"
  on likes for delete
  to authenticated
  using (auth.uid() = user_id);


-- ── follows ───────────────────────────────────────────────────
alter table follows enable row level security;

create policy "follows: anyone can read"
  on follows for select
  to authenticated
  using (true);

create policy "follows: owner can insert"
  on follows for insert
  to authenticated
  with check (auth.uid() = follower_id);

create policy "follows: owner can delete"
  on follows for delete
  to authenticated
  using (auth.uid() = follower_id);


-- ── dog_members ───────────────────────────────────────────────
alter table dog_members enable row level security;

create policy "dog_members: members can read"
  on dog_members for select
  to authenticated
  using (
    user_id = auth.uid()
    or dog_id in (select dog_id from dog_members where user_id = auth.uid())
  );

create policy "dog_members: owner can insert"
  on dog_members for insert
  to authenticated
  with check (
    auth.uid() = invited_by
    or auth.uid() = user_id
  );

create policy "dog_members: owner can delete"
  on dog_members for delete
  to authenticated
  using (
    auth.uid() = user_id
    or dog_id in (
      select dog_id from dog_members
      where user_id = auth.uid() and role = 'owner'
    )
  );


-- ── dog_invites ───────────────────────────────────────────────
alter table dog_invites enable row level security;

create policy "dog_invites: members can create"
  on dog_invites for insert
  to authenticated
  with check (
    exists (
      select 1 from dog_members
      where dog_members.dog_id = dog_invites.dog_id
        and dog_members.user_id = auth.uid()
    )
  );

create policy "dog_invites: anyone can read by code"
  on dog_invites for select
  to authenticated
  using (true);

create policy "dog_invites: user can accept"
  on dog_invites for update
  to authenticated
  using (auth.uid() is not null)
  with check (used_by = auth.uid());
