//
//  ViewController.swift
//  Todoey
//
//  Created by Yerzhan Syzdyk on 27.02.2023.
//

import UIKit
import SnapKit
import CoreData

final class ItemViewController: UIViewController {
    
    private var models = [TodoeyItem]()
    public var selectedSection : TodoeySection?
    var addValue = 0.0
    private lazy var imagePicker = UIImagePickerController()
    private var updatingItem : TodoeyItem?
    
    private lazy var searchBar : UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.searchTextField.backgroundColor = .white
        searchBar.layer.borderWidth = 2
        searchBar.layer.borderColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        return searchBar
    }()
    
    private lazy var itemsTableView : UITableView = {
        let myTableView = UITableView()
        myTableView.register(DataTableViewCell.self, forCellReuseIdentifier: DataTableViewCell.IDENTIFIER)
        return myTableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .cyan
        
        ItemManager.shared.delegate = self
        ItemManager.shared.fetchItems(section: selectedSection!)
        
        imagePicker.delegate = self
        
        itemsTableView.dataSource = self
        itemsTableView.delegate = self
        searchBar.delegate = self
        
        setNavigationButton()
        setupViews()
        setupConstraints()
    }
}

//MARK: Image Picker Delegate

extension ItemViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            if updatingItem != nil, selectedSection != nil{
                ItemManager.shared.updateItem(item: self.updatingItem!, with: (image.jpegData(compressionQuality: 1.0))!, section: self.selectedSection! )
            }
        }
    }
}

//MARK: Search bar delegate
extension ItemViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        ItemManager.shared.fetchItems(with: searchText,section: selectedSection!)
    }
}

//MARK: Data Manager delagate methods
extension ItemViewController: ItemManagerDelegate{
    func didUpdate(with list: [TodoeyItem]) {
        models = list
        DispatchQueue.main.async {
            self.itemsTableView.reloadData()
        }
    }
}

//MARK: Private extensions
private extension ItemViewController{
    func setNavigationButton(){
        navigationItem.title = selectedSection?.name
        navigationController?.navigationBar.tintColor = .label
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let addBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        
        navigationItem.rightBarButtonItem = addBarButton
    }
    
    @objc private func addTapped(){
        let alert  = UIAlertController(title: "New Item", message: "Create new item", preferredStyle: .alert)
        alert.addTextField()
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { _ in
            guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else { return }
            ItemManager.shared.createItem(with: text, section: self.selectedSection!)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    func getColor() -> UIColor{
        switch selectedSection!.color{
        case "red": return UIColor.generate(r: 1, g: 0, b: 0, v: addValue)
        case "blue": return UIColor.generate(r: 0, g: 0, b: 1, v: addValue)
        case "green": return UIColor.generate(r: 0, g: 1, b: 0, v: addValue)
        case "pink": return UIColor.generate(r: 1, g: 45/255, b: 85/255, v: addValue)
        case "yellow": return UIColor.generate(r: 1, g: 1, b: 0, v: addValue)
        case "gray": return UIColor.generate(r: 142/255, g: 142/255, b: 147/255, v: addValue)
        case "cyan": return UIColor.generate(r: 0, g: 1, b: 1, v: addValue)
        case "brown": return UIColor.generate(r: 0.6, g: 0.4, b: 0.2, v: addValue)
        case "orange": return UIColor.generate(r: 1, g: 0.5, b: 0, v: addValue)
        default: return UIColor.generate(r: 1, g: 1, b: 1, v: addValue)
        }
    }
}

//MARK: Table View Data Source
extension ItemViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DataTableViewCell.IDENTIFIER) as! DataTableViewCell
        let model = models[indexPath.row]
        
        if let name = model.name{
            cell.configure(with: name,tintColor: .white, data: model.storedImage)
        }
        
        if indexPath.row == 0 {addValue = 0.0}
        addValue += 0.1
        cell.backgroundColor = getColor()
        return cell
    }
}

extension ItemViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        view.frame.size.height * 0.1
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, handler) in
            ItemManager.shared.deleteItem(item: self.models[indexPath.row],section: self.selectedSection!)
        }
        deleteAction.backgroundColor = .red
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, handler) in
            let alert  = UIAlertController(title: "Edit Item", message: "Change name of item", preferredStyle: .alert)
            alert.addTextField()
            alert.textFields?.first?.text = self.models[indexPath.row].name
            alert.addAction(UIAlertAction(title: "Change", style: .cancel, handler: { _ in
                guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else { return }
                
                ItemManager.shared.editItem(item: self.models[indexPath.row], with: text,section: self.selectedSection!)
            }))
            
            self.present(alert, animated: true)
        }
        
        let updateAction = UIContextualAction(style: .destructive, title: "Set image") { (action, view, handler) in
            
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .photoLibrary
            self.updatingItem = self.models[indexPath.row]
            
            self.present(self.imagePicker,animated: true,completion: nil)
        }
        updateAction.backgroundColor = .blue
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction,editAction,updateAction])
        return configuration
    }
}

//MARK: setup views and constraints

extension ItemViewController{
    func setupViews(){
        view.addSubview(searchBar)
        view.addSubview(itemsTableView)
    }
    func setupConstraints(){
        searchBar.snp.makeConstraints { make in
            make.leading.top.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        searchBar.searchTextField.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(7)
        }
        itemsTableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(5)
            make.leading.bottom.trailing.equalToSuperview()
        }
    }
}
