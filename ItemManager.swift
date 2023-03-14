//
//  DataManager.swift
//  Todoey
//
//  Created by Yerzhan Syzdyk on 02.03.2023.
//

import Foundation
import UIKit

protocol ItemManagerDelegate{
    func didUpdate(with list: [TodoeyItem])
    func didFail(with error: Error)
}

struct ItemManager{
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var delegate : ItemManagerDelegate?
    static var shared = ItemManager()
    var selectedSection: TodoeySection?
    
    func fetchItems(with text: String = "", section: TodoeySection){
        do{
            let request = TodoeyItem.fetchRequest()
            
            if text != "" {
                let firstPredicate = NSPredicate(format: "name CONTAINS %@", text)
                let secondPredicate = NSPredicate(format: "section == %@", section)
                
                let andPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [firstPredicate, secondPredicate])
                request.predicate = andPredicate
            }else{
                let secondPredicate = NSPredicate(format: "section == %@", section)
                
                request.predicate = secondPredicate
            }
            
            let desc = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [desc]
            
            let models = try context.fetch(request)
            delegate?.didUpdate(with: models)
        }catch{
            print("Error accured: ", error)
        }
    }
    
    func createItem(with name: String, section: TodoeySection){
        let newItem = TodoeyItem(context: context)
        newItem.name = name
        newItem.createdAt = Date()
        newItem.color = section.color
        section.addToItems(newItem)
        do{
            try context.save()
            fetchItems(section: section)
        }catch{
            delegate?.didFail(with: error)
        }
    }
    
    func deleteItem(item: TodoeyItem, section: TodoeySection){
        do{
            context.delete(item)
            try context.save()
            fetchItems(section: section)
        }catch{
            delegate?.didFail(with: error)
        }
    }
    
    func editItem(item: TodoeyItem,with name: String,section: TodoeySection){
        do{
            item.name = name
            try context.save()
            fetchItems(section: section)
        }catch{
            print("Error accured: ", error)
        }
    }
    
    func updateItem(item: TodoeyItem,with data: Data,section: TodoeySection){
        do{
            item.storedImage = data
            try context.save()
            fetchItems(section: section)
        }catch{
            print("Error accured: ", error)
        }
    }
}

extension ItemManagerDelegate{
    func didFail(with error: Error){
        print("Error accured: ", error)
    }
}
