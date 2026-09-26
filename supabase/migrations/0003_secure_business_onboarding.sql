alter table public.businesses add column if not exists created_by uuid references auth.users(id) on delete set null;

drop policy if exists businesses_insert on public.businesses;
create policy businesses_insert on public.businesses
for insert to authenticated
with check ((select auth.uid()) = created_by);

drop policy if exists business_members_insert on public.business_members;
create policy business_members_insert on public.business_members
for insert to authenticated
with check (
  user_id = (select auth.uid())
  and exists (
    select 1 from public.businesses b
    where b.id = business_id
      and b.created_by = (select auth.uid())
  )
);

drop policy if exists business_members_update on public.business_members;
create policy business_members_update on public.business_members
for update to authenticated
using (
  exists (
    select 1 from public.business_members me
    where me.business_id = business_members.business_id
      and me.user_id = (select auth.uid())
      and me.role in ('owner','admin')
  )
)
with check (
  exists (
    select 1 from public.business_members me
    where me.business_id = business_members.business_id
      and me.user_id = (select auth.uid())
      and me.role in ('owner','admin')
  )
);
