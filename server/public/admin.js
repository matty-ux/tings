const api = '/api/admin/products';
let _allProducts = [];
let currentEditId = null;

async function refresh() {
  try {
    const res = await fetch('/api/admin/products');
    const data = await res.json();
    _allProducts = data;
    populateCategoryOptions(data);
    updateStats(data);
    render();
  } catch (error) {
    console.error('Failed to fetch products:', error);
    toast('Error loading products');
  }
}

function updateStats(products) {
  document.getElementById('productCount').textContent = products.length;
  document.getElementById('activeProducts').textContent = products.filter(p => p.active).length;
  
  // Update order count
  fetch('/api/admin/orders')
    .then(res => res.json())
    .then(orders => {
      document.getElementById('orderCount').textContent = orders.length;
    })
    .catch(() => {
      document.getElementById('orderCount').textContent = '-';
    });
}

function render() {
  const tbody = document.querySelector('#table tbody');
  tbody.innerHTML = '';
  const q = (document.getElementById('search').value || '').toLowerCase();
  const cat = document.getElementById('categoryFilter').value;
  const avail = document.getElementById('availFilter').value;
  
  const data = _allProducts.filter(p => {
    const inText = (p.name + ' ' + (p.sku||'') + ' ' + (p.tags||[]).join(' ')).toLowerCase().includes(q);
    const inCat = !cat || (p.category||'') === cat;
    const inAvail = !avail || (avail === 'in' ? p.available : !p.available);
    return inText && inCat && inAvail;
  });
  
  for (const p of data) {
    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td>
        <strong>${p.name}</strong>
        <div class="hint">${p.sku || 'No SKU'} ${p.category ? '• ' + p.category : ''}</div>
        ${p.tags && p.tags.length ? '<div>' + p.tags.map(t => '<span class="pill">' + t + '</span>').join('') + '</div>' : ''}
      </td>
      <td>
        <strong>£${p.price}</strong>
        ${p.salePrice ? '<div class="hint">Sale: £' + p.salePrice + '</div>' : ''}
      </td>
      <td>
        <span class="badge">${p.stockQty || 0} in stock</span>
      </td>
      <td>
        <div class="inline">
          <label><input type="checkbox" ${p.available ? 'checked' : ''} onchange="update('${p.id}',{available:this.checked})"> Available</label>
          <label><input type="checkbox" ${p.active ? 'checked' : ''} onchange="update('${p.id}',{active:this.checked})"> Active</label>
        </div>
      </td>
      <td>
        <button class="btn" onclick="openEdit('${p.id}')">Edit</button>
        <button class="btn" onclick="del('${p.id}')" style="background: #dc2626; color: white; border-color: #dc2626;">Delete</button>
      </td>
    `;
    tbody.appendChild(tr);
  }
}

function openModal() { openModalForCreate(); }

function openModalForCreate() {
  currentEditId = null;
  document.getElementById('modalTitle').textContent = 'New Product';
  document.getElementById('submitBtn').textContent = 'Create';
  document.getElementById('productForm').reset();
  document.getElementById('available').checked = true;
  document.getElementById('active').checked = true;
  document.getElementById('modal').style.display = 'flex';
}

function openEdit(id) {
  const p = _allProducts.find(x => x.id === id);
  if (!p) return;
  currentEditId = id;
  document.getElementById('modalTitle').textContent = 'Edit Product';
  document.getElementById('submitBtn').textContent = 'Save';
  const form = document.getElementById('productForm');
  form.querySelector('#sku').value = p.sku || '';
  form.querySelector('#sortOrder').value = p.sortOrder ?? 0;
  form.querySelector('#name').value = p.name || '';
  form.querySelector('#category').value = p.category || '';
  form.querySelector('#tags').value = (p.tags||[]).join(', ');
  form.querySelector('#shortDesc').value = p.shortDesc || '';
  form.querySelector('#fullDesc').value = p.fullDesc || '';
  form.querySelector('#price').value = p.price ?? '';
  form.querySelector('#salePrice').value = p.salePrice ?? '';
  form.querySelector('#costPrice').value = p.costPrice ?? '';
  form.querySelector('#taxRate').value = p.taxRate ?? 0;
  form.querySelector('#imageUrl').value = p.imageUrl || '';
  form.querySelector('#stockQty').value = p.stockQty ?? 0;
  form.querySelector('#maxOrderQty').value = p.maxOrderQty ?? 0;
  form.querySelector('#prepTimeMins').value = p.prepTimeMins ?? 0;
  form.querySelector('#available').checked = !!p.available;
  form.querySelector('#active').checked = p.active !== false;
  document.getElementById('modal').style.display = 'flex';
}

function closeModal() {
  document.getElementById('modal').style.display = 'none';
}

async function addProduct(e) {
  e?.preventDefault?.();
  const form = document.getElementById('productForm');
  const get = id => form.querySelector('#'+id);
  const name = get('name').value;
  const price = parseFloat(get('price').value);
  if (!name || Number.isNaN(price)) return alert('Name and price required');
  
  const payload = {
    sku: get('sku').value,
    name,
    shortDesc: get('shortDesc').value,
    fullDesc: get('fullDesc').value,
    category: get('category').value,
    tags: get('tags').value.split(',').map(s=>s.trim()).filter(Boolean),
    price,
    salePrice: (() => { const v = get('salePrice').value; return v === '' ? null : (Number.isNaN(parseFloat(v)) ? null : parseFloat(v)); })(),
    imageUrl: get('imageUrl').value,
    images: [],
    costPrice: (() => { const v = get('costPrice').value; return v === '' ? 0 : (Number.isNaN(parseFloat(v)) ? 0 : parseFloat(v)); })(),
    available: get('available').checked,
    taxRate: (() => { const v = get('taxRate').value; return v === '' ? 0 : (Number.isNaN(parseFloat(v)) ? 0 : parseFloat(v)); })(),
    stockQty: (() => { const v = get('stockQty').value; return v === '' ? 0 : (Number.isNaN(parseInt(v)) ? 0 : parseInt(v)); })(),
    maxOrderQty: (() => { const v = get('maxOrderQty').value; return v === '' ? 0 : (Number.isNaN(parseInt(v)) ? 0 : parseInt(v)); })(),
    prepTimeMins: (() => { const v = get('prepTimeMins').value; return v === '' ? 0 : (Number.isNaN(parseInt(v)) ? 0 : parseInt(v)); })(),
    active: get('active').checked,
    sortOrder: (() => { const v = get('sortOrder').value; return v === '' ? 0 : (Number.isNaN(parseInt(v)) ? 0 : parseInt(v)); })()
  };
  
  try {
    if (!currentEditId) {
      const res = await fetch('/api/admin/products', { method: 'POST', headers: {'Content-Type':'application/json'}, body: JSON.stringify(payload) });
      if (!res.ok) throw new Error('Create failed');
      toast('Product created successfully');
    } else {
      const res = await fetch(`/api/admin/products/${currentEditId}`, { method: 'PUT', headers: {'Content-Type':'application/json'}, body: JSON.stringify(payload) });
      if (!res.ok) throw new Error('Save failed');
      toast('Product saved successfully');
    }
  } catch (e) {
    console.error(e);
    toast('Error saving product');
    return;
  }
  closeModal();
  form.reset();
  refresh();
}

async function update(id, payload) {
  try {
    const res = await fetch(`/api/admin/products/${id}`, { method: 'PUT', headers: {'Content-Type':'application/json'}, body: JSON.stringify(payload) });
    if (!res.ok) throw new Error('Save failed');
    toast('Updated');
    refresh();
  } catch (e) {
    console.error(e);
    toast('Error updating');
  }
}

async function del(id) {
  if (!confirm('Delete this product?')) return;
  try {
    await fetch(`/api/admin/products/${id}`, { method: 'DELETE' });
    toast('Product deleted');
    refresh();
  } catch (e) {
    console.error(e);
    toast('Error deleting product');
  }
}

function populateCategoryOptions(data) {
  const sel = document.getElementById('categoryFilter');
  const current = sel.value;
  const cats = Array.from(new Set((data||[]).map(p => p.category).filter(Boolean))).sort();
  sel.innerHTML = '<option value="">All categories</option>' + cats.map(c => `<option value="${c}">${c}</option>`).join('');
  if (Array.from(sel.options).some(o => o.value === current)) sel.value = current;
}

function toggleTheme() {
  const next = (document.documentElement.getAttribute('data-theme') === 'dark') ? '' : 'dark';
  if (next) document.documentElement.setAttribute('data-theme','dark'); 
  else document.documentElement.removeAttribute('data-theme');
  localStorage.setItem('theme', next);
}

function toast(msg) {
  const el = document.getElementById('toast');
  el.textContent = msg;
  el.style.display = 'block';
  setTimeout(() => { el.style.display = 'none'; }, 2000);
}

// Initialize
document.addEventListener('DOMContentLoaded', function() {
  // Load theme
  const t = localStorage.getItem('theme');
  if (t === 'dark') document.documentElement.setAttribute('data-theme','dark');
  
  // Update uptime every second
  setInterval(() => {
    fetch('/health')
      .then(res => res.json())
      .then(data => {
        document.getElementById('uptime').textContent = Math.floor(data.uptime);
      })
      .catch(() => {});
  }, 1000);
  
  // Load data
  refresh();
});

// Event listeners
document.getElementById('search').addEventListener('input', render);
document.getElementById('categoryFilter').addEventListener('change', render);
document.getElementById('availFilter').addEventListener('change', render);
