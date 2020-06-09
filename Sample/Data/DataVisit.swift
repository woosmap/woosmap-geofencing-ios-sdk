//
//  DataVisit.swift
//
//  WoosmapGeofencing
//
//
import Foundation
import UIKit
import CoreData
import CoreLocation
import WoosmapGeofencing

class DataVisit:VisitServiceDelegate  {
    
    func processVisit(visit: CLVisit) {
        let calendar = Calendar.current
        let departureDate = calendar.component(.year, from: visit.departureDate) != 4001 ? visit.departureDate : nil
        let arrivalDate = calendar.component(.year, from: visit.arrivalDate) != 4001 ? visit.arrivalDate : nil
        if (arrivalDate != nil && departureDate != nil) {
            let visitToSave = VisitModel(visitId: UUID(), arrivalDate: arrivalDate, departureDate: departureDate, latitude: visit.coordinate.latitude, longitude: visit.coordinate.longitude, dateCaptured:Date() , accuracy: visit.horizontalAccuracy)
            createVisit(visit: visitToSave)
        }
        
        
    }
    
    func readVisits()-> Array<Visit> {
        var visits = [Visit]()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Visit>(entityName: "Visit")
        
        do {
            visits = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return visits
    }
    
    func createVisit(visit: VisitModel) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Visit", in: context)!
        let newVisit = Visit(entity: entity, insertInto: context)
        newVisit.setValue(visit.visitId, forKey: "visitId")
        newVisit.setValue(visit.arrivalDate, forKey: "arrivalDate")
        newVisit.setValue(visit.departureDate, forKey: "departureDate")
        newVisit.setValue(visit.accuracy, forKey: "accuracy")
        newVisit.setValue(visit.latitude, forKey: "latitude")
        newVisit.setValue(visit.longitude, forKey: "longitude")
        newVisit.setValue(visit.dateCaptured, forKey: "date")
        do {
            try context.save()
        }
        catch let error as NSError {
            print("Could not insert. \(error), \(error.userInfo)")
        }
        NotificationCenter.default.post(name: .newVisitSaved, object: self)
        DataZOI().createZOIFromVisit(visit: newVisit)
    }
    
