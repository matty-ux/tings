import express from 'express';
import cors from 'cors';
import { nanoid } from 'nanoid';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { initializeDatabase, query } from './database.js';

const app = express();
const port = process.env.PORT || 3001;

app.use(cors());
app.use(express.json());

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Initialize database on startup
async function initializeApp() {
  try {
    await initializeDatabase();
    console.log('✅ Database initialized successfully');
  } catch (error) {
    console.error('❌ Failed to initialize database:', error);
    process.exit(1);
  }
}

// Helper function to convert database product to API format
function dbProductToApi(product) {
  return {
    id: product.id.toString(),
    sku: product.sku || '',
    name: product.name,
    shortDesc: product.short_desc || '',
    fullDesc: product.full_desc || '',
    category: product.category || '',
    tags: product.tags || [],
    price: parseFloat(product.price),
    salePrice: product.sale_price ? parseFloat(product.sale_price) : null,
    taxRate: product.tax_rate || 0,
    costPrice: product.cost_price ? parseFloat(product.cost_price) : null,
    available: product.available !== false,
    stockQty: product.stock_qty || 0,
    maxOrderQty: product.max_order_qty || 5,
    prepTimeMins: product.prep_time_mins || 15,
    imageUrl: product.image_url || '',
    images: product.images || [],
    active: product.active !== false,
    sortOrder: product.sort_order || 0,
    createdAt: product.created_at,
    updatedAt: product.updated_at
  };
}

// Helper function to convert database order to API format
function dbOrderToApi(order) {
  return {
    id: order.order_id,
    customerName: order.customer_name,
    customerPhone: order.customer_phone || '',
    customerEmail: order.customer_email || '',
    items: order.items || [],
    total: parseFloat(order.total),
    status: order.status || 'new',
    deliveryAddress: order.delivery_address || '',
    specialInstructions: order.special_instructions || '',
    createdAt: order.created_at,
    updatedAt: order.updated_at
  };
}

// Public API (client apps) - hides costPrice
app.get('/api/products', async (req, res) => {
  try {
    const result = await query(`
      SELECT * FROM products 
      WHERE active = true 
      ORDER BY sort_order ASC, name ASC
    `);
    
    const products = result.rows.map(dbProductToApi);
    res.json(products);
  } catch (error) {
    console.error('Error fetching products:', error);
    res.status(500).json({ error: 'Failed to fetch products' });
  }
});

// Admin API - full access including costPrice
app.get('/api/admin/products', async (req, res) => {
  try {
    const result = await query(`
      SELECT * FROM products 
      ORDER BY sort_order ASC, name ASC
    `);
    
    const products = result.rows.map(dbProductToApi);
    res.json(products);
  } catch (error) {
    console.error('Error fetching products:', error);
    res.status(500).json({ error: 'Failed to fetch products' });
  }
});

// Create new product
app.post('/api/admin/products', async (req, res) => {
  try {
    const {
      sku, name, shortDesc, fullDesc, category, tags,
      price, salePrice, imageUrl, images, costPrice, available,
      taxRate, stockQty, maxOrderQty, prepTimeMins, active, sortOrder
    } = req.body;
    
    if (typeof name !== 'string' || typeof price !== 'number') {
      return res.status(400).json({ error: 'Invalid product payload' });
    }
    
    const result = await query(`
      INSERT INTO products (
        sku, name, short_desc, full_desc, category, tags,
        price, sale_price, image_url, images, cost_price, available,
        tax_rate, stock_qty, max_order_qty, prep_time_mins, active, sort_order
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18)
      RETURNING *
    `, [
      sku || '', name, shortDesc || '', fullDesc || '', category || '', JSON.stringify(tags || []),
      price, salePrice || null, imageUrl || '', JSON.stringify(images || []), costPrice || null, available !== false,
      taxRate || 0, stockQty || 0, maxOrderQty || 5, prepTimeMins || 15, active !== false, sortOrder || 0
    ]);
    
    const product = dbProductToApi(result.rows[0]);
    res.status(201).json(product);
  } catch (error) {
    console.error('Error creating product:', error);
    res.status(500).json({ error: 'Failed to create product' });
  }
});

// Update product
app.put('/api/admin/products/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const {
      sku, name, shortDesc, fullDesc, category, tags,
      price, salePrice, imageUrl, images, costPrice, available,
      taxRate, stockQty, maxOrderQty, prepTimeMins, active, sortOrder
    } = req.body;
    
    const result = await query(`
      UPDATE products SET
        sku = $2, name = $3, short_desc = $4, full_desc = $5, category = $6, tags = $7,
        price = $8, sale_price = $9, image_url = $10, images = $11, cost_price = $12, available = $13,
        tax_rate = $14, stock_qty = $15, max_order_qty = $16, prep_time_mins = $17, active = $18, sort_order = $19,
        updated_at = NOW()
      WHERE id = $1
      RETURNING *
    `, [
      id, sku || '', name, shortDesc || '', fullDesc || '', category || '', JSON.stringify(tags || []),
      price, salePrice || null, imageUrl || '', JSON.stringify(images || []), costPrice || null, available !== false,
      taxRate || 0, stockQty || 0, maxOrderQty || 5, prepTimeMins || 15, active !== false, sortOrder || 0
    ]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Product not found' });
    }
    
    const product = dbProductToApi(result.rows[0]);
    res.json(product);
  } catch (error) {
    console.error('Error updating product:', error);
    res.status(500).json({ error: 'Failed to update product' });
  }
});

