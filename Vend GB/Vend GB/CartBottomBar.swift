import SwiftUI

struct CartBottomBar: View {
    @ObservedObject var cart: CartManager
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color(.systemGray4))
            
            HStack(spacing: 16) {
                // Cart icon with count
                ZStack {
                    Image(systemName: "cart.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                    
                    if !cart.items.isEmpty {
                        Text("\(cart.items.reduce(0) { $0 + $1.quantity })")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                            .background(Color.red)
                            .clipShape(Circle())
                            .offset(x: 12, y: -12)
                    }
                }
                .frame(width: 40, height: 40)
                .background(
                    LinearGradient(
                        colors: [Color.blue, Color.blue.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
                
                // Cart details
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(cart.items.count) item\(cart.items.count == 1 ? "" : "s")")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(String(format: "£%.2f", cart.total))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                // Checkout button
                NavigationLink(destination: CheckoutView()) {
                    HStack(spacing: 8) {
                        Text("Checkout")
                            .font(.system(size: 16, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [Color.green, Color.green.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: Color.green.opacity(0.3), radius: 4, x: 0, y: 2)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                Color(.systemBackground)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: -4)
            )
        }
    }
}

#Preview {
    CartBottomBar(cart: CartManager.shared)
        .padding()
}
