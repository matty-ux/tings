import SwiftUI

struct FloatingBasketButton: View {
    @StateObject private var cart = CartManager.shared
    @State private var showingBasket = false
    @State private var bounceAnimation = false
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                Button(action: {
                    showingBasket = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "cart.fill")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text("\(cart.items.count)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("item\(cart.items.count == 1 ? "" : "s")")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.black)
                            .shadow(
                                color: Color.black.opacity(0.3),
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(bounceAnimation ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: bounceAnimation)
                .onChange(of: cart.items.count) { _, newCount in
                    if newCount > 0 {
                        // Trigger bounce animation when items are added
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            bounceAnimation = true
                        }
                        
                        // Reset animation after a short delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                bounceAnimation = false
                            }
                        }
                    }
                }
                .padding(.trailing, 20)
                .padding(.bottom, 100) // Position above the bottom navigation
            }
        }
        .sheet(isPresented: $showingBasket) {
            BasketView()
        }
    }
}

struct BasketView: View {
    @StateObject private var cart = CartManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if cart.items.isEmpty {
                    // Empty basket state
                    VStack(spacing: 20) {
                        Image(systemName: "cart")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("Your basket is empty")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Add some delicious items to get started!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Continue Shopping") {
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Basket with items
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(cart.items) { item in
                                BasketItemRow(item: item, cart: cart)
                            }
                        }
                        .padding()
                    }
                    
                    // Bottom section with total and checkout
                    VStack(spacing: 16) {
                        Divider()
                        
                        // Total
                        HStack {
                            Text("Total")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Text(String(format: "£%.2f", cart.total))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal)
                        
                        // Checkout button
                        NavigationLink(destination: CheckoutView()) {
                            HStack {
                                Image(systemName: "creditcard.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                
                                Text("Checkout")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                    .background(Color(.systemBackground))
                }
            }
            .navigationTitle("Basket")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct BasketItemRow: View {
    let item: CartItem
    let cart: CartManager
    
    var body: some View {
        HStack(spacing: 12) {
            // Product image
            AsyncImage(url: URL(string: item.product.imageUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                    )
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Product info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.product.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                Text(String(format: "£%.2f", item.product.salePrice ?? item.product.price))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Quantity controls
            HStack(spacing: 8) {
                Button(action: {
                    cart.changeQuantity(for: item.product.id, by: -1)
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
                
                Text("\(item.quantity)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .frame(minWidth: 20)
                
                Button(action: {
                    cart.changeQuantity(for: item.product.id, by: 1)
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.green)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Item total
            Text(String(format: "£%.2f", Double(item.quantity) * (item.product.salePrice ?? item.product.price)))
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(width: 60, alignment: .trailing)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    FloatingBasketButton()
}
