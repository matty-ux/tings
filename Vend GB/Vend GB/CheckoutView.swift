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
    @State private var showingPaymentSheet = false
    @State private var pendingOrderRequest: OrderRequest?
    @State private var deliveryType: DeliveryType = .delivery
    @State private var selectedDeliveryTime: DeliveryTime = .standard

    enum DeliveryType: String, CaseIterable {
        case delivery = "Delivery"
        case pickup = "Pick-up"
    }
    
    enum DeliveryTime: String, CaseIterable {
        case priority = "Priority"
        case standard = "Standard"
        case schedule = "Schedule"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header with delivery type tabs
                VStack(spacing: 16) {
                    HStack {
                        Text("Checkout")
                        .font(.title2)
                        .fontWeight(.bold)
                        Spacer()
                    }
                    
                    // Delivery type selector
                    HStack(spacing: 0) {
                        ForEach(DeliveryType.allCases, id: \.self) { type in
                            Button(action: {
                                deliveryType = type
                            }) {
                                Text(type.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(deliveryType == type ? .primary : .secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(deliveryType == type ? Color(.systemBackground) : Color.clear)
                                    )
                            }
                        }
                    }
                    .padding(4)
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                // Order Summary Section
                VStack(spacing: 16) {
                    HStack {
                        Text("Order Summary")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    VStack(spacing: 0) {
                        ForEach(cart.items) { item in
                            HStack(spacing: 12) {
                                // Product image placeholder
                                AsyncImage(url: URL(string: item.product.imageUrl ?? "")) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .overlay(
                                            Image(systemName: "photo")
                                                .font(.system(size: 16))
                                                .foregroundColor(.gray)
                                        )
                                }
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.product.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .lineLimit(1)
                                    Text("\(item.quantity) item\(item.quantity == 1 ? "" : "s")")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Text(String(format: "£%.2f", Double(item.quantity) * (item.product.salePrice ?? item.product.price)))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            
                            if item != cart.items.last {
                                Divider()
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray5), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                }
                
                // Delivery Time Selection
                if deliveryType == .delivery {
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.blue)
                            Text("Delivery time")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                            Text("10:54 AM - 11:17 AM")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 8) {
                            ForEach(DeliveryTime.allCases, id: \.self) { time in
                                Button(action: {
                                    selectedDeliveryTime = time
                                }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                    HStack {
                                                if time == .priority {
                                                    Image(systemName: "bolt.fill")
                                                        .foregroundColor(.orange)
                                                        .font(.caption)
                                                }
                                                Text(time.rawValue)
                                                    .font(.subheadline)
                                                    .fontWeight(.medium)
                                                Spacer()
                                                if time == .priority {
                                                    Text("+£3.49")
                                                        .font(.caption)
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(.orange)
                                                }
                                            }
                                            
                                            if time == .priority {
                                                Text("10:49 AM - 11:09 AM")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            } else if time == .standard {
                                                Text("10:54 AM - 11:17 AM")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            } else {
                                                Text("Choose a time")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        
                        Spacer()
                                        
                                        if selectedDeliveryTime == time {
                                            Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(selectedDeliveryTime == time ? Color.blue.opacity(0.1) : Color(.systemGray6))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(selectedDeliveryTime == time ? Color.blue : Color.clear, lineWidth: 2)
                                            )
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                // Customer Details
                VStack(spacing: 16) {
                    HStack {
                        Text("Contact Information")
                        .font(.headline)
                        .fontWeight(.semibold)
                        Spacer()
                    }
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 12) {
                        ModernTextField(title: "Full Name", text: $name, placeholder: "Enter your full name", icon: "person")
                        ModernTextField(title: "Phone Number", text: $phone, placeholder: "Enter your phone number", icon: "phone")
                            .keyboardType(.phonePad)
                    }
                    .padding(.horizontal, 20)
                }
                
                // Address Details
                VStack(spacing: 16) {
                    HStack {
                    Text("Delivery Address")
                        .font(.headline)
                        .fontWeight(.semibold)
                        Spacer()
                    }
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 12) {
                        ModernTextField(title: "Address Line 1", text: $line1, placeholder: "Street address", icon: "location")
                        ModernTextField(title: "Address Line 2", text: $line2, placeholder: "Apartment, suite, etc. (optional)", icon: "building.2")
                        HStack(spacing: 12) {
                            ModernTextField(title: "City", text: $city, placeholder: "City", icon: "building")
                            ModernTextField(title: "Postcode", text: $postcode, placeholder: "Postcode", icon: "number")
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // Cost Breakdown
                VStack(spacing: 16) {
                    HStack {
                        Text("Cost Breakdown")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("Subtotal")
                                .font(.subheadline)
                            Spacer()
                            Text(String(format: "£%.2f", cart.total))
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        HStack {
                            Text("Delivery fee")
                                .font(.subheadline)
                            Spacer()
                            Text("£2.99")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        HStack {
                            Text("Service fee")
                                .font(.subheadline)
                            Spacer()
                            Text("£1.50")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        if selectedDeliveryTime == .priority {
                            HStack {
                                Text("Priority delivery")
                                    .font(.subheadline)
                                Spacer()
                                Text("+£3.49")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Total")
                                .font(.headline)
                                .fontWeight(.bold)
                            Spacer()
                            Text(String(format: "£%.2f", totalCost))
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
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
                    Task { await prepareOrder() }
                }) {
                    HStack {
                        if isSubmitting {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "creditcard.fill")
                                .font(.system(size: 16))
                        }
                        Text(isSubmitting ? "Processing..." : "Pay £\(String(format: "%.2f", totalCost))")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(isSubmitting || cart.items.isEmpty || name.isEmpty || line1.isEmpty || city.isEmpty || postcode.isEmpty)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Checkout")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingPaymentSheet) {
            if pendingOrderRequest != nil {
                PaymentSheet(isPresented: $showingPaymentSheet, orderRequest: $pendingOrderRequest)
                    .onDisappear {
                        // Handle payment completion
                        if let result = PaymentService.shared.paymentResult {
                            switch result {
                            case .success(let orderId):
                                resultMessage = "Order placed: #\(orderId.suffix(6))"
                                cart.clear()
                            case .failure(let error):
                                resultMessage = "Payment failed: \(error)"
                            }
                        }
                    }
            }
        }
    }
    
    private var totalCost: Double {
        var total = cart.total
        total += 2.99 // Delivery fee
        total += 1.50 // Service fee
        if selectedDeliveryTime == .priority {
            total += 3.49 // Priority delivery
        }
        return total
    }
    
    private func prepareOrder() async {
        isSubmitting = true
        defer { isSubmitting = false }
        
        let items = cart.items.map { CheckoutItem(productId: $0.product.id, qty: $0.quantity) }
        
        // First, create the order on the server
        let deliveryAddress = "\(line1)\(line2.isEmpty ? "" : ", \(line2)"), \(city), \(postcode)"
        let checkoutRequest = CheckoutRequest(
            customerName: name,
            customerPhone: phone.isEmpty ? nil : phone,
            customerEmail: nil,
            items: items,
            total: cart.total,
            deliveryAddress: deliveryAddress,
            specialInstructions: nil
        )
        
        do {
            // Create order without payment
            let orderId = try await CheckoutService.shared.checkout(request: checkoutRequest)
            
            // Create OrderRequest for payment
            let orderRequest = OrderRequest(
                id: orderId,
                total: cart.total,
                items: items,
                customer: Customer(name: checkoutRequest.customerName, phone: checkoutRequest.customerPhone),
                address: Address(line1: line1, line2: line2.isEmpty ? nil : line2, city: city, postcode: postcode)
            )
            
            await MainActor.run {
                pendingOrderRequest = orderRequest
                showingPaymentSheet = true
            }
            
        } catch {
            await MainActor.run {
                resultMessage = "Failed to prepare order: \(error.localizedDescription)"
            }
        }
    }
}

struct ModernTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.system(size: 14))
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
            }
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

#Preview {
    NavigationView { CheckoutView() }
}
