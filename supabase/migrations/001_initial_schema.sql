-- Krishi Smart — Supabase initial schema
-- Run via Supabase CLI: supabase db push

-- Farmer profiles (synced from app after OTP auth)
create table if not exists public.farmer_profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  phone text,
  full_name text,
  district text,
  municipality text,
  land_size_ropani numeric,
  main_crops text[] default '{}',
  preferred_language text default 'ne' check (preferred_language in ('ne', 'en')),
  consent_location boolean default false,
  consent_photos boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Disease scan history (metadata only; images stay on-device unless user opts in)
create table if not exists public.disease_scans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  crop_id text not null,
  disease_label text not null,
  confidence numeric not null check (confidence >= 0 and confidence <= 1),
  remedy_summary text,
  scanned_at timestamptz default now()
);

-- Sync queue audit (optional server-side mirror)
create table if not exists public.sync_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  entity_type text not null,
  entity_id text not null,
  action text not null,
  payload jsonb,
  created_at timestamptz default now()
);

-- Seller reviews for marketplace
create table if not exists public.seller_reviews (
  id text primary key,
  seller_id text not null,
  buyer_id text,
  product_id text,
  rating integer not null check (rating >= 1 and rating <= 5),
  comment text,
  created_at timestamptz default now()
);

-- Row Level Security
alter table public.farmer_profiles enable row level security;
alter table public.disease_scans enable row level security;
alter table public.sync_events enable row level security;
alter table public.seller_reviews enable row level security;

create policy "Users read own profile"
  on public.farmer_profiles for select
  using (auth.uid() = id);

create policy "Users upsert own profile"
  on public.farmer_profiles for all
  using (auth.uid() = id)
  with check (auth.uid() = id);

create policy "Users read own scans"
  on public.disease_scans for select
  using (auth.uid() = user_id);

create policy "Users insert own scans"
  on public.disease_scans for insert
  with check (auth.uid() = user_id);

create policy "Users read own sync events"
  on public.sync_events for select
  using (auth.uid() = user_id);

create policy "Users insert own sync events"
  on public.sync_events for insert
  with check (auth.uid() = user_id);

create policy "Anyone can read all seller reviews"
  on public.seller_reviews for select
  to authenticated
  using (true);

create policy "Users can insert own seller reviews"
  on public.seller_reviews for insert
  to authenticated
  with check (buyer_id = auth.uid()::text or buyer_id is null);

-- Updated_at trigger
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger farmer_profiles_updated_at
  before update on public.farmer_profiles
  for each row execute function public.set_updated_at();

-- Indexes for performance
create index if not exists idx_seller_reviews_seller_id on public.seller_reviews(seller_id);
create index if not exists idx_seller_reviews_created_at on public.seller_reviews(created_at desc);