    func eraseVisits() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Visit>(entityName: "Visit")
        let deleteReqest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        do {
            try managedContext.execute(deleteReqest)
            try managedContext.save()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func getVisitFromUUID(id:UUID) -> Visit? {
        var visits = [Visit]()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Visit>(entityName: "Visit")
        fetchRequest.predicate = NSPredicate(format: "visitId == %@", id as CVarArg)
        do {
            visits = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        if visits.isEmpty {
            return nil
        }
        return visits.first!
    }
    
    let data = """
    2.2386777435903,48.8323083708807,2020-01-21 07:50:48+00,65.3774798275089
    2.24082349088927,48.8330758450305,2020-01-21 11:29:52+00,38.3856073595407
    2.23862348411691,48.8321628560397,2020-01-21 13:06:18+00,15.4456863336503
    2.30930125268582,48.7643589902469,2020-01-21 18:54:09+00,80.3589674748994
    2.31941716965886,48.7737557665263,2020-01-21 19:02:42+00,21.3536112426926
    2.23863537947482,48.832345717165,2020-01-22 07:50:30+00,72.5685889286188
    2.23978698263326,48.8341021940194,2020-01-22 12:29:18+00,49.6604342773985
    2.22007081866907,48.7828851657022,2020-01-22 18:01:06+00,101.063655268572
    2.31940296073547,48.7737603515304,2020-01-22 19:02:15+00,25.7139167446373
    2.23864658076508,48.8321880081563,2020-01-23 07:59:01+00,30.3215950285522
    2.24090398826995,48.8309549665283,2020-01-23 11:46:16+00,45.0734109043928
    2.23976695474231,48.8370501528679,2020-01-23 17:59:55+00,66.7672314816891
    2.31946135065139,48.7737540364344,2020-01-23 19:03:11+00,33.2422574879817
    2.31198969873405,48.7766314380755,2020-01-24 07:53:24+00,49.8373634120863
    2.31498569025292,48.7790679468002,2020-01-24 11:23:48+00,51.0611529695031
    2.31223336816423,48.7766765943806,2020-01-24 12:58:05+00,74.7812616536017
    2.23862559567543,48.8322009270268,2020-01-24 14:17:20+00,34.0464590222147
    2.31406959630548,48.7808071220997,2020-01-24 18:20:44+00,  77.30560504375
    2.31939670641591,48.7737556969992,2020-01-24 18:44:21+00,21.8108442743744
    2.35853591194929,48.8582132843901,2020-01-25 08:42:54+00,41.3370103305625
    2.34831533134137,48.8617960330088,2020-01-25 10:30:39+00,  91.40607906757
    2.34933060925616,48.8638653605191,2020-01-25 11:01:07+00,88.8807332147459
    2.34720040073831,48.8617830324354,2020-01-25 12:24:02+00,50.2755158496109
    2.31332694478891,48.7802846729979,2020-01-25 13:14:12+00,141.702882811415
    2.31656266913784,48.7772299094577,2020-01-25 13:20:42+00,94.8036483556401
    2.31937018891321,48.7737639681059,2020-01-25 13:26:40+00,40.6515323269322
    2.3112273092939,48.7860932329611,2020-01-26 08:23:48+00,79.7426361731964
    2.17446013412477,48.8796324503401,2020-01-26 09:26:31+00,42.1904172080425
    2.31940925886042,48.7737488538642,2020-01-26 12:44:36+00,20.7704058580833
    2.23869300175604,48.835793675857,2020-01-27 08:07:45+00,92.6689767818966
    2.23899465941025,48.8319527762499,2020-01-27 08:15:27+00,87.5467228259861
    2.31942950406436,48.7737125436886,2020-01-27 19:08:20+00, 27.931609135862
    2.32948271760429,48.7707135750882,2020-01-27 19:55:30+00,64.2919372740388
    2.31947239513145,48.7737790384402,2020-01-27 20:07:00+00,40.6499539171133
    2.23858117314968,48.8321975062541,2020-01-28 07:35:10+00,22.0269428267652
    2.30931773740929,48.7640465091583,2020-01-28 18:28:31+00,99.1699536336039
    2.31939310156085,48.7736890668491,2020-01-28 18:37:39+00,56.5555164749983
    2.31935753246927,48.7737571791295,2020-01-28 18:37:56+00,20.6753601458828
    2.3714155402373,48.8438495065328,2020-01-29 04:30:39+00,51.1631481390948
    3.88516564795694,43.6100283078013,2020-01-29 09:16:08+00,32.9770543064361
    2.37240458132181,48.8442122149723,2020-01-29 19:51:07+00,85.1234660381165
    2.31943575816216,48.7737496914468,2020-01-29 20:21:25+00,25.6472248892004
    2.23845804256012,48.8321602210941,2020-01-30 07:58:16+00,53.3190240380405
    2.23808737662726,48.832149281151,2020-01-30 12:24:02+00,100.747525057372
    2.3194293333356,48.7737423711688,2020-01-30 18:41:03+00,21.0029062113811
    2.23863105197292,48.8322226492718,2020-01-31 07:54:25+00,39.7139843657293
    2.23949747026321,48.832420459554,2020-01-31 11:28:15+00, 114.34115780411
    """
    
    func csv(data: String) -> [[String]] {
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            let columns = row.components(separatedBy: ";")
            result.append(columns)
        }
        return result
    }
    func mockVisitData() {
        eraseVisits()
        DataZOI().eraseZOIs()
        let testDatas = csv(data: data)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ssZ"
        
        for linePoint in testDatas {
            let coord = linePoint[0].components(separatedBy: ",")

            let arrivalDate = dateFormatter.date(from:coord[2])!
            let departureDate = arrivalDate.addingTimeInterval(5177)
            
            let lat = Double(coord[1].trimmingCharacters(in: .whitespaces))!
            let lng = Double(coord[0].trimmingCharacters(in: .whitespaces))!
            let accuracy = Double(coord[3].trimmingCharacters(in: .whitespaces))!
            
            let visitToSave = VisitModel(visitId: UUID(), arrivalDate: arrivalDate, departureDate: departureDate, latitude: lat, longitude:  lng, dateCaptured:Date() , accuracy: accuracy)
            
            createVisit(visit: visitToSave)
        }
        
    }
    
}


extension Notification.Name {
    static let newVisitSaved = Notification.Name("newVisitSaved")
}


