import dotenv from 'dotenv';
import {createClient} from '@supabase/supabasejsjs';

//cargar variables de entorno 
dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseUrl || !supabaseKey) {
    console.error('❌ Error: Las variables de SUPABASE_URL y SUPABASE_KEY  son requeridas ');
    process.exit(1);
}

export const supabase = createClient(supabaseUrl, supabaseKey);

export const conectaDB = () => {
    console.log('✅ conexion establecida correctamente');
};