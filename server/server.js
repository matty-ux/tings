import express from 'express';
import cors from 'cors';
import { nanoid } from 'nanoid';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const app = express();
const port = process.env.PORT || 3001;

app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// Persistence setup
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const dataDir = path.join(__dirname, 'data');
const dataFile = path.join(dataDir, 'products.json');
const ordersFile = path.join(dataDir, 'orders.json');

function ensureDataDir() {
  if (!fs.existsSync(dataDir)) {
    fs.mkdirSync(dataDir, { recursive: true });
  }
}

function loadProducts() {
  try {
    ensureDataDir();
    if (!fs.existsSync(dataFile)) return null;
    const raw = fs.readFileSync(dataFile, 'utf8');
    return JSON.parse(raw);
  } catch (e) {
    console.error('Failed to load products.json:', e);
    return null;
  }
}

function saveProducts(products) {
  try {
    ensureDataDir();
    fs.writeFileSync(dataFile, JSON.stringify(products, null, 2));
  } catch (e) {
    console.error('Failed to save products.json:', e);
  }
}

function loadOrders() {
  try {
    ensureDataDir();
    if (!fs.existsSync(ordersFile)) return null;
    const raw = fs.readFileSync(ordersFile, 'utf8');
    return JSON.parse(raw);
  } catch (e) {
    console.error('Failed to load orders.json:', e);
    return null;
  }
}

function saveOrders(orders) {
  try {
    ensureDataDir();
    fs.writeFileSync(ordersFile, JSON.stringify(orders, null, 2));
  } catch (e) {
    console.error('Failed to save orders.json:', e);
  }
}

// In-memory store for products (loaded from disk if available)
let products = loadProducts() ?? [
  {
    id: nanoid(), sku: 'PZ-MARG',
    name: 'Margherita Pizza', shortDesc: 'Classic cheese and tomato', fullDesc: '',
    category: 'Pizza', tags: ['vegetarian'],
    price: 8.99, salePrice: null, taxRate: 0,
    costPrice: 4.20,
    available: true, stockQty: 100, maxOrderQty: 5, prepTimeMins: 15,
    imageUrl: '', images: [],
    active: true, sortOrder: 0,
    createdAt: new Date().toISOString(), updatedAt: new Date().toISOString()
  },
  {
    id: nanoid(), sku: 'PZ-PEPP',
    name: 'Pepperoni Pizza', shortDesc: 'Spicy pepperoni', fullDesc: '',
    category: 'Pizza', tags: ['spicy'],
    price: 10.49, salePrice: 9.49, taxRate: 0,
    costPrice: 5.10,
    available: true, stockQty: 100, maxOrderQty: 5, prepTimeMins: 15,
    imageUrl: '', images: [],
    active: true, sortOrder: 1,
    createdAt: new Date().toISOString(), updatedAt: new Date().toISOString()
  },
  {
    id: nanoid(), sku: 'SD-GBRD',
    name: 'Garlic Bread', shortDesc: 'Buttery garlic bread', fullDesc: '',
    category: 'Sides', tags: [],
    price: 4.25, salePrice: null, taxRate: 0,
    costPrice: 1.60,
    available: true, stockQty: 100, maxOrderQty: 10, prepTimeMins: 5,
    imageUrl: '', images: [],
    active: true, sortOrder: 2,
    createdAt: new Date().toISOString(), updatedAt: new Date().toISOString()
  }
];
// Save initial products if file didn't exist
if (!loadProducts()) {
  saveProducts(products);
}

// Ensure any loaded products have the new fields
products = products.map(p => ({
  id: p.id ?? nanoid(),
  sku: p.sku ?? '',
  name: p.name,
  shortDesc: p.shortDesc ?? '',
  fullDesc: p.fullDesc ?? '',
  category: p.category ?? '',
  tags: Array.isArray(p.tags) ? p.tags : [],
  price: typeof p.price === 'number' ? p.price : 0,
  salePrice: p.salePrice ?? null,
  taxRate: typeof p.taxRate === 'number' ? p.taxRate : 0,
  imageUrl: p.imageUrl ?? '',
  images: Array.isArray(p.images) ? p.images : [],
  costPrice: typeof p.costPrice === 'number' ? p.costPrice : 0,
  available: Boolean(p.available),
  stockQty: typeof p.stockQty === 'number' ? p.stockQty : 0,
  maxOrderQty: typeof p.maxOrderQty === 'number' ? p.maxOrderQty : 0,
  prepTimeMins: typeof p.prepTimeMins === 'number' ? p.prepTimeMins : 0,
  active: p.active !== undefined ? Boolean(p.active) : true,
  sortOrder: typeof p.sortOrder === 'number' ? p.sortOrder : 0,
  createdAt: p.createdAt ?? new Date().toISOString(),
  updatedAt: new Date().toISOString()
}));
saveProducts(products);

