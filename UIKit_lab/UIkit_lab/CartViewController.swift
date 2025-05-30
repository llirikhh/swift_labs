import UIKit

class CartViewController: UIViewController {
    static let shared = CartViewController()
    
    private var cartItems: [CartItem] = []
    private let tableView = UITableView()
    private let totalStackView = UIStackView()
    private let cartTotalLabel = UILabel()
    private let taxLabel = UILabel()
    private let subTotalLabel = UILabel()
    private let checkoutButton = UIButton(type: .system)
    private let emptyCartLabel = UILabel()
    private let headerSeparator = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        updateCartState()
    }
    
    private func setupNavigationBar() {
        let titleLabel = UILabel()
        titleLabel.text = "Cart"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        headerSeparator.backgroundColor = .separator
        headerSeparator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerSeparator)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CartItemCell.self, forCellReuseIdentifier: "CartItemCell")
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        emptyCartLabel.text = "Cart is empty"
        emptyCartLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        emptyCartLabel.textColor = .secondaryLabel
        emptyCartLabel.textAlignment = .center
        emptyCartLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyCartLabel)
        
        totalStackView.axis = .vertical
        totalStackView.spacing = 8
        totalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        [cartTotalLabel, taxLabel, subTotalLabel].forEach {
            $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            totalStackView.addArrangedSubview($0)
        }
        
        let separator = UIView()
        separator.backgroundColor = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        totalStackView.insertArrangedSubview(separator, at: 2)
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        view.addSubview(totalStackView)
        
        checkoutButton.setTitle("Done", for: .normal)
        checkoutButton.backgroundColor = .systemBlue.withAlphaComponent(0.5)
        checkoutButton.setTitleColor(.white.withAlphaComponent(0.5), for: .normal)
        checkoutButton.layer.cornerRadius = 8
        checkoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        checkoutButton.isEnabled = false
        checkoutButton.addTarget(self, action: #selector(checkoutTapped), for: .touchUpInside)
        checkoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(checkoutButton)
        
        NSLayoutConstraint.activate([
            headerSeparator.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerSeparator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerSeparator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerSeparator.heightAnchor.constraint(equalToConstant: 1),
            
            tableView.topAnchor.constraint(equalTo: headerSeparator.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: totalStackView.topAnchor, constant: -20),
            
            emptyCartLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyCartLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            totalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            totalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            totalStackView.bottomAnchor.constraint(equalTo: checkoutButton.topAnchor, constant: -20),
            
            checkoutButton.heightAnchor.constraint(equalToConstant: 50),
            checkoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            checkoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            checkoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func updateCartState() {
        tableView.reloadData()
        updateCartTotals()
        
        let isEmpty = cartItems.isEmpty
        
        emptyCartLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        totalStackView.isHidden = isEmpty
        
        checkoutButton.isEnabled = !isEmpty
        checkoutButton.backgroundColor = isEmpty ? .systemBlue.withAlphaComponent(0.5) : .systemBlue
        checkoutButton.setTitleColor(isEmpty ? .white.withAlphaComponent(0.5) : .white, for: .normal)
    }
        func addProduct(_ product: Product) {
        if let index = cartItems.firstIndex(where: { $0.product.title == product.title }) {
            cartItems[index].quantity += 1
        } else {
            cartItems.append(CartItem(product: product, quantity: 1))
        }
        updateCartState()
    }
    
    private func removeProduct(at index: Int) {
        cartItems.remove(at: index)
        updateCartState()
    }
    
    private func updateCartTotals() {
        let cartTotal = cartItems.reduce(0) { $0 + $1.totalPrice }
        let tax = cartTotal * 0.20
        let subTotal = cartTotal + tax
        
        cartTotalLabel.text = "Cart Total: $\(String(format: "%.2f", cartTotal))"
        taxLabel.text = "Taxes (20%): $\(String(format: "%.2f", tax))"
        subTotalLabel.text = "Sub Total: $\(String(format: "%.2f", subTotal))"
    }
    
    @objc private func checkoutTapped() {
        guard !cartItems.isEmpty else { return }
        
        let alert = UIAlertController(
            title: "Succesful",
            message: "Succesful!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
            self?.cartItems.removeAll()
            self?.updateCartState()
        })
        present(alert, animated: true)
    }
}

extension CartViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartItemCell", for: indexPath) as! CartItemCell
        let item = cartItems[indexPath.row]
        cell.configure(with: item)
        
        cell.onQuantityChanged = { [weak self] newQuantity in
            self?.cartItems[indexPath.row].quantity = newQuantity
            self?.updateCartTotals()
        }
        
        cell.onDelete = { [weak self] in
            self?.removeProduct(at: indexPath.row)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
