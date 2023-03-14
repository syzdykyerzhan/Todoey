//
//  ItemViewController.swift
//  Todoey
//
//  Created by Yerzhan Syzdyk on 01.03.2023.
//

import UIKit
import DropDown

final class SectionViewController: UIViewController, UINavigationControllerDelegate {
    
    private var selectedColor = "white"
    private var imagePicker = UIImagePickerController()
    public var updatingSection: TodoeySection?
    private var models = [TodoeySection]()
    
    private lazy var menu : DropDown = {
        let menu = DropDown()
        var data : [String] = []
        for color in Colors.allCases{data.append(color.rawValue)}
        menu.dataSource = data
        menu.anchorView = sectionTableView
        return menu
    }()
    
    private lazy var sectionTableView : UITableView = {
        let myTableView = UITableView()
        myTableView.register(DataTableViewCell.self, forCellReuseIdentifier: DataTableViewCell.IDENTIFIER)
        return myTableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SectionManager.shared.delegate = self
        SectionManager.shared.fetchSections()
        
        imagePicker.delegate = self
        
        view.backgroundColor = .cyan
        setNavigationButton()
        
        sectionTableView.delegate = self
        sectionTableView.dataSource = self
        
        setupViews()
        setupConstraints()
    }
}

//MARK: Image Picker Delegate

extension SectionViewController: UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            if updatingSection != nil{
                SectionManager.shared.updateSection(section: self.updatingSection!, with: (image.jpegData(compressionQuality: 1.0))!)
            }
        }
    }
}

//MARK: SectionManger delegate methods

extension SectionViewController: SectionManagerDelegate{
    func didUpdate(with list: [TodoeySection]) {
        models = list
        
        DispatchQueue.main.async {
            self.sectionTableView.reloadData()
        }
    }
}

//MARK: Private extensions
private extension SectionViewController{
    
    func setNavigationButton(){
        navigationItem.title = "Todoey"
        navigationController?.navigationBar.tintColor = .label
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let addBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        let colorBarButton = UIBarButtonItem(image: UIImage(systemName: "paintpalette"), style: .plain, target: self, action: #selector(setColor))
        
        navigationItem.rightBarButtonItems = [addBarButton,colorBarButton]
    }
    
    @objc private func addTapped(){
        let alert  = UIAlertController(title: "New Section", message: "Create new section", preferredStyle: .alert)
        alert.addTextField()
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { _ in
            guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else { return }
            
            SectionManager.shared.createSection(with: text, color: self.selectedColor)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc private func setColor(){
        menu.show()
        menu.selectionAction = {_, title in
            self.selectedColor = title
        }
    }
    
    func getColor(with model: TodoeySection) -> (UIColor,UIColor){
        switch model.color{
        case "red": return (UIColor.red, UIColor.white)
        case "blue": return (UIColor.blue,UIColor.white)
        case "green": return (UIColor.green,UIColor.white)
        case "pink": return (UIColor.systemPink,UIColor.white)
        case "yellow": return (UIColor.yellow,UIColor.black)
        case "gray": return (UIColor.gray,UIColor.black)
        case "cyan": return (UIColor.cyan,UIColor.black)
        case "brown": return (UIColor.brown,UIColor.white)
        case "orange": return (UIColor.orange,UIColor.black)
        default: return (UIColor.white,UIColor.black)
        }
    }
}

//MARK: Table View Data Source
extension SectionViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DataTableViewCell.IDENTIFIER) as! DataTableViewCell
        let myVar = getColor(with: models[indexPath.row])
        
        if let name = models[indexPath.row].name{
            cell.configure(with: name,tintColor: myVar.1, data: models[indexPath.row].storedImage)
        }
        
        cell.backgroundColor = myVar.0
        cell.selectionStyle = .none
        
        return cell
    }
}

extension SectionViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        view.frame.size.height * 0.1
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, handler) in
            SectionManager.shared.deleteSection(section: self.models[indexPath.row])
        }
        deleteAction.backgroundColor = .red

        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, handler) in
            let alert  = UIAlertController(title: "Edit Section", message: "Change name of section", preferredStyle: .alert)
            alert.addTextField()
            alert.textFields?.first?.text = self.models[indexPath.row].name
            alert.addAction(UIAlertAction(title: "Change", style: .cancel, handler: { _ in
                guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else { return }

                SectionManager.shared.editSection(section: self.models[indexPath.row], with: text)
            }))

            self.present(alert, animated: true)
        }

        let updateAction = UIContextualAction(style: .destructive, title: "Set Image") { (action, view, handler) in
            
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .photoLibrary
            self.updatingSection = self.models[indexPath.row]
            
            self.present(self.imagePicker,animated: true,completion: nil)
        }
        updateAction.backgroundColor = .blue

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction,editAction,updateAction])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = ItemViewController()
        viewController.selectedSection = models[indexPath.row]
        navigationController?.pushViewController(viewController, animated: true)
    }
}


//MARK: setup views and constraints

extension SectionViewController{
    func setupViews(){
        view.addSubview(sectionTableView)
    }
    func setupConstraints(){
        sectionTableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension UIColor {
    
    static func generate(r: CGFloat,g:CGFloat,b:CGFloat,v: CGFloat) -> UIColor{
        return UIColor(
            red: checkVal(a: r, b: v), green: checkVal(a: g, b: v), blue: checkVal(a: b, b: v), alpha: 1
        )
    }
    
    static func checkVal(a: CGFloat,b:CGFloat) -> CGFloat{
        if(a-b>0.0){return (a-b)}
        else{return 0.0}
    }
}
