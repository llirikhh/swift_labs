import UIKit

class StoreViewController: UIViewController {
    
    private var products: [Product] = [
        Product(imageName: "circle", title: "Circle", price: 9),
        Product(imageName: "square", title: "Square", price: 19),
        Product(imageName: "capsule", title: "Capsule", price: 24),
        Product(imageName: "triangle", title: "Triangle", price: 7),
        Product(imageName: "diamond", title: "Diamond", price: 3),
        Product(imageName: "pentagon", title: "Pentagon", price: 10)
    ]
    
    private var filteredProducts: [Product] = []
    private let searchController = UISearchController(searchResultsController: nil)
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let navBarSeparator = UIView()
    
    private var ascending = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupSearchController()
        setupNavBarSeparator()
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
    }
    
    private func setupNavigationBar() {
        let searchButton = UIBarButtonItem(
            image: UIImage(systemName: "magnifyingglass"),
            style: .plain,
            target: self,
            action: #selector(showSearchBar)
        )
        ///
        let filterButton = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease.circle"),
            style: .plain,
            target: self,
            action: #selector(showFilterOptions)
        )
        
        navigationItem.rightBarButtonItems = [filterButton, searchButton]

        let titleLabel = UILabel()
        titleLabel.text = "Category"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
    }

    
    private func setupNavBarSeparator() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        
        navBarSeparator.backgroundColor = .lightGray
        navBarSeparator.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.addSubview(navBarSeparator)
        
        NSLayoutConstraint.activate([
            navBarSeparator.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor),
            navBarSeparator.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor),
            navBarSeparator.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            navBarSeparator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    @objc private func showSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        DispatchQueue.main.async {
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    ///
    @objc private func showFilterOptions() {
        if ascending {
            self.products.sort { $0.title.lowercased() < $1.title.lowercased() }
            self.collectionView.reloadData()
        } else {
            self.products.sort { $0.title.lowercased() > $1.title.lowercased() }
            self.collectionView.reloadData()
        }
        ascending.toggle()
    }

    
    private func hideSearchBar() {
        navigationItem.searchController = nil
        filteredProducts.removeAll()
        collectionView.reloadData()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ProductCell.self, forCellWithReuseIdentifier: ProductCell.reuseID)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 16
            layout.minimumInteritemSpacing = 16
            layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        }
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func filterProducts(for searchText: String) {
        filteredProducts = products.filter {
            $0.title.lowercased().contains(searchText.lowercased())
        }
        collectionView.reloadData()
    }
}

extension StoreViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty ?
            filteredProducts.count : products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCell.reuseID, for: indexPath) as! ProductCell
        let product = searchController.isActive && !searchController.searchBar.text!.isEmpty ?
            filteredProducts[indexPath.item] : products[indexPath.item]
        cell.configure(with: product)
        cell.addToCartAction = { product in
            CartViewController.shared.addProduct(product)
        }
        return cell
    }
}

extension StoreViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16 * 3
        let availableWidth = view.frame.width - padding
        let widthPerItem = availableWidth / 2
        return CGSize(width: widthPerItem, height: widthPerItem + 120)
    }
}

extension StoreViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterProducts(for: searchController.searchBar.text ?? "")
    }
}

extension StoreViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        hideSearchBar()
    }
}
