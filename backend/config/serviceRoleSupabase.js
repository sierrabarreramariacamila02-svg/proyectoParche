import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

let serviceRoleClient;

export const obtenerClienteServiceRole = () => {
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  const supabaseUrl = process.env.SUPABASE_URL;

  if (!supabaseUrl || !serviceRoleKey) {
    const error = new Error(
      'Configura SUPABASE_URL y SUPABASE_SERVICE_ROLE_KEY en el backend para registrar pedidos.',
    );
    error.code = 'SUPABASE_SERVICE_ROLE_CONFIG';
    throw error;
  }

  if (!serviceRoleClient) {
    serviceRoleClient = createClient(supabaseUrl, serviceRoleKey, {
      auth: {
        persistSession: false,
        autoRefreshToken: false,
      },
    });
  }

  return serviceRoleClient;
};
