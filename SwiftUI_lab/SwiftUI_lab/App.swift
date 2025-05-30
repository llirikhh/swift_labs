import SwiftUI
import SwiftData

@main
struct MainApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Product.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            StoreView()
                .tabItem {
                    Label("Category", systemImage: "bag")
                }
            
            CartView()
                .tabItem {
                    Label("Cart", systemImage: "cart")
                }
        }
    }
}
