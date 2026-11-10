import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

let clienteInventario;

export const obtenerClienteInventario = () => {
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!serviceRoleKey) {
    const error = new Error(
      'Configura SUPABASE_SERVICE_ROLE_KEY en el entorno del backend para administrar el inventario.',
    );
    error.code = 'INVENTORY_DB_CONFIG';
    throw error;
  }

  if (!clienteInventario) {
    clienteInventario = createClient(process.env.SUPABASE_URL, serviceRoleKey, {
      auth: {
        persistSession: false,
        autoRefreshToken: false,
      },
    });
  }

  return clienteInventario;
};
