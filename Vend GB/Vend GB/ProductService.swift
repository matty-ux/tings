import Foundation

final class ProductService {
    static let shared = ProductService()
    private init() {}

    func fetchProducts() async throws -> [Product] {
        let url = AppConfig.baseURL.appendingPathComponent("/api/products")
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode([Product].self, from: data)
    }
}
