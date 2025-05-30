import SwiftUI
import SwiftData

struct StoreView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var products: [Product]
    
    @ObservedObject var cartViewModel = CartViewModel.shared
    @State private var searchText = ""
    @State private var isSearching = false
    
    private var filteredProducts: [Product] {
        searchText.isEmpty ? products : products.filter {
            ($0.title + String(format: "%f", $0.price)).lowercased().contains(searchText.lowercased())
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                if isSearching {
                    searchHeaderView
                } else {
                    regularHeaderView
                }
                
                Divider()
                    .background(Color.gray)
            
                ScrollView {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ],
                        spacing: 16
                    ) {
                        ForEach(filteredProducts) { product in
                            ProductCard(
                                product: product,
                                size: CGSize(
                                    width: (geometry.size.width - 48) / 2,
                                    height: (geometry.size.width)/1.4
                                )
                            ) {
                                cartViewModel.addProduct(product)
                            }
                        }
                    }
                    .padding(16)
                }
            }
        }
        .onAppear {
            if products.isEmpty {
                addInitialProducts()
            }
        }
    }
    
    private func addInitialProducts() {
        let initialProducts = [
            Product(imageName: "circle", title: "Circle", price: 9),
            Product(imageName: "square", title: "Square", price: 19),
            Product(imageName: "capsule", title: "Capsule", price: 24),
            Product(imageName: "triangle", title: "Triangle", price: 7),
            Product(imageName: "diamond", title: "Diamond", price: 3),
            Product(imageName: "pentagon", title: "Pentagon", price: 10)
        ]
        
        for product in initialProducts {
            modelContext.insert(product)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save initial products: \(error)")
        }
    }
    
 
    private var regularHeaderView: some View {
        HStack {
            Text("Category Page")
                .font(.system(size: 20, weight: .bold))
                .padding(.leading)
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    isSearching = true
                }
            }) {
                Image(systemName: "magnifyingglass")
                    .padding(.trailing)
            }
        }
        .frame(height: 44)
    }
    
    private var searchHeaderView: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search", text: $searchText)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(8)
            .background(Color(.systemGray5))
            .cornerRadius(8)
            
            Button("Cancel") {
                withAnimation {
                    isSearching = false
                    searchText = ""
                }
            }
            .padding(.trailing, 8)
        }
        .padding(.horizontal)
        .frame(height: 44)
        .transition(.move(edge: .trailing))
    }
}

struct ProductCard: View {
    let product: Product
    let size: CGSize
    var addToCart: () -> Void
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0.5) {
            Image(systemName: product.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: size.width, height: size.width)
                .clipped()
                .cornerRadius(8)
                .background(Color(.systemGray5))
                .padding(.top, 2)
            
            Text(product.title)
                .font(.system(size: 17, weight: .medium))
                .lineLimit(2)
                .frame(height: size.height * 0.1, alignment: .top)
                .padding(.horizontal, 6)
                .padding(.top, 1)
            
            Text("$\(product.price, specifier: "%.2f")")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.blue)
                .frame(height: size.height * 0.1)
                .padding(.horizontal, 6)
                .padding(.top, 0)
            
            Spacer()
            
            Button(action: {
                addToCart()
                withAnimation(.spring()) {
                    isAnimating = true
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        isAnimating = false
                    }
                }
            }) {
                Text("Add to cart")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: max(30, size.height * 0.1))
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .scaleEffect(isAnimating ? 1.05 : 1.0)
            .padding(.horizontal, 6)
            .padding(.bottom, 6)
        }
        .frame(width: size.width, height: size.height)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
