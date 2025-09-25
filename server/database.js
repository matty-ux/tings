import pg from 'pg';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const { Pool } = pg;

// Get database URL from environment variables
// Railway automatically provides DATABASE_URL when you add PostgreSQL
const databaseUrl = process.env.DATABASE_URL || process.env.POSTGRES_URL;

// For local development, you can set a local PostgreSQL URL
const localUrl = process.env.LOCAL_DATABASE_URL || 'postgresql://localhost:5432/vendgb';

const pool = new Pool({
  connectionString: databaseUrl || localUrl,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
});

// Test the connection
pool.on('connect', () => {
  console.log('✅ Connected to PostgreSQL database');
});

pool.on('error', (err) => {
  console.error('❌ PostgreSQL connection error:', err);
});

// Database initialization function
export async function initializeDatabase() {
  try {
    console.log('🔄 Initializing database...');
    
    // Create products table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS products (
        id SERIAL PRIMARY KEY,
        sku VARCHAR(100),
        name VARCHAR(255) NOT NULL,
        short_desc TEXT,
        full_desc TEXT,
        category VARCHAR(100),
        tags JSONB DEFAULT '[]',
        price DECIMAL(10,2) NOT NULL,
        sale_price DECIMAL(10,2),
        tax_rate DECIMAL(5,4) DEFAULT 0,
        cost_price DECIMAL(10,2),
        available BOOLEAN DEFAULT true,
        stock_qty INTEGER DEFAULT 0,
        max_order_qty INTEGER DEFAULT 5,
        prep_time_mins INTEGER DEFAULT 15,
        image_url VARCHAR(500),
        images JSONB DEFAULT '[]',
        active BOOLEAN DEFAULT true,
        sort_order INTEGER DEFAULT 0,
        metadata JSONB,
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW()
      )
    `);

    // Create orders table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS orders (
        id SERIAL PRIMARY KEY,
        order_id VARCHAR(50) UNIQUE NOT NULL,
        customer_name VARCHAR(255) NOT NULL,
        customer_phone VARCHAR(50),
        customer_email VARCHAR(255),
        items JSONB NOT NULL,
        total DECIMAL(10,2) NOT NULL,
        status VARCHAR(50) DEFAULT 'new',
        delivery_address TEXT,
        special_instructions TEXT,
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW()
      )
    `);

    // Create indexes for better performance
    await pool.query(`
      CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
    `);
    
    await pool.query(`
      CREATE INDEX IF NOT EXISTS idx_products_active ON products(active);
    `);
    
    await pool.query(`
      CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
    `);
    
    await pool.query(`
      CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at);
    `);

    console.log('✅ Database initialized successfully');
  } catch (error) {
    console.error('❌ Database initialization failed:', error);
    throw error;
  }
}

// Helper function to run queries
export async function query(text, params = []) {
  try {
    const start = Date.now();
    const result = await pool.query(text, params);
    const duration = Date.now() - start;
    console.log('📊 Query executed', { text: text.substring(0, 50) + '...', duration: duration + 'ms' });
    return result;
  } catch (error) {
    console.error('❌ Database query error:', error);
    throw error;
  }
}

// Close the pool when the app shuts down
export async function closeDatabase() {
  await pool.end();
}

export default pool;
