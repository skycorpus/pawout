-- ============================================================
-- PawOut — Schema DDL
-- 실행 순서: 001_schema.sql → 002_rls.sql
-- Supabase SQL Editor에서 순서대로 실행하세요.
-- ============================================================


-- ── profiles ─────────────────────────────────────────────────
create table if not exists profiles (
  id         uuid primary key references auth.users(id) on delete cascade,
  name       text not null,
  created_at timestamptz not null default now()
);


-- ── common_codes ─────────────────────────────────────────────
create table if not exists common_codes (
  group_code text not null,
  code       text not null,
  code_name  text not null,
  sort_order int  not null default 0,
  primary key (group_code, code)
);


-- ── dogs ─────────────────────────────────────────────────────
create table if not exists dogs (
  id                bigint generated always as identity primary key,
  user_id           uuid        not null references auth.users(id) on delete cascade,
  name              text        not null,
  breed             text        not null,  -- common_codes.code (e.g. 'POODLE')
  birth_date        date        not null,
  gender            text        not null check (gender in ('male', 'female')),
  weight            numeric     not null,
  is_neutered       boolean     not null default false,
  chip_number       text,
  profile_image_url text,
  i_date            timestamptz not null default now(),
  i_user            text,
  u_date            timestamptz,
  u_user            text
);

create index if not exists idx_dogs_user on dogs(user_id);


-- ── walks ─────────────────────────────────────────────────────
create table if not exists walks (
  id          bigint generated always as identity primary key,
  dog_id      bigint      not null references dogs(id) on delete cascade,
  start_time  timestamptz not null,
  end_time    timestamptz,
  distance_km numeric,
  steps       int,
  route_points jsonb,
  created_at  timestamptz not null default now()
);

create index if not exists idx_walks_dog on walks(dog_id);


-- ── walk_dogs ─────────────────────────────────────────────────
create table if not exists walk_dogs (
  id                    bigint generated always as identity primary key,
  walk_id               bigint      not null references walks(id) on delete cascade,
  dog_id                bigint      not null references dogs(id) on delete cascade,
  allocated_steps       int,
  allocated_distance_km numeric,
  display_order         int         not null default 0,
  created_at            timestamptz not null default now(),
  unique (walk_id, dog_id)
);

create index if not exists idx_walk_dogs_walk on walk_dogs(walk_id);
create index if not exists idx_walk_dogs_dog  on walk_dogs(dog_id);


-- ── daily_rankings ────────────────────────────────────────────
create table if not exists daily_rankings (
  id                bigint generated always as identity primary key,
  dog_id            bigint  not null references dogs(id) on delete cascade,
  date              date    not null,
  total_steps       int     not null default 0,
  total_distance_km numeric not null default 0,
  unique (dog_id, date)
);

create index if not exists idx_daily_rankings_date on daily_rankings(date);


-- ── likes ─────────────────────────────────────────────────────
create table if not exists likes (
  id         bigint generated always as identity primary key,
  user_id    uuid        not null references auth.users(id) on delete cascade,
  dog_id     bigint      not null references dogs(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (user_id, dog_id)
);

create index if not exists idx_likes_dog on likes(dog_id);


-- ── follows ───────────────────────────────────────────────────
create table if not exists follows (
  id           bigint generated always as identity primary key,
  follower_id  uuid        not null references auth.users(id) on delete cascade,
  following_id uuid        not null references auth.users(id) on delete cascade,
  created_at   timestamptz not null default now(),
  unique (follower_id, following_id),
  check (follower_id <> following_id)
);

create index if not exists idx_follows_follower  on follows(follower_id);
create index if not exists idx_follows_following on follows(following_id);


-- ── dog_members ───────────────────────────────────────────────
create table if not exists dog_members (
  id         bigint generated always as identity primary key,
  dog_id     bigint      not null references dogs(id) on delete cascade,
  user_id    uuid        not null references auth.users(id) on delete cascade,
  role       text        not null check (role in ('owner', 'family')),
  is_primary boolean     not null default false,
  joined_at  timestamptz not null default now(),
  invited_by uuid        references auth.users(id) on delete set null,
  unique (dog_id, user_id)
);

create index if not exists idx_dog_members_dog  on dog_members(dog_id);
create index if not exists idx_dog_members_user on dog_members(user_id);


-- ── dog_invites ───────────────────────────────────────────────
create table if not exists dog_invites (
  id          bigint generated always as identity primary key,
  dog_id      bigint      not null references dogs(id) on delete cascade,
  invite_code text        not null unique,
  created_by  uuid        not null references auth.users(id) on delete cascade,
  expires_at  timestamptz not null default (now() + interval '7 days'),
  used_by     uuid        references auth.users(id) on delete set null,
  used_at     timestamptz,
  created_at  timestamptz not null default now()
);

create index if not exists idx_dog_invites_code on dog_invites(invite_code);
create index if not exists idx_dog_invites_dog  on dog_invites(dog_id);