// Users storage
const usersFile = path.join(dataDir, 'users.json');

function loadUsers() {
  try {
    ensureDataDir();
    if (!fs.existsSync(usersFile)) return [];
    const raw = fs.readFileSync(usersFile, 'utf8');
    return JSON.parse(raw);
  } catch (e) {
    console.error('Failed to load users.json:', e);
    return [];
  }
}

function saveUsers(users) {
  try {
    ensureDataDir();
    fs.writeFileSync(usersFile, JSON.stringify(users, null, 2));
  } catch (e) {
    console.error('Failed to save users.json:', e);
  }
}

// In-memory store for users (loaded from disk if available)
let users = loadUsers();

// Orders store
let orders = loadOrders() ?? [
  {
    id: nanoid(),
    createdAt: new Date().toISOString(),
    status: 'new', // new, accepted, preparing, out_for_delivery, delivered, cancelled
    customer: { name: 'John Doe', phone: '+44 7700 900123' },
    address: {
      line1: '221B Baker Street',
      line2: '',
      city: 'London',
      postcode: 'NW1 6XE'
    },
    items: [
      { productId: products[0]?.id || '', name: products[0]?.name || 'Item', qty: 1, price: products[0]?.price || 9.99 },
      { productId: products[2]?.id || '', name: products[2]?.name || 'Item', qty: 2, price: products[2]?.price || 3.49 }
    ],
    notes: 'Leave at the door',
    total: 0
  }
];

// Compute totals if missing
orders = orders.map(o => ({
  ...o,
  total: typeof o.total === 'number' && o.total > 0 ? o.total : +(Array.isArray(o.items) ? o.items.reduce((s,i)=>s + (i.qty||0)*(i.price||0), 0) : 0).toFixed(2)
}));
saveOrders(orders);

// REST API
function toPublicProduct(p) {
  const {
    costPrice, taxRate, stockQty, prepTimeMins,
    active, createdAt, updatedAt, sku,
    ...pub
  } = p;
  // Compute tax-inclusive prices without exposing tax rate
  const finalPrice = typeof taxRate === 'number' ? +(p.price * (1 + taxRate/100)).toFixed(2) : p.price;
  const finalSale = p.salePrice != null ? +(p.salePrice * (1 + (taxRate||0)/100)).toFixed(2) : null;
  return {
    ...pub,
    price: p.price, // base price still provided
    salePrice: p.salePrice ?? null,
    priceWithTax: finalPrice,
    salePriceWithTax: finalSale,
  };
}

// Public API (client apps) - hides costPrice
app.get('/api/products', (req, res) => {
  res.json(products.map(toPublicProduct));
});

// Admin API - full access including costPrice
app.get('/api/admin/products', (req, res) => {
  res.json(products);
});

app.post('/api/admin/products', (req, res) => {
  const {
    sku, name, shortDesc, fullDesc, category, tags,
    price, salePrice, imageUrl, images, costPrice, available,
    taxRate, stockQty, maxOrderQty, prepTimeMins, active, sortOrder
  } = req.body;
  if (typeof name !== 'string' || typeof price !== 'number') {
    return res.status(400).json({ error: 'Invalid product payload' });
  }
  const product = {
    id: nanoid(),
    sku: typeof sku === 'string' ? sku : '',
    name,
    shortDesc: typeof shortDesc === 'string' ? shortDesc : '',
    fullDesc: typeof fullDesc === 'string' ? fullDesc : '',
    category: typeof category === 'string' ? category : '',
    tags: Array.isArray(tags) ? tags : [],
    price,
    salePrice: typeof salePrice === 'number' ? salePrice : null,
    imageUrl: typeof imageUrl === 'string' ? imageUrl : '',
    images: Array.isArray(images) ? images : [],
    costPrice: typeof costPrice === 'number' ? costPrice : 0,
    available: Boolean(available),
    taxRate: typeof taxRate === 'number' ? taxRate : 0,
    stockQty: typeof stockQty === 'number' ? stockQty : 0,
    maxOrderQty: typeof maxOrderQty === 'number' ? maxOrderQty : 0,
    prepTimeMins: typeof prepTimeMins === 'number' ? prepTimeMins : 0,
    active: active !== undefined ? Boolean(active) : true,
    sortOrder: typeof sortOrder === 'number' ? sortOrder : 0,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  };
  products.push(product);
  saveProducts(products);
  res.status(201).json(product);
});

