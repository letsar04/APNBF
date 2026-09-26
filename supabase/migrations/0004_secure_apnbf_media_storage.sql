insert into storage.buckets (id, name, public)
values ('apnbf-media', 'apnbf-media', true)
on conflict (id) do update set public = true;

drop policy if exists apnbf_media_public_read on storage.objects;
create policy apnbf_media_public_read on storage.objects
for select to public
using (bucket_id = 'apnbf-media');

drop policy if exists apnbf_media_owner_insert on storage.objects;
create policy apnbf_media_owner_insert on storage.objects
for insert to authenticated
with check (
  bucket_id = 'apnbf-media'
  and exists (
    select 1 from public.business_members bm
    where bm.user_id = (select auth.uid())
      and bm.business_id::text = split_part(name, '/', 1)
  )
);

drop policy if exists apnbf_media_owner_update on storage.objects;
create policy apnbf_media_owner_update on storage.objects
for update to authenticated
using (
  bucket_id = 'apnbf-media'
  and exists (select 1 from public.business_members bm where bm.user_id = (select auth.uid()) and bm.business_id::text = split_part(name, '/', 1))
)
with check (
  bucket_id = 'apnbf-media'
  and exists (select 1 from public.business_members bm where bm.user_id = (select auth.uid()) and bm.business_id::text = split_part(name, '/', 1))
);

drop policy if exists apnbf_media_owner_delete on storage.objects;
create policy apnbf_media_owner_delete on storage.objects
for delete to authenticated
using (
  bucket_id = 'apnbf-media'
  and exists (select 1 from public.business_members bm where bm.user_id = (select auth.uid()) and bm.business_id::text = split_part(name, '/', 1))
);
