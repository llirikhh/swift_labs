import SwiftUI

import SwiftData

struct CartView: View {
    @ObservedObject var viewModel = CartViewModel.shared
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                VStack(spacing: 0) {
                    HStack {
                        Text("Cart")
                            .font(.system(size: 20, weight: .bold))
                        Spacer()
                    }
                    .padding()
                    
                    Divider()
                }
                if viewModel.cartItems.isEmpty {
                    emptyCartView
                } else {
                    listView
                    totalsView
                    checkoutButton
                }
            }
            .navigationBarHidden(true)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Succesful"),
                    message: Text("Succesful!"),
                    dismissButton: .default(Text("Ok")))
    
            }
        }
    }
    
    private var emptyCartView: some View {
        VStack {
            Spacer()
            Text("Cart is empty")
                .font(.title3)
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var listView: some View {
        List {
            ForEach(viewModel.cartItems.indices, id: \.self) { index in
                CartItemRow(item: $viewModel.cartItems[index]) {
                    viewModel.removeItem(at: index)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private var totalsView: some View {
        VStack(spacing: 8) {
            Divider()
            
            HStack {
                Text("Cart Total:")
                Spacer()
                Text("$\(viewModel.calculateTotal(), specifier: "%.2f")")
            }
            
            HStack {
                Text("Taxes (20%):")
                Spacer()
                Text("$\(viewModel.calculateTax(), specifier: "%.2f")")
            }
            
            Divider()
            
            HStack {
                Text("Sub Total:")
                Spacer()
                Text("$\(viewModel.calculateSubtotal(), specifier: "%.2f")")
                    .fontWeight(.bold)
            }
        }
        .padding()
    }
    
    private var checkoutButton: some View {
        Button(action: {
            showAlert = true
            viewModel.checkout()
        }) {
            Text("Done")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.blue)
                .cornerRadius(10)
        }
        .padding()
    }
}

struct CartItemRow: View {
    @Binding var item: CartItem
    var onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: item.product.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.product.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text("$\(item.totalPrice, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            HStack {
                Text("\(item.quantity)")
                    .frame(width: 30)
                
                Stepper("",
                       onIncrement: { item.quantity += 1 },
                       onDecrement: { item.quantity = max(1, item.quantity - 1) })
                    .labelsHidden()
                    .frame(width: 100)
            }
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .frame(width: 20, height: 20)
            }
        }
        .padding(.vertical, 8)
    }
}
