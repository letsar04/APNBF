alter table public.businesses add column if not exists public_slug text;
alter table public.businesses add column if not exists is_public boolean not null default true;
update public.businesses set public_slug = lower(regexp_replace(name, '[^a-zA-Z0-9]+', '-', 'g')) || '-' || substr(id::text,1,6) where public_slug is null;
create unique index if not exists businesses_public_slug_idx on public.businesses(public_slug);

create table if not exists public.customer_requests (
  id uuid primary key default gen_random_uuid(), business_id uuid not null references public.businesses(id) on delete cascade,
  client_name text not null, phone text, whatsapp text,
  request_type text not null default 'order' check (request_type in ('order','preorder','quote','contact')),
  product_id uuid references public.products(id) on delete set null, service_id uuid references public.services(id) on delete set null,
  quantity numeric(14,2) not null default 1 check (quantity > 0), message text,
  status text not null default 'new' check (status in ('new','contacted','confirmed','cancelled','completed')),
  created_at timestamptz not null default now()
);
create index if not exists customer_requests_business_idx on public.customer_requests(business_id,status,created_at desc);
alter table public.customer_requests enable row level security;
create policy customer_requests_public_insert on public.customer_requests for insert to anon, authenticated with check (exists(select 1 from public.businesses b where b.id=business_id and b.is_public=true));
create policy customer_requests_owner_select on public.customer_requests for select to authenticated using (public.is_business_member(business_id));
create policy customer_requests_owner_update on public.customer_requests for update to authenticated using (public.is_business_member(business_id)) with check (public.is_business_member(business_id));

drop policy if exists businesses_public_select on public.businesses;
create policy businesses_public_select on public.businesses for select to anon using (is_public=true);
drop policy if exists products_public_select on public.products;
create policy products_public_select on public.products for select to anon using (status='available' and exists(select 1 from public.businesses b where b.id=business_id and b.is_public=true));
drop policy if exists services_public_select on public.services;
create policy services_public_select on public.services for select to anon using (is_active=true and exists(select 1 from public.businesses b where b.id=business_id and b.is_public=true));
drop policy if exists product_images_public_select on public.product_images;
create policy product_images_public_select on public.product_images for select to anon using (exists(select 1 from public.products p join public.businesses b on b.id=p.business_id where p.id=product_id and p.status='available' and b.is_public=true));

create or replace view public.public_businesses with (security_invoker=true) as select id,name,description,phone,whatsapp,email,address,logo_url,public_slug from public.businesses where is_public=true;
create or replace view public.public_products with (security_invoker=true) as select p.id,p.business_id,p.name,p.description,p.price,p.quantity,p.condition,p.status,p.is_preorder,p.preorder_price,p.arrival_date,p.created_at,(select pi.storage_path from public.product_images pi where pi.product_id=p.id order by pi.sort_order,pi.created_at limit 1) as image_path from public.products p where p.status='available';
create or replace view public.public_services with (security_invoker=true) as select id,business_id,name,description,price_type,base_price,image_url from public.services where is_active=true;
create or replace view public.public_product_images with (security_invoker=true) as select id,product_id,storage_path,sort_order from public.product_images;
grant select on public.public_businesses, public.public_products, public.public_services, public.public_product_images to anon, authenticated;
grant insert on public.customer_requests to anon, authenticated;
grant select, update on public.customer_requests to authenticated;

insert into storage.buckets (id,name,public) values ('apnbf-media','apnbf-media',true) on conflict (id) do update set public=true;
drop policy if exists apnbf_media_public_read on storage.objects;
create policy apnbf_media_public_read on storage.objects for select to anon, authenticated using (bucket_id='apnbf-media');
drop policy if exists apnbf_media_auth_insert on storage.objects;
create policy apnbf_media_auth_insert on storage.objects for insert to authenticated with check (bucket_id='apnbf-media' and public.is_business_member(((storage.foldername(name))[1])::uuid));
drop policy if exists apnbf_media_auth_update on storage.objects;
create policy apnbf_media_auth_update on storage.objects for update to authenticated using (bucket_id='apnbf-media' and public.is_business_member(((storage.foldername(name))[1])::uuid)) with check (bucket_id='apnbf-media' and public.is_business_member(((storage.foldername(name))[1])::uuid));
drop policy if exists apnbf_media_auth_delete on storage.objects;
create policy apnbf_media_auth_delete on storage.objects for delete to authenticated using (bucket_id='apnbf-media' and public.is_business_member(((storage.foldername(name))[1])::uuid));