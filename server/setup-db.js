import { initializeDatabase, query } from './database.js';

async function setupDatabase() {
  try {
    console.log('🚀 Setting up Vend GB database...');
    
    // Initialize database (creates tables)
    await initializeDatabase();
    
    // Check if we have any data
    const productCount = await query('SELECT COUNT(*) FROM products');
    const orderCount = await query('SELECT COUNT(*) FROM orders');
    
    console.log(`📊 Database setup complete!`);
    console.log(`   - Products: ${productCount.rows[0].count}`);
    console.log(`   - Orders: ${orderCount.rows[0].count}`);
    
    if (productCount.rows[0].count === '0') {
      console.log('📝 Database is empty. You can now:');
      console.log('   1. Run the migration script: node migrate.js');
      console.log('   2. Or start with empty data and add products via the admin panel');
    }
    
  } catch (error) {
    console.error('❌ Database setup failed:', error.message);
    
    if (error.code === 'ECONNREFUSED') {
      console.log('\n💡 To fix this:');
      console.log('   1. Add PostgreSQL to Railway: https://railway.app/dashboard');
      console.log('   2. Or install PostgreSQL locally and set LOCAL_DATABASE_URL');
    }
    
    process.exit(1);
  }
}

setupDatabase();
