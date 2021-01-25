//
//  AppDelegate.swift
//  WoosmapGeofencing
//
//

import UIKit
import CoreData
import CoreLocation
import WoosmapGeofencing

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UserDefaults.standard.register(defaults:["TrackingEnable":true,
                                                 "SearchAPIEnable":true,
                                                 "DistanceAPIEnable":true,
                                                 "searchAPICreationRegionEnable":true])
        
        // Set private Woosmap key API
        WoosmapGeofencing.shared.setWoosmapAPIKey(key: WoosmapKey)
        WoosmapGeofencing.shared.setGMPAPIKey(key: GoogleStaticMapKey)
        
        // Set the search url Woosmap API
        WoosmapGeofencing.shared.setSearchWoosmapAPI(api: searchWoosmapAPI)
        
        // Set the distance url Woosmap API
        WoosmapGeofencing.shared.setDistanceWoosmapAPI(api: distanceWoosmapAPI)
        WoosmapGeofencing.shared.setDistanceAPIMode(mode: drivingModeDistance)
        
        // Set your filter on position location and search
        //WoosmapGeofencing.shared.setCurrentPositionFilter(distance: 10.0, time: 10)
        //WoosmapGeofencing.shared.setSearchAPIFilter(distance: 10.0, time: 10)
        
        // Set classification of zoi enable
        WoosmapGeofencing.shared.setClassification(enable: true)
        
        WoosmapGeofencing.shared.setFirstSearchAPIRegionRadius(radius: 150.0)
        WoosmapGeofencing.shared.setSecondSearchAPIRegionRadius(radius: 350.0)
        WoosmapGeofencing.shared.setThirdSearchAPIRegionRadius(radius: 550.0)

        
        // Set delegate of protocol Location, POI and Distance
        WoosmapGeofencing.shared.getLocationService().locationServiceDelegate = DataLocation()
        WoosmapGeofencing.shared.getLocationService().searchAPIDataDelegate = DataPOI()
        WoosmapGeofencing.shared.getLocationService().distanceAPIDataDelegate = DataDistance()
        WoosmapGeofencing.shared.getLocationService().regionDelegate = DataRegion()
        
        // Enable Visit and set delegate of protocol Visit
        WoosmapGeofencing.shared.setVisitEnable(enable: true)
        WoosmapGeofencing.shared.getLocationService().visitDelegate = DataVisit()
        
        // Set Tracking state
        WoosmapGeofencing.shared.setTrackingEnable(enable: UserDefaults.standard.bool(forKey: "TrackingEnable"))
        
        // Set SearchAPI automatic on each location
        WoosmapGeofencing.shared.setSearchAPIRequestEnable(enable: UserDefaults.standard.bool(forKey: "SearchAPIEnable"))
        
        // Set 3 Creations Regions POI from Search API result
        WoosmapGeofencing.shared.setSearchAPICreationRegionEnable(enable: UserDefaults.standard.bool(forKey: "searchAPICreationRegionEnable"))
        
        // Set DistanceAPI automatic on each POI
        WoosmapGeofencing.shared.setDistanceAPIRequestEnable(enable: UserDefaults.standard.bool(forKey: "DistanceAPIEnable"))
        
        //MockData Visit
        //MockDataVisit().mockVisitData()
        
        
        // Check if the authorization Status of location Manager
        if (CLLocationManager.authorizationStatus() != .notDetermined) {
            WoosmapGeofencing.shared.startMonitoringInBackground()
        }
        
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]) { granted, error in }
        } else {
            application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
        }
        application.registerForRemoteNotifications()
        
        return true
    }
    
    // Handle remote notification registration. (succes)
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){
        let tokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("this will return '32 bytes' in iOS 13+ rather than the token \(tokenString)")
        NSLog("%%%%% THE the token: %@", tokenString);
        UserDefaults.standard.set(tokenString, forKey:"TokenID")
    }
    
    // Handle remote notification registration. (failed)
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NSLog("Error on getting remote notification token : \(error.localizedDescription)")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        if (CLLocationManager.authorizationStatus() != .notDetermined) {
            WoosmapGeofencing.shared.startMonitoringInBackground()
        }
        
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        WoosmapGeofencing.shared.didBecomeActive()
        let userDataCleaner = UserDataCleaner()
        userDataCleaner.cleanOldGeographicData()
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Location")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

