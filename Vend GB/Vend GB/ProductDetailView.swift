import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @StateObject private var cart = CartManager.shared
    @State private var quantity: Int = 1
    @State private var showingAddedToCart = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Product Image
                AsyncImage(url: URL(string: product.imageUrl ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                        )
                }
                .frame(height: 300)
                .clipped()
                
                VStack(alignment: .leading, spacing: 20) {
                    // Product Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(product.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                if let category = product.category {
                                    Text(category)
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                }
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                if let salePrice = product.salePrice, salePrice < product.price {
                                    Text("£\(String(format: "%.2f", product.price))")
                                        .font(.subheadline)
                                        .strikethrough()
                                        .foregroundColor(.secondary)
                                    
                                    Text("£\(String(format: "%.2f", salePrice))")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.red)
                                } else {
                                    Text("£\(String(format: "%.2f", product.price))")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                }
                                
                                if let maxOrderQty = product.maxOrderQty {
                                    Text("Max: \(maxOrderQty)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        // Availability Status
                        HStack {
                            Circle()
                                .fill(product.available ? Color.green : Color.red)
                                .frame(width: 8, height: 8)
                            
                            Text(product.available ? "In Stock" : "Out of Stock")
                                .font(.subheadline)
                                .foregroundColor(product.available ? .green : .red)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Tags
                    if let tags = product.tags, !tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.gray.opacity(0.2))
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    // Short Description
                    if let shortDesc = product.shortDesc, !shortDesc.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text(shortDesc)
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Full Description
                    if let fullDesc = product.fullDesc, !fullDesc.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Details")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text(fullDesc)
                                .font(.body)
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Product Information
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Product Information")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 8) {
                            InfoRowView(title: "Product ID", value: product.id)
                            
                            if let category = product.category {
                                InfoRowView(title: "Category", value: category)
                            }
                            
                            InfoRowView(
                                title: "Price",
                                value: product.salePrice != nil ? 
                                    "£\(String(format: "%.2f", product.salePrice!)) (was £\(String(format: "%.2f", product.price)))" :
                                    "£\(String(format: "%.2f", product.price))"
                            )
                            
                            if let maxOrderQty = product.maxOrderQty {
                                InfoRowView(title: "Maximum Order Quantity", value: "\(maxOrderQty)")
                            }
                            
                            InfoRowView(
                                title: "Availability",
                                value: product.available ? "In Stock" : "Out of Stock"
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Quantity and Add to Cart
                    VStack(spacing: 16) {
                        HStack {
                            Text("Quantity")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            HStack(spacing: 16) {
                                Button(action: {
                                    if quantity > 1 {
                                        quantity -= 1
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(quantity > 1 ? .blue : .gray)
                                }
                                .disabled(quantity <= 1)
                                
                                Text("\(quantity)")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .frame(minWidth: 30)
                                
                                Button(action: {
                                    if let maxQty = product.maxOrderQty {
                                        if quantity < maxQty {
                                            quantity += 1
                                        }
                                    } else {
                                        quantity += 1
                                    }
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(canIncreaseQuantity ? .blue : .gray)
                                }
                                .disabled(!canIncreaseQuantity)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Add to Cart Button
                        Button(action: addToCart) {
                            HStack {
                                Image(systemName: "cart.badge.plus")
                                    .font(.title3)
                                
                                Text("Add to Cart - £\(String(format: "%.2f", totalPrice))")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(product.available ? Color.blue : Color.gray)
                            )
                        }
                        .disabled(!product.available)
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 20)
                }
            }
            }
            
            // Floating Basket Button
            if !cart.items.isEmpty {
                FloatingBasketButton()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Close") {
                    dismiss()
                }
            }
        }
        .alert("Added to Cart", isPresented: $showingAddedToCart) {
            Button("OK") { }
        } message: {
            Text("\(quantity) x \(product.name) added to your cart")
        }
    }
    
    private var canIncreaseQuantity: Bool {
        if let maxQty = product.maxOrderQty {
            return quantity < maxQty
        }
        return true
    }
    
    private var totalPrice: Double {
        let price = product.salePrice ?? product.price
        return price * Double(quantity)
    }
    
    private func addToCart() {
        cart.add(product: product, quantity: quantity)
        showingAddedToCart = true
    }
}

struct InfoRowView: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationView {
        ProductDetailView(product: Product(
            id: "1",
            name: "Fish & Chips",
            shortDesc: "Classic British fish and chips with mushy peas",
            fullDesc: "Our signature fish and chips features fresh cod in crispy beer batter, served with hand-cut chips, mushy peas, and tartar sauce. A true British classic that's been perfected over generations.",
            category: "Main Course",
            tags: ["Popular", "Traditional", "Seafood"],
            price: 12.99,
            salePrice: 9.99,
            imageUrl: "https://example.com/fish-chips.jpg",
            images: ["https://example.com/fish-chips-1.jpg", "https://example.com/fish-chips-2.jpg"],
            available: true,
            maxOrderQty: 5,
            sortOrder: 1
        ))
    }
}
