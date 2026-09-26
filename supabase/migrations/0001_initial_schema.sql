-- APNBF Burkina Faso: initial multi-tenant schema
create extension if not exists pgcrypto;

create type public.member_role as enum ('owner','admin','manager','employee');
create type public.product_condition as enum ('new','used','refurbished');
create type public.product_status as enum ('draft','available','reserved','sold','inactive');
create type public.order_status as enum ('pending','confirmed','processing','ready','delivered','cancelled');
create type public.order_type as enum ('product','service','mixed');
create type public.preorder_status as enum ('interested','confirmed','deposit_paid','arrived','fulfilled','cancelled');
create type public.transaction_type as enum ('income','expense');
create type public.payment_method as enum ('cash','mobile_money','bank','other');
create type public.credit_status as enum ('active','partially_paid','paid','overdue','cancelled');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text, phone text, avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.businesses (
  id uuid primary key default gen_random_uuid(),
  name text not null, description text, phone text, whatsapp text, email text,
  address text, logo_url text, currency text not null default 'XOF',
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

create table public.business_members (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role public.member_role not null default 'employee',
  created_at timestamptz not null default now(),
  unique (business_id,user_id)
);

create table public.clients (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  full_name text not null, phone text, whatsapp text, email text, address text,
  latitude double precision, longitude double precision, notes text,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

create table public.product_categories (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  name text not null, created_at timestamptz not null default now(),
  unique (business_id,name)
);

create table public.products (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  category_id uuid references public.product_categories(id) on delete set null,
  name text not null, description text,
  price numeric(14,2) not null default 0 check (price >= 0),
  cost_price numeric(14,2) check (cost_price is null or cost_price >= 0),
  quantity numeric(14,2) not null default 0 check (quantity >= 0),
  condition public.product_condition not null default 'used',
  status public.product_status not null default 'draft',
  is_preorder boolean not null default false,
  preorder_price numeric(14,2) check (preorder_price is null or preorder_price >= 0),
  arrival_date date,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

create table public.product_images (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  storage_path text not null, sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

create table public.services (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  name text not null, description text,
  price_type text not null default 'quote' check (price_type in ('fixed','quote','starting_from')),
  base_price numeric(14,2) check (base_price is null or base_price >= 0),
  image_url text, is_active boolean not null default true,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

create table public.orders (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  client_id uuid not null references public.clients(id) on delete restrict,
  status public.order_status not null default 'pending',
  order_type public.order_type not null default 'product',
  total_amount numeric(14,2) not null default 0 check (total_amount >= 0),
  paid_amount numeric(14,2) not null default 0 check (paid_amount >= 0),
  notes text,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

create table public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  product_id uuid references public.products(id) on delete restrict,
  service_id uuid references public.services(id) on delete restrict,
  description text, quantity numeric(14,2) not null default 1 check (quantity > 0),
  unit_price numeric(14,2) not null default 0 check (unit_price >= 0),
  created_at timestamptz not null default now(),
  check (product_id is not null or service_id is not null or description is not null)
);

create table public.preorders (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete restrict,
  client_id uuid not null references public.clients(id) on delete restrict,
  quantity numeric(14,2) not null default 1 check (quantity > 0),
  estimated_price numeric(14,2), deposit_amount numeric(14,2) not null default 0 check (deposit_amount >= 0),
  expected_arrival date, status public.preorder_status not null default 'interested',
  notes text, created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

create table public.transactions (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  type public.transaction_type not null, amount numeric(14,2) not null check (amount > 0),
  category text not null, reference_type text, reference_id uuid, description text,
  transaction_date date not null default current_date, created_at timestamptz not null default now()
);

create table public.credits (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  client_id uuid not null references public.clients(id) on delete restrict,
  order_id uuid references public.orders(id) on delete set null,
  original_amount numeric(14,2) not null check (original_amount > 0),
  paid_amount numeric(14,2) not null default 0 check (paid_amount >= 0),
  due_date date, status public.credit_status not null default 'active',
  notes text, created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  check (paid_amount <= original_amount)
);

create table public.payments (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  client_id uuid references public.clients(id) on delete set null,
  order_id uuid references public.orders(id) on delete set null,
  credit_id uuid references public.credits(id) on delete set null,
  amount numeric(14,2) not null check (amount > 0),
  payment_method public.payment_method not null default 'cash',
  reference text, notes text, paid_at timestamptz not null default now()
);

create table public.expenses (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  category text not null, amount numeric(14,2) not null check (amount > 0),
  description text, supplier text, expense_date date not null default current_date,
  created_at timestamptz not null default now()
);

create index clients_business_idx on public.clients(business_id);
create index products_business_idx on public.products(business_id);
create index orders_business_idx on public.orders(business_id);
create index transactions_business_date_idx on public.transactions(business_id,transaction_date);
create index credits_business_status_idx on public.credits(business_id,status);
create index preorders_business_status_idx on public.preorders(business_id,status);

create or replace function public.is_business_member(target_business_id uuid)
returns boolean language sql stable security invoker set search_path=public
as $$ select exists (
  select 1 from public.business_members bm
  where bm.business_id=target_business_id and bm.user_id=(select auth.uid())
); $$;

alter table public.profiles enable row level security;
alter table public.businesses enable row level security;
alter table public.business_members enable row level security;
alter table public.clients enable row level security;
alter table public.product_categories enable row level security;
alter table public.products enable row level security;
alter table public.product_images enable row level security;
alter table public.services enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.preorders enable row level security;
alter table public.transactions enable row level security;
alter table public.credits enable row level security;
alter table public.payments enable row level security;
alter table public.expenses enable row level security;

create policy profiles_select_own on public.profiles for select to authenticated using (id=(select auth.uid()));
create policy profiles_insert_own on public.profiles for insert to authenticated with check (id=(select auth.uid()));
create policy profiles_update_own on public.profiles for update to authenticated using (id=(select auth.uid())) with check (id=(select auth.uid()));

create policy business_members_select on public.business_members for select to authenticated using (user_id=(select auth.uid()) or public.is_business_member(business_id));
create policy businesses_select on public.businesses for select to authenticated using (public.is_business_member(id));
create policy businesses_update on public.businesses for update to authenticated using (public.is_business_member(id)) with check (public.is_business_member(id));

create policy clients_all on public.clients for all to authenticated using (public.is_business_member(business_id)) with check (public.is_business_member(business_id));
create policy categories_all on public.product_categories for all to authenticated using (public.is_business_member(business_id)) with check (public.is_business_member(business_id));
create policy products_all on public.products for all to authenticated using (public.is_business_member(business_id)) with check (public.is_business_member(business_id));
create policy services_all on public.services for all to authenticated using (public.is_business_member(business_id)) with check (public.is_business_member(business_id));
create policy orders_all on public.orders for all to authenticated using (public.is_business_member(business_id)) with check (public.is_business_member(business_id));
create policy preorders_all on public.preorders for all to authenticated using (public.is_business_member(business_id)) with check (public.is_business_member(business_id));
create policy transactions_all on public.transactions for all to authenticated using (public.is_business_member(business_id)) with check (public.is_business_member(business_id));
create policy credits_all on public.credits for all to authenticated using (public.is_business_member(business_id)) with check (public.is_business_member(business_id));
create policy payments_all on public.payments for all to authenticated using (public.is_business_member(business_id)) with check (public.is_business_member(business_id));
create policy expenses_all on public.expenses for all to authenticated using (public.is_business_member(business_id)) with check (public.is_business_member(business_id));

create policy product_images_all on public.product_images for all to authenticated
using (exists(select 1 from public.products p where p.id=product_id and public.is_business_member(p.business_id)))
with check (exists(select 1 from public.products p where p.id=product_id and public.is_business_member(p.business_id)));

create policy order_items_all on public.order_items for all to authenticated
using (exists(select 1 from public.orders o where o.id=order_id and public.is_business_member(o.business_id)))
with check (exists(select 1 from public.orders o where o.id=order_id and public.is_business_member(o.business_id)));
