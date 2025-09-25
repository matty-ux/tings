import Foundation

struct Product: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var shortDesc: String?
    var fullDesc: String?
    var category: String?
    var tags: [String]?
    var price: Double
    var salePrice: Double?
    var imageUrl: String?
    var images: [String]?
    var available: Bool
    var maxOrderQty: Int?
    var sortOrder: Int?
    var priceWithTax: Double?
    var salePriceWithTax: Double?
}