app.put('/api/admin/products/:id', (req, res) => {
  const { id } = req.params;
  const idx = products.findIndex(p => p.id === id);
  if (idx === -1) return res.status(404).json({ error: 'Not found' });
  const {
    sku, name, shortDesc, fullDesc, category, tags,
    price, salePrice, imageUrl, images, costPrice, available,
    taxRate, stockQty, maxOrderQty, prepTimeMins, active, sortOrder
  } = req.body;
  products[idx] = {
    ...products[idx],
    ...(sku !== undefined ? { sku } : {}),
    ...(name !== undefined ? { name } : {}),
    ...(shortDesc !== undefined ? { shortDesc } : {}),
    ...(fullDesc !== undefined ? { fullDesc } : {}),
    ...(category !== undefined ? { category } : {}),
    ...(tags !== undefined ? { tags: Array.isArray(tags) ? tags : [] } : {}),
    ...(price !== undefined ? { price } : {}),
    ...(salePrice !== undefined ? { salePrice } : {}),
    ...(imageUrl !== undefined ? { imageUrl } : {}),
    ...(images !== undefined ? { images: Array.isArray(images) ? images : [] } : {}),
    ...(costPrice !== undefined ? { costPrice } : {}),
    ...(available !== undefined ? { available: Boolean(available) } : {}),
    ...(taxRate !== undefined ? { taxRate } : {}),
    ...(stockQty !== undefined ? { stockQty } : {}),
    ...(maxOrderQty !== undefined ? { maxOrderQty } : {}),
    ...(prepTimeMins !== undefined ? { prepTimeMins } : {}),
    ...(active !== undefined ? { active: Boolean(active) } : {}),
    ...(sortOrder !== undefined ? { sortOrder } : {}),
    updatedAt: new Date().toISOString()
  };
  saveProducts(products);
  res.json(products[idx]);
});

app.delete('/api/admin/products/:id', (req, res) => {
  const { id } = req.params;
  const before = products.length;
  products = products.filter(p => p.id !== id);
  if (products.length === before) return res.status(404).json({ error: 'Not found' });
  saveProducts(products);
  res.status(204).send();
});

// Orders Admin API
app.get('/api/admin/orders', (req, res) => {
  res.json(orders);
});

app.post('/api/admin/orders', (req, res) => {
  const { customer, address, items, notes } = req.body || {};
  const order = {
    id: nanoid(),
    createdAt: new Date().toISOString(),
    status: 'new',
    customer: customer || { name: '', phone: '' },
    address: address || { line1: '', line2: '', city: '', postcode: '' },
    items: Array.isArray(items) ? items : [],
    notes: notes || '',
    total: 0
  };
  order.total = +(order.items.reduce((s,i)=>s + (i.qty||0)*(i.price||0), 0)).toFixed(2);
  orders.unshift(order);
  saveOrders(orders);
  res.status(201).json(order);
});

app.put('/api/admin/orders/:id', (req, res) => {
  const { id } = req.params;
  const idx = orders.findIndex(o => o.id === id);
  if (idx === -1) return res.status(404).json({ error: 'Not found' });
  const { status, customer, address, items, notes } = req.body || {};
  const updated = {
    ...orders[idx],
    ...(status !== undefined ? { status } : {}),
    ...(customer !== undefined ? { customer } : {}),
    ...(address !== undefined ? { address } : {}),
    ...(items !== undefined ? { items } : {}),
    ...(notes !== undefined ? { notes } : {}),
  };
  updated.total = +(updated.items.reduce((s,i)=>s + (i.qty||0)*(i.price||0), 0)).toFixed(2);
  orders[idx] = updated;
  saveOrders(orders);
  res.json(orders[idx]);
});

app.delete('/api/admin/orders/:id', (req, res) => {
  const { id } = req.params;
  const before = orders.length;
  orders = orders.filter(o => o.id !== id);
  if (orders.length === before) return res.status(404).json({ error: 'Not found' });
  saveOrders(orders);
  res.status(204).send();
});

