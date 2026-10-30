ALTER TABLE public.usuario
ADD COLUMN IF NOT EXISTS creado_por_admin BOOLEAN NOT NULL DEFAULT FALSE;

UPDATE public.usuario
SET creado_por_admin = TRUE
WHERE LOWER(COALESCE(rol, '')) IN (
  'pendiente',
  'mesero',
  'cocinero',
  'cocina',
  'domiciliario',
  'domicilio',
  'admin',
  'administrador'
);
