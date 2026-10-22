-- MEJIA | LA CULTURA 09 SPORT
-- Ejecutar en Supabase > SQL Editor DESPUÉS de crear el proyecto.
create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text not null,
  price numeric(10,2) not null check (price >= 0),
  stock integer not null default 0 check (stock >= 0),
  size text not null default '',
  description text not null default '',
  image_url text not null default '',
  tag text not null default '',
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.products enable row level security;

drop policy if exists "Public can read active products" on public.products;
create policy "Public can read active products"
on public.products for select
to anon, authenticated
using (active = true);

drop policy if exists "Authenticated users manage products" on public.products;
create policy "Authenticated users manage products"
on public.products for all
to authenticated
using (auth.uid() is not null)
with check (auth.uid() is not null);

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('product-photos', 'product-photos', true, 5242880, array['image/jpeg','image/png','image/webp'])
on conflict (id) do nothing;

drop policy if exists "Public can view product photos" on storage.objects;
create policy "Public can view product photos"
on storage.objects for select
to anon, authenticated
using (bucket_id = 'product-photos');

drop policy if exists "Authenticated users upload product photos" on storage.objects;
create policy "Authenticated users upload product photos"
on storage.objects for insert
to authenticated
with check (bucket_id = 'product-photos' and auth.uid() is not null);

drop policy if exists "Authenticated users update product photos" on storage.objects;
create policy "Authenticated users update product photos"
on storage.objects for update
to authenticated
using (bucket_id = 'product-photos' and auth.uid() is not null)
with check (bucket_id = 'product-photos' and auth.uid() is not null);

drop policy if exists "Authenticated users delete product photos" on storage.objects;
create policy "Authenticated users delete product photos"
on storage.objects for delete
to authenticated
using (bucket_id = 'product-photos' and auth.uid() is not null);
