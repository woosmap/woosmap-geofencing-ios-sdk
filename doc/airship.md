﻿

  
## Airship Integration
  
Generate contextual events from Geofencing SDK data using their different event types: Geofences, POI, Visits and ZOI.

Whenever location events are generated, the SDK geofencing will send custom events and properties to Airship via a delegate protocol. This data can then be used with the Custom Event trigger in the Automation and Journey composers.

###  Airship Integration Requirements

**Airship**

1.  **SDK version 6.0 or later:**  Download the latest stable SDK from appropriate  [Platform](https://docs.airship.com/platform/)  page.
2.  **Account Entitlements:**  Account-level permissions apply, based on your pricing package. Contact Airship Sales with any questions related to pricing and entitlements for location and automation services.

### Configure Airship Integration in your app

To configure your app with the Airship SDK follow the instruction on the Airship web site :
https://docs.airship.com/platform/ios/getting-started/

### Set up Airship events 
The first step in sending custom events to Airship is to set `airshipEventsDelegate`, this should be done as early as possible in your didFinishLaunchingWithOptions App Delegate.

```swift
let dataLocation = DataLocation()
let dataPOI = DataPOI()
let dataDistance = DataDistance()
let dataRegion = DataRegion()
let dataVisit = DataVisit()
let airshipEvents = AirshipEvents()

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
	
	#if canImport(AirshipCore)
        // Populate AirshipConfig.plist with your app's info from https://go.urbanairship.com
        // or set runtime properties here.
        let config = UAConfig.default()

        if (config.validate() != true) {
            showInvalidConfigAlert()
            return true
        }

        // Set log level for debugging config loading (optional)
        // It will be set to the value in the loaded config upon takeOff
        UAirship.setLogLevel(UALogLevel.trace)

        config.messageCenterStyleConfig = "UAMessageCenterDefaultStyle"

        // You can then programmatically override the plist values:
        // config.developmentAppKey = "YourKey"
        // etc.
        // Call takeOff (which creates the UAirship singleton)
        UAirship.takeOff(config)
        UAirship.push()?.userPushNotificationsEnabled = true
        UAirship.push()?.defaultPresentationOptions = [.alert,.badge,.sound]
        UAirship.push()?.isAutobadgeEnabled = true


        // Print out the application configuration for debugging (optional)
        print("Config:\n \(config)")
        WoosmapGeofencing.shared.getLocationService().airshipEventsDelegate = airshipEvents
	#endif
``` 
### Retrieve Airship events
In your class delegate, retrieve custom events data :
``` swift
public class AirshipEvents: AirshipEventsDelegate {
    
    public init() {}
    
    public func regionEnterEvent(regionEvent: Dictionary<String, Any>) {
        #if canImport(AirshipCore)
            let event = UACustomEvent(name: "Geofence_entered_event", value: 1)
            event.properties = regionEvent
            event.track()
        #endif
    }
    
    public func regionExitEvent(regionEvent: Dictionary<String, Any>) {
        #if canImport(AirshipCore)
            let event = UACustomEvent(name: "Geofence_exited_event", value: 1)
            event.properties = regionEvent
            event.track()
        #endif
    }
    
    public func visitEvent(visitEvent: Dictionary<String, Any>) {
        #if canImport(AirshipCore)
            let event = UACustomEvent(name: "Visit_event", value: 1)
            event.properties = visitEvent
            event.track()
        #endif
    }
    
    public func poiEvent(POIEvent: Dictionary<String, Any>) {
        #if canImport(AirshipCore)
            let event = UACustomEvent(name: "poi_event", value: 1)
            event.properties = POIEvent
            event.track()
        #endif
    }
}
```

##  Events and Properties

### Geofences

**geofence_entered_event**

Date: String  
id: String  
lattitude: Double  
longitude: Double
radius: Double

**geofence_exited_event**

Date: String  
id: String  
lattitude: Double  
longitude: Double
radius: Double

### POI

**POI_event**

Date: String  
Name: String  
IdStore: String  
City: String  
Distance: String  
Tag: String  
type: String  

### Visit

**Visit_event**
Date: String  
arrivalDate: String  
departureDate: String  
Id: String  
lattitude: Double  
longitude: Double