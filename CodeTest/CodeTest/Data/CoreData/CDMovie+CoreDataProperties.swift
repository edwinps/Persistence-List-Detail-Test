//
//  CDMovie+CoreDataProperties.swift
//  CodeTest
//
//  Created by Edwin Peña on 2/11/22.
//
//

import Foundation
import CoreData

extension CDMovie {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDMovie> {
        return NSFetchRequest<CDMovie>(entityName: "CDMovie")
    }

    @NSManaged public var id: String
    @NSManaged public var imageData: Data?
    @NSManaged public var imageUrl: String?
    @NSManaged public var rating: String?
    @NSManaged public var summary: String?
    @NSManaged public var title: String?
    @NSManaged public var type: String?
    @NSManaged public var favorite: Bool
}

extension CDMovie: Identifiable { }
