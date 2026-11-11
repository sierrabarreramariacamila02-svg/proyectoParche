ALTER TABLE public.pedido
ADD COLUMN IF NOT EXISTS nombre_receptor TEXT,
ADD COLUMN IF NOT EXISTS telefono_receptor TEXT,
ADD COLUMN IF NOT EXISTS correo_contacto TEXT,
ADD COLUMN IF NOT EXISTS metodo_pago TEXT;
