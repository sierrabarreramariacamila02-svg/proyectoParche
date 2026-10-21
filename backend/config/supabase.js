import { createClient } from '@supabase/supabase-js';
import WebSocket from 'ws'; // NUEVO: Conexión a Supabase con transporte WebSocket para Node.js
import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_KEY;

export const supabase = createClient(supabaseUrl, supabaseKey, {
  auth: {
    persistSession: false,
    autoRefreshToken: false,
  },
  realtime: {            // NUEVO: todo este bloque
    transport: WebSocket,
  },
});