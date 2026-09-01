import dotenv from 'dotenv';
import { createClient } from '@supabase/supabase-js';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error('❌ Error: Las variables SUPABASE_URL y SUPABASE_KEY son requeridas');
  process.exit(1);
}

export const supabase = createClient(supabaseUrl, supabaseKey);

export const connectaDB = () => {
    console.log('...//_________________________________________//...');
    console.log('✅ Conexión a Supabase establecida correctamente');
};