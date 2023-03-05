//
//  ItemViewController.swift
//  Todoey
//
//  Created by Yerzhan Syzdyk on 01.03.2023.
//

import UIKit
import DropDown

final class SectionViewController: UIViewController {
    
    private var selectedColor = "white"
    
    private lazy var menu : DropDown = {
        let menu = DropDown()
        menu.dataSource = ["white","red","green","blue","yellow","pink","orange","cyan","brown","gray"]
        menu.anchorView = sectionTableView
        return menu
    }()
    
    private var models = [TodoeySection]()
    
    private lazy var sectionTableView : UITableView = {
        let myTableView = UITableView()
        myTableView.register(DataTableViewCell.self, forCellReuseIdentifier: DataTableViewCell.IDENTIFIER)
        return myTableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SectionManager.shared.delegate = self
        SectionManager.shared.fetchSections()
        
        view.backgroundColor = .cyan
        setNavigationButton()
        
        sectionTableView.delegate = self
        sectionTableView.dataSource = self
        
        setupViews()
        setupConstraints()
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
    
    func getColor(with model: TodoeySection) -> UIColor{
        switch model.color{
        case "red": return UIColor.red
        case "blue": return UIColor.blue
        case "green": return UIColor.green
        case "pink": return UIColor.systemPink
        case "yellow": return UIColor.yellow
        case "gray": return UIColor.gray
        case "cyan": return UIColor.cyan
        case "brown": return UIColor.brown
        case "orange": return UIColor.orange
        default: return UIColor.white
        }
    }
    
}

//MARK: Table View Data Source
extension SectionViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DataTableViewCell.IDENTIFIER) as! DataTableViewCell
        cell.configure(with: models[indexPath.row].name!)
        
        cell.backgroundColor = getColor(with: models[indexPath.row])
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

        deleteAction.backgroundColor = .red
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction,editAction])
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
