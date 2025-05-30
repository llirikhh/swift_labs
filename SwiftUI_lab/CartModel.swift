import Foundation

class CartViewModel: ObservableObject {
    static let shared = CartViewModel()
    private init() {}
    
    @Published var cartItems: [CartItem] = []
    
    func addProduct(_ product: Product) {
        if let index = cartItems.firstIndex(where: { $0.product.id == product.id }) {
            cartItems[index].quantity += 1
        } else {
            cartItems.append(CartItem(product: product, quantity: 1))
        }
    }
    
    
    func removeItem(at index: Int) {
        cartItems.remove(at: index)
    }
    
    func removeItem(withId id: UUID) {
        if let index = cartItems.firstIndex(where: { $0.id == id }) {
            cartItems.remove(at: index)
        }
    }
    
    func calculateTotal() -> Double {
        return cartItems.reduce(0) { $0 + $1.totalPrice }
    }
    
    func calculateTax() -> Double {
        return calculateTotal() * 0.20
    }
    
    func calculateSubtotal() -> Double {
        return calculateTotal() + calculateTax()
    }
    
    func checkout() {
        cartItems.removeAll()
    }
}
