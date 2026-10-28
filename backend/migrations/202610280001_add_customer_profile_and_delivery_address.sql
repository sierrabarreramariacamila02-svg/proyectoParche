ALTER TABLE public.usuario
ADD COLUMN IF NOT EXISTS avatar TEXT;

ALTER TABLE public.pedido
ADD COLUMN IF NOT EXISTS direccion_entrega TEXT;
