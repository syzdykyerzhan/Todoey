//
//  TodoeyItem+CoreDataProperties.swift
//  
//
//  Created by Yerzhan Syzdyk on 06.03.2023.
//
//

import Foundation
import CoreData


extension TodoeyItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoeyItem> {
        return NSFetchRequest<TodoeyItem>(entityName: "TodoeyItem")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var name: String?
    @NSManaged public var color: String?
    @NSManaged public var section: TodoeySection?

}
