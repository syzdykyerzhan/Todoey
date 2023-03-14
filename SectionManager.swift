//
//  DataManager.swift
//  Todoey
//
//  Created by Yerzhan Syzdyk on 02.03.2023.
//

import Foundation
import UIKit
import CoreData

protocol SectionManagerDelegate{
    func didUpdate(with list: [TodoeySection])
    func didFail(with error: Error)
}

struct SectionManager{
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var delegate : SectionManagerDelegate?
    static var shared = SectionManager()
    
    func fetchSections(){
        do{
            let request = TodoeySection.fetchRequest()
            
            let desc = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [desc]
            
            let models = try context.fetch(request)
            delegate?.didUpdate(with: models)
        }catch{
            print("Error accured: ", error)
        }
    }
    
    func createSection(with name: String, color: String = "white"){
        let newSection = TodoeySection(context: context)
        newSection.name = name
        newSection.color = color
        do{
            try context.save()
            fetchSections()
        }catch{
            delegate?.didFail(with: error)
        }
    }
    
    func deleteSection(section: TodoeySection){
        do{
            context.delete(section)
            try context.save()
            fetchSections()
        }catch{
            delegate?.didFail(with: error)
        }
    }
    
    func editSection(section: TodoeySection,with name: String){
        do{
            section.name = name
            try context.save()
            fetchSections()
        }catch{
            print("Error accured: ", error)
        }
    }
    
    func updateSection(section: TodoeySection,with photo: Data){
        do{
            section.storedImage = photo
            try context.save()
            fetchSections()
        }catch{
            print("Error accured: ", error)
        }
    }
}

extension SectionManagerDelegate{
    func didFail(with error: Error){
        print("Error accured: ", error)
    }
}
