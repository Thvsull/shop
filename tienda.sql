-- Ejecuta una vez en Supabase → SQL Editor → New query → Run
-- ANTES de ejecutar: cambia TU_CORREO@EJEMPLO.COM (última línea) por el correo con el que creaste tu cuenta en la app de finanzas.
create table if not exists public.tienda_catalogo(
  id int primary key default 1 check (id = 1),
  data jsonb not null default '{}',
  updated_at timestamptz not null default now()
);
create table if not exists public.tienda_admin(
  user_id uuid primary key references auth.users(id) on delete cascade
);
alter table public.tienda_catalogo enable row level security;
alter table public.tienda_admin enable row level security;

-- Cualquier cliente puede VER el catálogo
create policy "catalogo publico" on public.tienda_catalogo for select using (true);
-- Solo los administradores pueden crear/editar el catálogo
create policy "admin escribe catalogo" on public.tienda_catalogo for all
  using (exists (select 1 from public.tienda_admin a where a.user_id = auth.uid()))
  with check (exists (select 1 from public.tienda_admin a where a.user_id = auth.uid()));
create policy "ver mi admin" on public.tienda_admin for select using (auth.uid() = user_id);

-- Te registra como administrador (dueño)
insert into public.tienda_admin(user_id) select id from auth.users where email = 'TU_CORREO@EJEMPLO.COM' on conflict do nothing;
