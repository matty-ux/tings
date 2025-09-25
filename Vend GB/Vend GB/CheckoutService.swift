import Foundation

struct CheckoutItem: Codable {
    let productId: String
    let qty: Int
}

struct CheckoutRequest: Codable {
    let customer: Customer
    let address: Address
    let items: [CheckoutItem]
    let notes: String?
}

struct Customer: Codable {
    let name: String
    let phone: String?
}

struct Address: Codable {
    let line1: String
    let line2: String?
    let city: String
    let postcode: String
}

final class CheckoutService {
    static let shared = CheckoutService()
    private init() {}

    func checkout(request: CheckoutRequest) async throws -> String {
        let url = AppConfig.baseURL.appendingPathComponent("/api/checkout")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(request)
        print("Checkout request to:", url.absoluteString)
        print("Request body:", String(data: req.httpBody!, encoding: .utf8) ?? "nil")
        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse else {
            print("Invalid response type")
            throw URLError(.badServerResponse)
        }
        print("Response status:", http.statusCode)
        print("Response body:", String(data: data, encoding: .utf8) ?? "nil")
        guard (200..<300).contains(http.statusCode) else {
            print("HTTP error:", http.statusCode)
            throw URLError(.badServerResponse)
        }
        let result = try JSONDecoder().decode([String:String].self, from: data)
        return result["id"] ?? ""
    }
}
