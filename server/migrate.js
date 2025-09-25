import fs from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { initializeDatabase, query } from './database.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Migration function
async function migrateData() {
  try {
    console.log('🚀 Starting data migration from JSON to PostgreSQL...');
    
    // Initialize database
    await initializeDatabase();
    
    // Read existing JSON files
    const productsPath = join(__dirname, 'data', 'products.json');
    const ordersPath = join(__dirname, 'data', 'orders.json');
    
    // Migrate products
    if (fs.existsSync(productsPath)) {
      console.log('📦 Migrating products...');
      const productsData = JSON.parse(fs.readFileSync(productsPath, 'utf8'));
      
      for (const product of productsData) {
        await query(`
          INSERT INTO products (name, price, category, active, stock, description, image_url, metadata)
          VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
          ON CONFLICT DO NOTHING
        `, [
          product.name,
          product.price,
          product.category || 'General',
          product.active !== false,
          product.stock || 0,
          product.description || '',
          product.image || '',
          JSON.stringify(product.metadata || {})
        ]);
      }
      console.log(`✅ Migrated ${productsData.length} products`);
    }
    
    // Migrate orders
    if (fs.existsSync(ordersPath)) {
      console.log('📋 Migrating orders...');
      const ordersData = JSON.parse(fs.readFileSync(ordersPath, 'utf8'));
      
      for (const order of ordersData) {
        await query(`
          INSERT INTO orders (order_id, customer_name, customer_phone, customer_email, items, total, status, delivery_address, special_instructions)
          VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
          ON CONFLICT (order_id) DO NOTHING
        `, [
          order.id,
          order.customerName || 'Guest',
          order.customerPhone || '',
          order.customerEmail || '',
          JSON.stringify(order.items || []),
          order.total || 0,
          order.status || 'new',
          order.deliveryAddress || '',
          order.specialInstructions || ''
        ]);
      }
      console.log(`✅ Migrated ${ordersData.length} orders`);
    }
    
    console.log('🎉 Migration completed successfully!');
    
    // Show some stats
    const productCount = await query('SELECT COUNT(*) FROM products');
    const orderCount = await query('SELECT COUNT(*) FROM orders');
    
    console.log(`📊 Database now contains:`);
    console.log(`   - ${productCount.rows[0].count} products`);
    console.log(`   - ${orderCount.rows[0].count} orders`);
    
  } catch (error) {
    console.error('❌ Migration failed:', error);
    process.exit(1);
  }
}

// Run migration if this file is executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
  migrateData();
}

export { migrateData };
