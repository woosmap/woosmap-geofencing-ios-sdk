//
//  ZOI+CoreDataProperties.swift
//  
//
//  Created by Mac de Laurent on 02/06/2020.
//
//

import Foundation
import CoreData


extension ZOI {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ZOI> {
        return NSFetchRequest<ZOI>(entityName: "ZOI")
    }

    @NSManaged public var zoiId: UUID?
    @NSManaged public var idVisits: [UUID]?
    @NSManaged public var lngMean: Double
    @NSManaged public var latMean: Double
    @NSManaged public var age: Double
    @NSManaged public var accumulator: Double
    @NSManaged public var covariance_det: Double
    @NSManaged public var prior_probability: Double
    @NSManaged public var x00Covariance_matrix_inverse: Double
    @NSManaged public var x01Covariance_matrix_inverse: Double
    @NSManaged public var x10Covariance_matrix_inverse: Double
    @NSManaged public var x11Covariance_matrix_inverse: Double
    @NSManaged public var startTime: Date?
    @NSManaged public var endTime: Date?
    @NSManaged public var duration: Int64
    @NSManaged public var wktPolygon: String?

}