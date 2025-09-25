import SwiftUI

struct ProductCard: View {
    let product: Product
    let cart: CartManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ProductImageView(product: product)
            ProductInfoView(product: product, cart: cart)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(
            color: Color.black.opacity(0.05),
            radius: 2,
            x: 0,
            y: 1
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.systemGray5), lineWidth: 0.5)
        )
    }
}

// MARK: - Component Views

struct ProductImageView: View {
    let product: Product
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            ProductImageBackground(product: product)
            ProductDiscountBadge(product: product)
            ProductAvailabilityIndicator(available: product.available)
        }
    }
}

struct ProductImageBackground: View {
    let product: Product
    
    var body: some View {
        Group {
            if let imageUrlString = product.imageUrl, 
               let url = URL(string: imageUrlString), 
               !imageUrlString.isEmpty {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                }
                .frame(height: 140)
                .clipped()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 140)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 30))
                            .foregroundColor(.gray)
                    )
            }
        }
    }
}

struct ProductDiscountBadge: View {
    let product: Product
    
    var body: some View {
        if let sale = product.salePrice, sale < product.price {
            let discount = Int(((product.price - sale) / product.price) * 100)
            VStack(alignment: .leading, spacing: 0) {
                Text("-\(discount)%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            .padding(8)
        }
    }
}

struct ProductAvailabilityIndicator: View {
    let available: Bool
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Circle()
                    .fill(available ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
            }
            Spacer()
        }
        .padding(8)
    }
}

struct ProductInfoView: View {
    let product: Product
    let cart: CartManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ProductTitleView(product: product)
            ProductDescriptionView(product: product)
            ProductPriceAndActionView(product: product, cart: cart)
        }
        .padding(12)
    }
}

struct ProductTitleView: View {
    let product: Product
    
    var body: some View {
        Text(product.name)
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.black)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
    }
}

struct ProductDescriptionView: View {
    let product: Product
    
    var body: some View {
        if let shortDesc = product.shortDesc, !shortDesc.isEmpty {
            Text(shortDesc)
                .font(.caption)
                .foregroundColor(.black)
                .lineLimit(1)
        }
    }
}

struct ProductPriceAndActionView: View {
    let product: Product
    let cart: CartManager
    
    var body: some View {
        HStack {
            ProductPriceView(product: product)
            Spacer()
            ProductActionButton(product: product, cart: cart)
        }
    }
}

struct ProductPriceView: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let sale = product.salePrice {
                Text(String(format: "£%.2f", sale))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Text(String(format: "£%.2f", product.price))
                    .font(.caption)
                    .strikethrough()
                    .foregroundColor(.black)
            } else {
                Text(String(format: "£%.2f", product.price))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
            }
        }
    }
}

struct ProductActionButton: View {
    let product: Product
    let cart: CartManager
    
    var body: some View {
        if product.available {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    cart.add(product: product)
                }
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(Color.blue)
                    .clipShape(Circle())
            }
            .scaleEffect(1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: cart.items.count)
        } else {
            Text("Out")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.red)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.red.opacity(0.1))
                .clipShape(Capsule())
        }
    }
}

#Preview {
    ProductCard(
        product: Product(
            id: "1",
            name: "Margherita Pizza",
            shortDesc: "Classic tomato and mozzarella",
            fullDesc: nil,
            category: "Pizza",
            tags: nil,
            price: 12.99,
            salePrice: 9.99,
            imageUrl: nil,
            images: nil,
            available: true,
            maxOrderQty: nil,
            sortOrder: nil,
            priceWithTax: nil,
            salePriceWithTax: nil
        ),
        cart: CartManager.shared
    )
    .padding()
}
