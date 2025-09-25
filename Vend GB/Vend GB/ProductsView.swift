import SwiftUI

struct ProductsView: View {
    @State private var products: [Product] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @StateObject private var cart = CartManager.shared
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some View {
        NavigationView {
            ZStack {
                // Adaptive background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                Group {
                    if let errorMessage {
                        VStack(spacing: 20) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundColor(.orange)
                            Text(errorMessage)
                                .font(.headline)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            Button("Retry", action: load)
                                .buttonStyle(.borderedProminent)
                                .controlSize(.large)
                        }
                        .padding()
                    } else if isLoading && products.isEmpty {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Loading delicious items...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        MainContentView(products: products, cart: cart, load: load)
                    }
                }
            }
            .navigationBarHidden(true)
            .safeAreaInset(edge: .bottom) {
                if !cart.items.isEmpty {
                    CartBottomBar(cart: cart)
                } else {
                    // Bottom Navigation
                    BottomNavigationBarView()
                }
            }
        }
        .task { load() }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }

    private func load() {
        errorMessage = nil
        isLoading = true
        Task {
            do {
                let data = try await ProductService.shared.fetchProducts()
                await MainActor.run {
                    self.products = data
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load products"
                    self.isLoading = false
                }
            }
        }
    }
}

#Preview {
    ProductsView()
}

// MARK: - Inline Components

struct MainContentView: View {
    let products: [Product]
    let cart: CartManager
    let load: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HeroSectionView()
                ProductsGridView(products: products, cart: cart)
            }
        }
        .refreshable { load() }
    }
}

struct HeroSectionView: View {
    var body: some View {
        VStack(spacing: 16) {
            // App Logo/Title
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Vend GB")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button(action: {}) {
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            
            // Tagline
            Text("The UAE's Favourite British Food Delivery service")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            // Category Pills
            CategoryPillsView()
            
            // Search Bar
            SearchBarView()
        }
        .padding(.bottom, 20)
    }
}

struct CategoryPillsView: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryPillView(title: "Deals", isSelected: true)
                CategoryPillView(title: "Fast Delivery", isSelected: false)
                CategoryPillView(title: "New", isSelected: false)
                CategoryPillView(title: "Hot", isSelected: false)
            }
            .padding(.horizontal, 20)
        }
    }
}

struct SearchBarView: View {
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            Text("Search for British favorites...")
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 20)
    }
}

struct ProductsGridView: View {
    let products: [Product]
    let cart: CartManager
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 16) {
            ForEach(products) { product in
                ProductCard(product: product, cart: cart)
            }
        }
        .padding(.horizontal, 20)
    }
}

struct CategoryPillView: View {
    let title: String
    let isSelected: Bool
    
    var body: some View {
        Text(title)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue : Color(.secondarySystemGroupedBackground))
            )
    }
}

struct BottomNavigationBarView: View {
    @State private var selectedTab = 0
    @State private var showingAccountView = false
    
    var body: some View {
        HStack(spacing: 0) {
            TabButtonView(
                icon: "house.fill",
                title: "Home",
                isSelected: selectedTab == 0
            ) {
                selectedTab = 0
            }
            
            TabButtonView(
                icon: "magnifyingglass",
                title: "Search",
                isSelected: selectedTab == 1
            ) {
                selectedTab = 1
            }
            
            TabButtonView(
                icon: "list.bullet",
                title: "Orders",
                isSelected: selectedTab == 2
            ) {
                selectedTab = 2
            }
            
            TabButtonView(
                icon: "person.fill",
                title: "Profile",
                isSelected: selectedTab == 3
            ) {
                selectedTab = 3
                showingAccountView = true
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 1),
            alignment: .top
        )
        .sheet(isPresented: $showingAccountView) {
            AccountView()
        }
    }
}

struct TabButtonView: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .blue : .gray)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
