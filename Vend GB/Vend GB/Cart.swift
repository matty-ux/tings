import Foundation
import SwiftUI

struct CartItem: Identifiable, Hashable {
    let id: String
    let product: Product
    var quantity: Int
}

final class CartManager: ObservableObject {
    static let shared = CartManager()

    @Published private(set) var items: [CartItem] = []

    private init() {}

    var total: Double {
        items.reduce(0) { $0 + Double($1.quantity) * ($1.product.salePrice ?? $1.product.price) }
    }

    func add(product: Product) {
        if let idx = items.firstIndex(where: { $0.product.id == product.id }) {
            items[idx].quantity += 1
        } else {
            items.append(CartItem(id: product.id, product: product, quantity: 1))
        }
    }

    func changeQuantity(for productId: String, by delta: Int) {
        guard let idx = items.firstIndex(where: { $0.product.id == productId }) else { return }
        let newQty = max(0, items[idx].quantity + delta)
        if newQty == 0 {
            items.remove(at: idx)
        } else {
            items[idx].quantity = newQty
        }
    }

    func clear() {
        items.removeAll()
    }
}
