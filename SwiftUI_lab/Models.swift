import Foundation

import SwiftData
import Foundation

@Model
final class Product: Identifiable {
    var id: UUID
    var imageName: String
    var title: String
    var price: Double
    
    init(imageName: String, title: String, price: Double) {
        self.id = UUID()
        self.imageName = imageName
        self.title = title
        self.price = price
    }
}

struct CartItem: Identifiable {
    let id = UUID()
    let product: Product
    var quantity: Int
    var totalPrice: Double {
        return product.price * Double(quantity)
    }
}
