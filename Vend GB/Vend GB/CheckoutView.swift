import SwiftUI

struct CheckoutView: View {
    @StateObject private var cart = CartManager.shared
    @State private var name: String = ""
    @State private var phone: String = ""
    @State private var line1: String = ""
    @State private var line2: String = ""
    @State private var city: String = ""
    @State private var postcode: String = ""
    @State private var isSubmitting: Bool = false
    @State private var resultMessage: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "cart.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                    Text("Review Your Order")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.top, 20)
                
                // Basket Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Order Summary")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Spacer()
                        Text("\(cart.items.count) item\(cart.items.count == 1 ? "" : "s")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 12) {
                        ForEach(cart.items) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.product.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text("Qty: \(item.quantity)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text(String(format: "£%.2f", Double(item.quantity) * (item.product.salePrice ?? item.product.price)))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            .padding(.vertical, 8)
                            
                            if item != cart.items.last {
                                Divider()
                            }
                        }
                    }
                    .padding(16)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    HStack {
                        Text("Total")
                            .font(.title3)
                            .fontWeight(.bold)
                        Spacer()
                        Text(String(format: "£%.2f", cart.total))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 4)
                }
                .padding(.horizontal, 20)
                
                // Customer Details
                VStack(alignment: .leading, spacing: 16) {
                    Text("Customer Details")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 16) {
                        CustomTextField(title: "Full Name", text: $name, placeholder: "Enter your full name")
                        CustomTextField(title: "Phone Number", text: $phone, placeholder: "Enter your phone number")
                            .keyboardType(.phonePad)
                    }
                    .padding(.horizontal, 20)
                }
                
                // Address Details
                VStack(alignment: .leading, spacing: 16) {
                    Text("Delivery Address")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 16) {
                        CustomTextField(title: "Address Line 1", text: $line1, placeholder: "Street address")
                        CustomTextField(title: "Address Line 2", text: $line2, placeholder: "Apartment, suite, etc. (optional)")
                        HStack(spacing: 12) {
                            CustomTextField(title: "City", text: $city, placeholder: "City")
                            CustomTextField(title: "Postcode", text: $postcode, placeholder: "Postcode")
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // Result Message
                if let resultMessage {
                    Text(resultMessage)
                        .font(.subheadline)
                        .foregroundColor(resultMessage.contains("placed") ? .green : .red)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(resultMessage.contains("placed") ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                        )
                }
                
                // Place Order Button
                Button(action: {
                    Task { await submit() }
                }) {
                    HStack {
                        if isSubmitting {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16))
                        }
                        Text(isSubmitting ? "Placing Order..." : "Place Order")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: isSubmitting ? [Color.gray, Color.gray.opacity(0.8)] : [Color.blue, Color.blue.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                .disabled(isSubmitting || cart.items.isEmpty || name.isEmpty || line1.isEmpty || city.isEmpty || postcode.isEmpty)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Checkout")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func submit() async {
        isSubmitting = true
        defer { isSubmitting = false }
        let items = cart.items.map { CheckoutItem(productId: $0.product.id, qty: $0.quantity) }
        let req = CheckoutRequest(
            customer: Customer(name: name, phone: phone.isEmpty ? nil : phone),
            address: Address(line1: line1, line2: line2.isEmpty ? nil : line2, city: city, postcode: postcode),
            items: items,
            notes: nil
        )
        do {
            let orderId = try await CheckoutService.shared.checkout(request: req)
            await MainActor.run {
                resultMessage = "Order placed: #\(orderId.suffix(6))"
                cart.clear()
            }
        } catch {
            await MainActor.run {
                resultMessage = "Checkout failed"
            }
        }
    }
}

#Preview {
    NavigationView { CheckoutView() }
}
