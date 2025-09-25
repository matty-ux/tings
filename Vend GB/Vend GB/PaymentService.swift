import Foundation
import Stripe

final class PaymentService: ObservableObject {
    static let shared = PaymentService()
    
    private init() {
        // Initialize Stripe with publishable key
        StripeAPI.defaultPublishableKey = "pk_live_51PHVTuHOqlzoVZb0CVdn0yNyDYGsDkMMi5Pc9KVAe2YTEWVnJsW8Mmq3fBYXlCVACgGktvHCS7ZGlnFXaFDokxZE00SK7S8xgG"
    }
    
    @Published var isProcessing = false
    @Published var paymentResult: PaymentResult?
    
    enum PaymentResult {
        case success(orderId: String)
        case failure(error: String)
    }
    
    func createPaymentIntent(for order: OrderRequest) async throws -> PaymentIntent {
        let url = AppConfig.baseURL.appendingPathComponent("/api/payment/create-intent")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = [
            "orderId": order.id,
            "amount": order.total,
            "currency": "gbp"
        ] as [String: Any]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw PaymentError.serverError("Failed to create payment intent")
        }
        
        let paymentData = try JSONDecoder().decode(PaymentIntentResponse.self, from: data)
        
        // Create Stripe PaymentIntent
        let paymentIntent = PaymentIntent(
            id: paymentData.paymentIntentId,
            clientSecret: paymentData.clientSecret,
            amount: paymentData.amount,
            currency: paymentData.currency
        )
        
        return paymentIntent
    }
    
    func confirmPayment(paymentIntent: PaymentIntent, orderId: String) async throws -> String {
        let url = AppConfig.baseURL.appendingPathComponent("/api/payment/confirm")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = [
            "paymentIntentId": paymentIntent.id,
            "orderId": orderId
        ] as [String: Any]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw PaymentError.serverError("Failed to confirm payment")
        }
        
        let confirmData = try JSONDecoder().decode(PaymentConfirmResponse.self, from: data)
        
        if confirmData.success {
            return confirmData.orderId ?? orderId
        } else {
            throw PaymentError.confirmationFailed(confirmData.message ?? "Payment confirmation failed")
        }
    }
    
    func processPayment(for order: OrderRequest, paymentMethod: STPPaymentMethodParams) async {
        await MainActor.run {
            isProcessing = true
            paymentResult = nil
        }
        
        do {
            // Step 1: Create payment intent
            let paymentIntent = try await createPaymentIntent(for: order)
            
            // Step 2: Confirm payment with Stripe
            let paymentIntentParams = STPPaymentIntentParams(clientSecret: paymentIntent.clientSecret)
            paymentIntentParams.paymentMethodParams = paymentMethod
            
            let result = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<STPPaymentIntent, Error>) in
                STPAPIClient.shared.confirmPaymentIntent(with: paymentIntentParams) { paymentIntent, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let paymentIntent = paymentIntent {
                        continuation.resume(returning: paymentIntent)
                    } else {
                        continuation.resume(throwing: PaymentError.serverError("Unknown payment error"))
                    }
                }
            }
            
            switch result.status {
            case .succeeded:
                // Step 3: Confirm payment on server
                let confirmedOrderId = try await confirmPayment(paymentIntent: paymentIntent, orderId: order.id)
                
                await MainActor.run {
                    paymentResult = .success(orderId: confirmedOrderId)
                    isProcessing = false
                }
                
            case .requiresAction:
                // Handle 3D Secure or other authentication
                await MainActor.run {
                    paymentResult = .failure(error: "Payment requires additional authentication")
                    isProcessing = false
                }
                
            default:
                await MainActor.run {
                    paymentResult = .failure(error: "Payment failed")
                    isProcessing = false
                }
            }
            
        } catch {
            await MainActor.run {
                paymentResult = .failure(error: error.localizedDescription)
                isProcessing = false
            }
        }
    }
}

// MARK: - Supporting Types

struct OrderRequest {
    let id: String
    let total: Double
    let items: [CheckoutItem]
    let customer: Customer
    let address: Address
}

struct PaymentIntent {
    let id: String
    let clientSecret: String
    let amount: Double
    let currency: String
}

struct PaymentIntentResponse: Codable {
    let clientSecret: String
    let paymentIntentId: String
    let amount: Double
    let currency: String
}

struct PaymentConfirmResponse: Codable {
    let success: Bool
    let message: String?
    let orderId: String?
}

enum PaymentError: LocalizedError {
    case serverError(String)
    case confirmationFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .serverError(let message):
            return message
        case .confirmationFailed(let message):
            return message
        }
    }
}
