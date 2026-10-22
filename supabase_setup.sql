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
  images text[] not null default '{}',
  tag text not null default '',
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.products add column if not exists images text[] not null default '{}';

alter table public.products enable row level security;

drop policy if exists "Public can read active products" on public.products;
create policy "Public can read active products"
on public.products for select
to anon, authenticated
using (active = true);

drop policy if exists "Authenticated users manage products" on public.products;
drop policy if exists "Only LC09 admin manages products" on public.products;
create policy "Only LC09 admin manages products"
on public.products for all
to authenticated
using (auth.uid() = '8f587962-3b19-4601-a00a-7edcec31ee1d'::uuid)
with check (auth.uid() = '8f587962-3b19-4601-a00a-7edcec31ee1d'::uuid);

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('product-photos', 'product-photos', true, 5242880, array['image/jpeg','image/png','image/webp'])
on conflict (id) do nothing;

drop policy if exists "Public can view product photos" on storage.objects;
create policy "Public can view product photos"
on storage.objects for select
to anon, authenticated
using (bucket_id = 'product-photos');

drop policy if exists "Authenticated users upload product photos" on storage.objects;
drop policy if exists "Only LC09 admin uploads product photos" on storage.objects;
create policy "Only LC09 admin uploads product photos"
on storage.objects for insert
to authenticated
with check (bucket_id = 'product-photos' and auth.uid() = '8f587962-3b19-4601-a00a-7edcec31ee1d'::uuid);

drop policy if exists "Authenticated users update product photos" on storage.objects;
drop policy if exists "Only LC09 admin updates product photos" on storage.objects;
create policy "Only LC09 admin updates product photos"
on storage.objects for update
to authenticated
using (bucket_id = 'product-photos' and auth.uid() = '8f587962-3b19-4601-a00a-7edcec31ee1d'::uuid)
with check (bucket_id = 'product-photos' and auth.uid() = '8f587962-3b19-4601-a00a-7edcec31ee1d'::uuid);

drop policy if exists "Authenticated users delete product photos" on storage.objects;
drop policy if exists "Only LC09 admin deletes product photos" on storage.objects;
create policy "Only LC09 admin deletes product photos"
on storage.objects for delete
to authenticated
using (bucket_id = 'product-photos' and auth.uid() = '8f587962-3b19-4601-a00a-7edcec31ee1d'::uuid);


-- Pedidos creados desde la tienda pública. No procesa pagos en línea.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  customer_name text not null check (char_length(customer_name) between 1 and 120),
  phone text not null check (char_length(phone) between 1 and 40),
  delivery text not null default 'Coordinar entrega',
  items jsonb not null default '[]'::jsonb,
  total_dop numeric(12,2) not null check (total_dop >= 0),
  status text not null default 'Pendiente' check (status in ('Pendiente','En proceso','Completada','Cancelada')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.orders enable row level security;
drop policy if exists "Public can place orders" on public.orders;
create policy "Public can place orders" on public.orders for insert to anon, authenticated with check (true);
drop policy if exists "Only LC09 admin reads orders" on public.orders;
create policy "Only LC09 admin reads orders" on public.orders for select to authenticated using (auth.uid() = '8f587962-3b19-4601-a00a-7edcec31ee1d'::uuid);
drop policy if exists "Only LC09 admin updates orders" on public.orders;
create policy "Only LC09 admin updates orders" on public.orders for update to authenticated using (auth.uid() = '8f587962-3b19-4601-a00a-7edcec31ee1d'::uuid) with check (auth.uid() = '8f587962-3b19-4601-a00a-7edcec31ee1d'::uuid);
