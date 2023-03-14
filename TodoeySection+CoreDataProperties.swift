//
//  TodoeySection+CoreDataProperties.swift
//  
//
//  Created by Yerzhan Syzdyk on 14.03.2023.
//
//

import Foundation
import CoreData


extension TodoeySection {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoeySection> {
        return NSFetchRequest<TodoeySection>(entityName: "TodoeySection")
    }

    @NSManaged public var color: String?
    @NSManaged public var name: String?
    @NSManaged public var storedImage: Data?
    @NSManaged public var items: NSSet?

}

// MARK: Generated accessors for items
extension TodoeySection {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: TodoeyItem)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: TodoeyItem)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}
