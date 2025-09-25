import SwiftUI
import Stripe

struct PaymentSheet: View {
    @StateObject private var paymentService = PaymentService.shared
    @Binding var isPresented: Bool
    @Binding var orderRequest: OrderRequest?
    @State private var paymentMethodParams: STPPaymentMethodParams? = nil
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Complete Payment")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if let order = orderRequest {
                        Text(String(format: "£%.2f", order.total))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.top, 20)
                
                // Payment Form
                VStack(spacing: 20) {
                    // Card Details
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Card Details")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        STPPaymentCardTextField.Representable(paymentMethodParams: $paymentMethodParams)
                            .frame(height: 50)
                            .padding(.horizontal, 16)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    // Payment Button
                    Button(action: {
                        Task {
                            if let order = orderRequest, let paymentMethod = paymentMethodParams {
                                await paymentService.processPayment(for: order, paymentMethod: paymentMethod)
                            }
                        }
                    }) {
                        HStack {
                            if paymentService.isProcessing {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: "creditcard.fill")
                                    .font(.system(size: 16))
                            }
                            
                            Text(paymentService.isProcessing ? "Processing..." : "Pay Now")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: paymentService.isProcessing ? 
                                    [Color.gray, Color.gray.opacity(0.8)] : 
                                    [Color.blue, Color.blue.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .disabled(paymentService.isProcessing || !isPaymentMethodValid)
                    
                    // Payment Result
                    if let result = paymentService.paymentResult {
                        switch result {
                        case .success(let orderId):
                            VStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.green)
                                
                                Text("Payment Successful!")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                
                                Text("Order #\(orderId.suffix(6))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Button("Done") {
                                    isPresented = false
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.green)
                                .clipShape(Capsule())
                            }
                            .padding(.top, 20)
                            
                        case .failure(let error):
                            VStack(spacing: 12) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.red)
                                
                                Text("Payment Failed")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                                
                                Text(error)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                Button("Try Again") {
                                    paymentService.paymentResult = nil
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.red)
                                .clipShape(Capsule())
                            }
                            .padding(.top, 20)
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .navigationTitle("Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .disabled(paymentService.isProcessing)
                }
            }
        }
        .onDisappear {
            // Reset payment result when sheet is dismissed
            paymentService.paymentResult = nil
        }
    }
    
    private var isPaymentMethodValid: Bool {
        // Basic validation - in a real app you'd want more comprehensive validation
        return paymentMethodParams?.card != nil
    }
}

#Preview {
    PaymentSheet(
        isPresented: .constant(true),
        orderRequest: .constant(OrderRequest(
            id: "test123",
            total: 15.99,
            items: [],
            customer: Customer(name: "Test User", phone: nil),
            address: Address(line1: "123 Test St", line2: nil, city: "Test City", postcode: "TE1 1ST")
        ))
    )
}