// Delete product
app.delete('/api/admin/products/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    const result = await query('DELETE FROM products WHERE id = $1 RETURNING *', [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Product not found' });
    }
    
    res.json({ message: 'Product deleted successfully' });
  } catch (error) {
    console.error('Error deleting product:', error);
    res.status(500).json({ error: 'Failed to delete product' });
  }
});

// Orders API
app.get('/api/admin/orders', async (req, res) => {
  try {
    const result = await query(`
      SELECT * FROM orders 
      ORDER BY created_at DESC
    `);
    
    const orders = result.rows.map(dbOrderToApi);
    res.json(orders);
  } catch (error) {
    console.error('Error fetching orders:', error);
    res.status(500).json({ error: 'Failed to fetch orders' });
  }
});

// Create new order
app.post('/api/orders', async (req, res) => {
  try {
    const {
      customerName, customerPhone, customerEmail, items, total,
      deliveryAddress, specialInstructions
    } = req.body;
    
    if (!customerName || !items || !Array.isArray(items) || items.length === 0) {
      return res.status(400).json({ error: 'Invalid order payload' });
    }
    
    const orderId = nanoid();
    
    const result = await query(`
      INSERT INTO orders (
        order_id, customer_name, customer_phone, customer_email, items, total,
        delivery_address, special_instructions, status
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      RETURNING *
    `, [
      orderId, customerName, customerPhone || '', customerEmail || '',
      JSON.stringify(items), total || 0, deliveryAddress || '', specialInstructions || '', 'new'
    ]);
    
    const order = dbOrderToApi(result.rows[0]);
    res.status(201).json(order);
  } catch (error) {
    console.error('Error creating order:', error);
    res.status(500).json({ error: 'Failed to create order' });
  }
});

// Update order status
app.put('/api/admin/orders/:id/status', async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;
    
    const validStatuses = ['new', 'accepted', 'preparing', 'out_for_delivery', 'delivered', 'cancelled'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ error: 'Invalid status' });
    }
    
    const result = await query(`
      UPDATE orders SET status = $2, updated_at = NOW()
      WHERE order_id = $1
      RETURNING *
    `, [id, status]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Order not found' });
    }
    
    const order = dbOrderToApi(result.rows[0]);
    res.json(order);
  } catch (error) {
    console.error('Error updating order status:', error);
    res.status(500).json({ error: 'Failed to update order status' });
  }
});

// Delete order
app.delete('/api/admin/orders/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    const result = await query('DELETE FROM orders WHERE order_id = $1 RETURNING *', [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Order not found' });
    }
    
    res.json({ message: 'Order deleted successfully' });
  } catch (error) {
    console.error('Error deleting order:', error);
    res.status(500).json({ error: 'Failed to delete order' });
  }
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// Admin UI - serve the new admin panel
app.get('/admin', (req, res) => {
  console.log('Admin route accessed');
  res.sendFile(path.join(__dirname, 'public', 'admin.html'));
});

// Keep the old admin route as backup
app.get('/admin-old', (req, res) => {
  console.log('Old admin route accessed');
  res.send(`
<!doctype html>
<html>
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Vend GB Admin</title>
    <style>
      body { font-family: system-ui; margin: 0; padding: 20px; background: #f5f5f5; }
      .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
      h1 { color: #333; margin-bottom: 20px; }
      .status { padding: 10px; background: #e8f5e8; border: 1px solid #4caf50; border-radius: 4px; margin-bottom: 20px; }
      .endpoints { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; }
      .endpoint { padding: 15px; border: 1px solid #ddd; border-radius: 4px; }
      .endpoint h3 { margin-top: 0; color: #555; }
      .endpoint a { display: inline-block; margin: 5px 10px 5px 0; padding: 8px 12px; background: #007bff; color: white; text-decoration: none; border-radius: 4px; font-size: 14px; }
      .endpoint a:hover { background: #0056b3; }
    </style>
  </head>
  <body>
    <div class="container">
      <h1>🍕 Vend GB Admin Dashboard</h1>
      <div class="status">
        <strong>✅ Server Status:</strong> Running and healthy
      </div>
      <div class="endpoints">
        <div class="endpoint">
          <h3>📦 Products</h3>
          <a href="/api/admin/products" target="_blank">View All Products</a>
          <a href="/api/products" target="_blank">Public Products API</a>
        </div>
        <div class="endpoint">
          <h3>📋 Orders</h3>
          <a href="/api/admin/orders" target="_blank">View All Orders</a>
        </div>
        <div class="endpoint">
          <h3>❤️ Health</h3>
          <a href="/health" target="_blank">Health Check</a>
        </div>
      </div>
    </div>
  </body>
</html>
  `);
});

// Serve static files after custom routes
app.use(express.static('public'));

// Start server
async function startServer() {
  await initializeApp();
  
  app.listen(port, () => {
    console.log(`🚀 Vend GB Admin Server running on port ${port}`);
    console.log(`📊 Environment: ${process.env.NODE_ENV || 'development'}`);
    console.log(`🌐 Admin Panel: http://localhost:${port}/admin`);
    console.log(`❤️ Health Check: http://localhost:${port}/health`);
  });
}

startServer().catch(error => {
  console.error('Failed to start server:', error);
  process.exit(1);
});