// Public Checkout (no payment): create order from basket
app.post('/api/checkout', (req, res) => {
  try {
    const { customer, address, items, notes } = req.body || {};
    if (!Array.isArray(items) || items.length === 0) {
      return res.status(400).json({ error: 'No items provided' });
    }
    const normalizedItems = items.map(it => {
      const product = products.find(p => p.id === it.productId);
      return {
        productId: it.productId,
        name: product?.name || it.name || 'Item',
        qty: Math.max(1, parseInt(it.qty || 1)),
        price: typeof product?.price === 'number' ? product.price : (typeof it.price === 'number' ? it.price : 0)
      };
    });
    const order = {
      id: nanoid(),
      createdAt: new Date().toISOString(),
      status: 'new',
      customer: {
        name: customer?.name || '',
        phone: customer?.phone || ''
      },
      address: {
        line1: address?.line1 || '',
        line2: address?.line2 || '',
        city: address?.city || '',
        postcode: address?.postcode || ''
      },
      items: normalizedItems,
      notes: notes || '',
      total: 0
    };
    order.total = +(order.items.reduce((s,i)=> s + (i.qty||0)*(i.price||0), 0)).toFixed(2);
    orders.unshift(order);
    saveOrders(orders);
    return res.status(201).json({ id: order.id });
  } catch (e) {
    console.error('Checkout error:', e);
    return res.status(500).json({ error: 'Checkout failed' });
  }
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// Admin UI
app.get('/admin', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Catch-all route for admin panel (handle client-side routing)
app.get('/admin/*', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// ===== USER AUTHENTICATION ROUTES =====

// User registration/login
app.post('/api/auth/login', (req, res) => {
  const { email, name, provider, providerId } = req.body;
  
  if (!email || !name || !provider) {
    return res.status(400).json({ error: 'Email, name, and provider are required' });
  }
  
  // Check if user exists
  let user = users.find(u => u.email === email);
  
  if (!user) {
    // Create new user
    user = {
      id: nanoid(),
      email,
      name,
      provider,
      providerId: providerId || nanoid(),
      profileImageURL: null,
      createdAt: new Date().toISOString(),
      lastLoginAt: new Date().toISOString()
    };
    users.push(user);
    saveUsers(users);
  } else {
    // Update last login
    user.lastLoginAt = new Date().toISOString();
    saveUsers(users);
  }
  
  res.json({
    user: {
      id: user.id,
      email: user.email,
      name: user.name,
      profileImageURL: user.profileImageURL,
      provider: user.provider
    },
    token: generateToken(user.id) // Simple token for demo
  });
});

// Get user profile
app.get('/api/auth/profile/:userId', (req, res) => {
  const { userId } = req.params;
  const user = users.find(u => u.id === userId);
  
  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }
  
  res.json({
    id: user.id,
    email: user.email,
    name: user.name,
    profileImageURL: user.profileImageURL,
    provider: user.provider,
    createdAt: user.createdAt,
    lastLoginAt: user.lastLoginAt
  });
});

// Update user profile
app.put('/api/auth/profile/:userId', (req, res) => {
  const { userId } = req.params;
  const { name, email, profileImageURL } = req.body;
  
  const user = users.find(u => u.id === userId);
  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }
  
  if (name) user.name = name;
  if (email) user.email = email;
  if (profileImageURL !== undefined) user.profileImageURL = profileImageURL;
  
  saveUsers(users);
  
  res.json({
    id: user.id,
    email: user.email,
    name: user.name,
    profileImageURL: user.profileImageURL,
    provider: user.provider
  });
});

// Simple token generation (in production, use JWT)
function generateToken(userId) {
  return `token_${userId}_${Date.now()}`;
}

// Duplicate admin routes removed - using the ones defined earlier

import os from 'os';

function getLocalLANAddresses() {
  const interfaces = os.networkInterfaces();
  const addrs = [];
  for (const key of Object.keys(interfaces)) {
    for (const info of interfaces[key] || []) {
      if (info.family === 'IPv4' && !info.internal) {
        addrs.push(info.address);
      }
    }
  }
  return addrs;
}

app.listen(port, '0.0.0.0', () => {
  const addrs = getLocalLANAddresses();
  console.log(`🚀 Vend GB Admin Server running on port ${port}`);
  console.log(`📊 Health check: http://localhost:${port}/health`);
  console.log(`🛠️  Admin panel: http://localhost:${port}/admin`);
  console.log(`📱 API endpoint: http://localhost:${port}/api/products`);
  
  if (process.env.NODE_ENV === 'development') {
    console.log(`\n📍 Local network access:`);
    for (const ip of addrs) {
      console.log(`- http://${ip}:${port}`);
    }
  }
  
  console.log(`\n🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
});
