const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error('⚠️  Faltan las variables SUPABASE_URL o SUPABASE_KEY en el .env');
}

const supabase = createClient(supabaseUrl, supabaseKey);

module.exports = supabase;
