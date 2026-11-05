REVOKE ALL ON TABLE public.inventario FROM anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.inventario TO service_role;

DO $$
DECLARE
  inventario_id_sequence TEXT;
BEGIN
  inventario_id_sequence := pg_get_serial_sequence('public.inventario', 'id');
  IF inventario_id_sequence IS NOT NULL THEN
    EXECUTE format(
      'GRANT USAGE, SELECT ON SEQUENCE %s TO service_role',
      inventario_id_sequence
    );
  END IF;
END
$$;
