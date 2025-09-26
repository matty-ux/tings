import SwiftUI

struct ProductsView: View {
    @State private var products: [Product] = []
    @State private var filteredProducts: [Product] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var searchText: String = ""
    @State private var selectedCategory: String = "All"
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
                    } else if filteredProducts.isEmpty && (!searchText.isEmpty || selectedCategory != "All") {
                        VStack(spacing: 20) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary)
                            Text("No products found")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("Try adjusting your search or category filter")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            Button("Clear Filters") {
                                searchText = ""
                                selectedCategory = "All"
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                        }
                        .padding()
                    } else {
                        MainContentView(
                            products: filteredProducts,
                            searchText: $searchText,
                            selectedCategory: $selectedCategory,
                            allProducts: products,
                            cart: cart,
                            load: load
                        )
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
        .onChange(of: searchText) {
            filterProducts()
        }
        .onChange(of: selectedCategory) {
            filterProducts()
        }
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
                    self.filteredProducts = data
                    self.isLoading = false
                    // Apply initial filtering
                    self.filterProducts()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load products"
                    self.isLoading = false
                }
            }
        }
    }
    
    private func filterProducts() {
        var filtered = products
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { product in
                product.name.localizedCaseInsensitiveContains(searchText) ||
                product.shortDesc?.localizedCaseInsensitiveContains(searchText) == true ||
                product.category?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
        
        // Filter by category
        if selectedCategory != "All" {
            filtered = filtered.filter { product in
                product.category?.localizedCaseInsensitiveContains(selectedCategory) == true
            }
        }
        
        filteredProducts = filtered
    }
}

#Preview {
    ProductsView()
}

// MARK: - Inline Components

struct MainContentView: View {
    let products: [Product]
    @Binding var searchText: String
    @Binding var selectedCategory: String
    let allProducts: [Product]
    let cart: CartManager
    let load: () -> Void
    
    var availableCategories: [String] {
        let categories = Set(allProducts.compactMap { $0.category })
        return ["All"] + Array(categories).sorted()
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HeroSectionView(
                    searchText: $searchText,
                    selectedCategory: $selectedCategory,
                    availableCategories: availableCategories
                )
                ProductsGridView(products: products, cart: cart)
            }
        }
        .refreshable { load() }
    }
    
    private func filterProducts() {
        // This will be handled by the parent view
    }
}

struct HeroSectionView: View {
    @Binding var searchText: String
    @Binding var selectedCategory: String
    let availableCategories: [String]
    
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
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            
            // Tagline
            Text("The UAE's Favourite British Food Delivery service")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            // Search Bar
            SearchBarView(searchText: $searchText)
            
            // Category Pills
            CategoryPillsView(
                selectedCategory: $selectedCategory,
                availableCategories: availableCategories
            )
        }
        .padding(.bottom, 20)
    }
}

struct CategoryPillsView: View {
    @Binding var selectedCategory: String
    let availableCategories: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(availableCategories, id: \.self) { category in
                    CategoryPillView(
                        title: category,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct SearchBarView: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search for British favorites...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
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
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
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
        .buttonStyle(PlainButtonStyle())
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
