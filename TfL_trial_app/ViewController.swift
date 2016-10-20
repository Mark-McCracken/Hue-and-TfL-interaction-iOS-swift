//
//  ViewController.swift
//  TfL_trial_app
//
//  Created by Mark McCracken on 26/01/2016.
//  Copyright © 2016 McCracken Apps. All rights reserved.
//

import UIKit
import Foundation
import Alamofire

class ViewController: UIViewController {
    
    //all unique identifiers and keys are not real.
    
    
    // let bridgeIPaddress = "<add your ip address here>"
    //let hueUsername = "<add your hue username here, it will look something like 13ff73d58fc0b7a32fce4695c6074g9>"
    
    let stringBeforeBusType = "<td class=\"resRoute\">\n\t\t\t\t\t\t\n\t\t\t\t\t\t\t\n\t\t\t\t\t\t\t"
    let stringBeforeDestination = "<td class=\"resDir\" style=\"width:50%;\">"
    let stringBeforeDueTime = "<td class=\"resDue\">"
    
    //let hueBaseUrl = "http://<ip address>/api/<hue username>"
    
    //let tflApplicationID = "<your tfl application ID, which will look like 435f5d83>"
    //let tflAPIkey = "<your tfl api key, which will look like 5c4f62697fbe3c8a9b22g29e887982b8>"
    
    var mprHtmlCode = ""
    var sprHtmlCode = ""
    
    var timeToWalkToBusStop = 5
    
    var jsonOptional: JSON? = nil
    var allLights: Array<String> = []
    
    
    var margeryParkRoad86Times: Array<Int> = []
        { didSet { self.AchieveablemargeryParkRoad86Times = self.transformBusTimes(self.margeryParkRoad86Times);
        if self.margeryParkRoad86Times.count > 0 {
            self.nextMPR86Time = self.margeryParkRoad86Times[0]
                }
        else { self.nextMPR86Time = 60 } } }
    
    var margeryParkRoad25Times: Array<Int> = []
        { didSet { self.AchieveablemargeryParkRoad25Times = self.transformBusTimes(self.margeryParkRoad25Times);
        if self.margeryParkRoad25Times.count > 0 {
            self.nextMPR25Time = self.margeryParkRoad25Times[0]
        }
        else { self.nextMPR25Time = 60 }  } }
    
    var SprowstonRoad86Times:   Array<Int> = []
        { didSet { self.AchieveableSprowstonRoad86Times   = self.transformBusTimes(self.SprowstonRoad86Times)  ;
        if self.SprowstonRoad86Times.count > 0   {
            self.nextSpr86Time = self.SprowstonRoad86Times[0]
        }
        else { self.nextSpr86Time = 60 }  } }
    
    var SprowstonRoad25Times:   Array<Int> = []
        { didSet { self.AchieveableSprowstonRoad25Times   = self.transformBusTimes(self.SprowstonRoad25Times)  ;
        if self.SprowstonRoad25Times.count > 0   {
            self.nextSpr25Time = self.SprowstonRoad25Times[0]
        }
        else { self.nextSpr25Time = 60 }  } }
    
    
    
    
    var AchieveablemargeryParkRoad86Times: Array<Int> = []
        { didSet {
        if self.AchieveablemargeryParkRoad86Times.count > 0 {
            self.nextAchMPR86Time = self.AchieveablemargeryParkRoad86Times[0]
        }
        else {
            self.nextAchMPR86Time = 60
        }  } }
    
    var AchieveablemargeryParkRoad25Times: Array<Int> = []
        { didSet {
        if self.AchieveablemargeryParkRoad25Times.count > 0 {
            self.nextAchMPR25Time = self.AchieveablemargeryParkRoad25Times[0]
        }
        else {
            self.nextAchMPR25Time = 60
        }  } }
    
    var AchieveableSprowstonRoad86Times:   Array<Int> = []
        { didSet {
        if self.AchieveableSprowstonRoad86Times.count > 0   {
            self.nextAchSpr86Time = self.AchieveableSprowstonRoad86Times[0]
        }
        else {
            self.nextAchSpr86Time = 60
        }  } }
    
    var AchieveableSprowstonRoad25Times:   Array<Int> = []
        { didSet {
        if self.AchieveableSprowstonRoad25Times.count > 0   {
            self.nextAchSpr25Time = self.AchieveableSprowstonRoad25Times[0]
        }
        else {
            self.nextAchSpr25Time = 60
        }  } }
    
    
    
    var nextAchMPR86Time = 20
    var nextAchMPR25Time = 20
    var nextAchSpr86Time = 20
    var nextAchSpr25Time = 20
    
    var nextMPR86Time    = 20
    var nextMPR25Time    = 20
    var nextSpr86Time    = 20
    var nextSpr25Time    = 20
    
    func transformBusTimes(times: Array<Int>) -> Array<Int> {
        var newTimes: Array<Int> = []
        
        for time in times {
            if time < self.timeToWalkToBusStop {
                if time == 0 {
                    //print("You wouldn't make that bus, it's due now.")
                }
                else if time == 1 {
                    //print("You wouldn't make that bus, it's in", time, "minute.")
                }
                else {
                    //print("You wouldn't make that bus, it's in", time, "minutes.")
                }
            }
            else {
                newTimes.append(time - self.timeToWalkToBusStop)
            }
        }
        
        return newTimes
        
    }
    
    func getBusTimes() {
        let margeryParkRoadStop = "http://m.countdown.tfl.gov.uk/arrivals/48112" //unique id for the busstop, available from TfL
        let sprowstonRoadStop   = "http://m.countdown.tfl.gov.uk/arrivals/73606"
        
        Alamofire.request(.GET, margeryParkRoadStop).validate().responseString { response in
            print("sending request for bus times")
            //print("printing repsonse.response", response.response)
            //print("printing response.result", response.result) //just shows if it was successful
            //print("printing response.result.value", response.result.value) // needs decoding
            
            if let theHtmlCode = response.result.value {
                self.mprHtmlCode = theHtmlCode
                
                
                var breakdownByBus = theHtmlCode.componentsSeparatedByString(self.stringBeforeBusType)
                breakdownByBus.removeFirst()
                self.margeryParkRoad25Times = []
                self.margeryParkRoad86Times = []
                
                for bus in breakdownByBus{
                    //print(bus)
                    let busNumberArray = bus.componentsSeparatedByString("\n")
                    var busNumber = 100
                    guard var possibleBusNumber = Int(busNumberArray[0]) else {
                        print("you fucked up. But it might be a night bus")
                        
                        
                        guard let newBusNumber = Int(busNumberArray[0].componentsSeparatedByString("N")[1]) else {
                            print("Nope, you definitely fucked up.")
                            return
                        }
                        busNumber = newBusNumber
                        
                        return
                    }
                    busNumber = possibleBusNumber
                    
                    //don't really need this information yet.
                    var destinationArr1 = bus.componentsSeparatedByString(self.stringBeforeDestination)
                    destinationArr1.removeFirst()
                    var destinationArr = destinationArr1[0].componentsSeparatedByString("&")
                    let destination = destinationArr[0]
                    //print(destination)
                    //-----------------------------------
                    
                    var timeUntilArr1 = bus.componentsSeparatedByString(self.stringBeforeDueTime)
                    timeUntilArr1.removeFirst()
                    var timeUntilArr = timeUntilArr1[0].componentsSeparatedByString("<")
                    let timeUntil = timeUntilArr[0]
                    
                    switch timeUntil {
                    case "due":
                        if busNumber == 25 {
                            self.margeryParkRoad25Times.append(0)
                        }
                        if busNumber == 86 {
                            self.margeryParkRoad86Times.append(0)
                        }
                        
                    default:
                        guard let timeDue = Int(timeUntil.componentsSeparatedByString(" ")[0]) else {
                            print("couldn't convert time to proper integer")
                            return
                        }
                        if busNumber == 25 {
                            self.margeryParkRoad25Times.append(timeDue)
                        }
                        if busNumber == 86 {
                            self.margeryParkRoad86Times.append(timeDue)
                        }
                    }
                    
                }
            }
            
         print("mpr times fetched")
        }
        
        Alamofire.request(.GET, sprowstonRoadStop).validate().responseString { response in
            
            //print("printing repsonse.response", response.response)
            //print("printing response.result", response.result) //just shows if it was successful
            //print("printing response.result.value", response.result.value) // needs decoding
            
            if let theHtmlCode = response.result.value {
                self.sprHtmlCode = theHtmlCode
                
                
                var breakdownByBus = theHtmlCode.componentsSeparatedByString(self.stringBeforeBusType)
                breakdownByBus.removeFirst()
                self.SprowstonRoad25Times = []
                self.SprowstonRoad86Times = []
                
                for bus in breakdownByBus{
                    let busNumberArray = bus.componentsSeparatedByString("\n")
                    var busNumber = 100
                    guard var possibleBusNumber = Int(busNumberArray[0]) else {
                        print("you fucked up. But it might be a night bus")
                        
                        
                        guard let newBusNumber = Int(busNumberArray[0].componentsSeparatedByString("N")[1]) else {
                            print("Nope, you definitely fucked up.")
                            return
                        }
                        busNumber = newBusNumber
                        
                        return
                    }
                    busNumber = possibleBusNumber
                    
                    //don't really need this information yet.
                    var destinationArr1 = bus.componentsSeparatedByString(self.stringBeforeDestination)
                    destinationArr1.removeFirst()
                    var destinationArr = destinationArr1[0].componentsSeparatedByString("&")
                    let destination = destinationArr[0]
                    //print(destination)
                    //-----------------------------------
                    
                    var timeUntilArr1 = bus.componentsSeparatedByString(self.stringBeforeDueTime)
                    timeUntilArr1.removeFirst()
                    var timeUntilArr = timeUntilArr1[0].componentsSeparatedByString("<")
                    let timeUntil = timeUntilArr[0]
                    
                    switch timeUntil {
                    case "due":
                        if busNumber == 25 {
                            self.SprowstonRoad25Times.append(0)
                        }
                        if busNumber == 86 {
                            self.SprowstonRoad86Times.append(0)
                        }
                        
                    default:
                        guard let timeDue = Int(timeUntil.componentsSeparatedByString(" ")[0]) else {
                            print("couldn't convert time to proper integer")
                            return
                        }
                        if busNumber == 25 {
                            self.SprowstonRoad25Times.append(timeDue)
                        }
                        if busNumber == 86 {
                            self.SprowstonRoad86Times.append(timeDue)
                        }
                    }
                    
                }
            }
            
            print("spr times fetched")
        }
        
        
    }
    
    func printTimes() {
        
        print("86 times from mpr:\n",
            self.margeryParkRoad86Times,
            "\nWhat the 86 times will be when you get to mpr:\n",
            self.transformBusTimes(self.margeryParkRoad86Times),
            "\nNext mpr 86",
            self.nextMPR86Time,
            "\nNext acheiveable mpr 86",
            self.nextAchMPR86Time)  // mpr  86
        
        print("25 times from mpr:\n",
            self.margeryParkRoad25Times,
            "\nWhat the 25 times will be when you get to mpr:\n",
            self.transformBusTimes(self.margeryParkRoad25Times),
            "\nNext mpr 25",
            self.nextMPR25Time,
            "\nNext acheiveable mpr 25",
            self.nextAchMPR25Time)  // mpr 25
        
        print("86 times from spr:\n",
            self.SprowstonRoad86Times,
            "\nWhat the 86 times will be when you get to spr:\n",
            self.transformBusTimes(self.SprowstonRoad86Times),
            "\nNext spr 86",
            self.nextSpr86Time,
            "\nNext acheiveable spr 86",
            self.nextAchSpr86Time)  // sprowston road 86
        print("25 times from spr:\n",
            self.SprowstonRoad25Times,
            "\nWhat the 25 times will be when you get to spr:\n",
            self.transformBusTimes(self.SprowstonRoad25Times),
            "\nNext spr 25",
            self.nextSpr25Time,
            "\nNext acheiveable spr 25",
            self.nextAchSpr25Time)  // sprowston road 25
        
        print("acheivable times: ", self.nextAchMPR86Time, self.nextAchMPR25Time, self.nextAchSpr86Time, self.nextAchSpr25Time)
        
        
    }
    
    func turnAllLightsOn() {
        
        let parameters = [
            "on": true
        ]
        
        for light in allLights {
            Alamofire.request(.PUT, hueBaseUrl + "/lights/\(light)/state/", parameters: parameters, encoding: .JSON).validate().responseJSON { response in
                //print(response.response)
                
            }
        }
    }
    
    func turnAllLightsOff() {
        
        
        let parameters = [
            "on": false
        ]
        for light in allLights {
            Alamofire.request(.PUT, hueBaseUrl + "/lights/\(light)/state/", parameters: parameters, encoding: .JSON).validate().responseJSON { response in
                //print(response.response)
                
            }
        }

    }
    
    func setBrightnessTo(value: Int) {
        var val = value
        if val > 254 {
            val = 254
        }
        //check value isn't too high
        let parameters = [
            "bri": val
        ]
        //set parameters, in this case the brightness
        for light in allLights {
            Alamofire.request(.PUT, hueBaseUrl + "/lights/\(light)/state/", parameters: parameters, encoding: .JSON).validate().responseJSON { response in
                print(response.response)
            }
        }
        //send the .PUT request with a JSON encoded body of the constant, parameters.
    }
    
    func findAllLights() {
        
        Alamofire.request(.GET, "http://" + bridgeIPaddress + "/api/" + hueUsername, parameters: nil).validate().responseJSON { response in
            //   print(response.request) //this is simply the request sent. Whatever you've sent
            
            //   print(response.response) //this shows the reponse of your request, whether successful or not.
            
            //   print(response.data) //print the data. this needs decoding.
            
            //   print(response.result) //prints whether or not the reult has been a success. eg. SUCCESS
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    self.jsonOptional = JSON(value)
                    let temporaryJSON = JSON(value)
                    
                    for (light,subJson):(String,JSON) in temporaryJSON["lights"] {
                        self.allLights.append(light)
                    }
                    //                    print("JSON: \(json)")
                }
            case .Failure(let error):
                print(error)
            }
            
            print(self.allLights)
        }
    }
    
    func getLightStatuses() {
        
        Alamofire.request(.GET, "http://" + bridgeIPaddress + "/api/" + hueUsername, parameters: nil).validate().responseJSON { response in
            //   print(response.request) //this is simply the request sent. Whatever you've sent
            
            //   print(response.response) //this shows the reponse of your request, whether successful or not.
            
            //   print(response.data) //print the data. this needs decoding.
            
            //   print(response.result) //prints whether or not the reult has been a success. eg. SUCCESS
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    self.jsonOptional = JSON(value)
                    let temporaryJSON = JSON(value)
                    
                    for (light,subJson):(String,JSON) in temporaryJSON["lights"] {
                        self.allLights.append(light)
                    }
                    //                    print("JSON: \(json)")
                }
            case .Failure(let error):
                print(error)
            }
        
        
        

        
        guard let json = self.jsonOptional else { print("error!")
            return }
        
        for (light,subJson):(String,JSON) in json["lights"] {
            print(light)
            
            // gets on off state of each light
            
            for (state,subJson):(String,JSON) in json["lights"][light] {
                if state == "state" {
                    for (on,subJson):(String,JSON) in json["lights"][light][state] {
                        if on == "on" {
                            print(json["lights"][light]["name"], " on off status: ", json["lights"][light][state][on])
                            
                        }
                    }
                    
                }
            }
        }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        findAllLights()
        getBusTimes()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    func updateLights() {
        let purpleLightHue = 49776 //furthest away time, 8+ min
        let blueLightHue   = 47125 // 5 - 7 min
        let greenLightHue  = 25653 // 4 min
        let yellowLightHue = 22581 // 3 min
        let orangeLightHue = 11427 // 2 min
        let pinkLightHue   = 55056 // 1 min
        let redLightHue    = 65527 //bus due
        
        
        // 1 - library
        // 2 - kitchen
        // 3 - tv
        // 4 - table
        // 5 - lamp
        let mpr86LightNumber = 4
        let mpr25LightNumber = 1
        let spr86LightNumber = 2
        let spr25LightNumber = 3
        
        var mpr86Hue: Int
        var mpr25Hue: Int
        var spr86Hue: Int
        var spr25Hue: Int
        
        switch self.nextAchMPR86Time {
        case 0:
            mpr86Hue = redLightHue
        case 1:
            mpr86Hue = pinkLightHue
        case 2:
            mpr86Hue = orangeLightHue
        case 3:
            mpr86Hue = yellowLightHue
        case 4:
            mpr86Hue = greenLightHue
        case 5, 6, 7:
            mpr86Hue = blueLightHue
        default:
            mpr86Hue = purpleLightHue
        }
        switch self.nextAchMPR25Time {
        case 0:
            mpr25Hue = redLightHue
        case 1:
            mpr25Hue = pinkLightHue
        case 2:
            mpr25Hue = orangeLightHue
        case 3:
            mpr25Hue = yellowLightHue
        case 4:
            mpr25Hue = greenLightHue
        case 5, 6, 7:
            mpr25Hue = blueLightHue
        default:
            mpr25Hue = purpleLightHue
        }
        switch self.nextAchSpr86Time {
        case 0:
            spr86Hue = redLightHue
        case 1:
            spr86Hue = pinkLightHue
        case 2:
            spr86Hue = orangeLightHue
        case 3:
            spr86Hue = yellowLightHue
        case 4:
            spr86Hue = greenLightHue
        case 5, 6, 7:
            spr86Hue = blueLightHue
        default:
            spr86Hue = purpleLightHue
        }
        switch self.nextAchMPR86Time {
        case 0:
            spr25Hue = redLightHue
        case 1:
            spr25Hue = pinkLightHue
        case 2:
            spr25Hue = orangeLightHue
        case 3:
            spr25Hue = yellowLightHue
        case 4:
            spr25Hue = greenLightHue
        case 5, 6, 7:
            spr25Hue = blueLightHue
        default:
            spr25Hue = purpleLightHue
        }
        
        
        let mpr86Param = [
            "hue": mpr86Hue
        ]
        let mpr25Param = [
            "hue": mpr25Hue
        ]
        let spr86Param = [
            "hue": spr86Hue
        ]
        let spr25Param = [
            "hue": spr25Hue
        ]
        
        
        Alamofire.request(.PUT, hueBaseUrl + "/lights/\(mpr86LightNumber)/state/", parameters: mpr86Param, encoding: .JSON).validate().responseJSON { response in
            print(response.response)
            
        }
        Alamofire.request(.PUT, hueBaseUrl + "/lights/\(mpr25LightNumber)/state/", parameters: mpr25Param, encoding: .JSON).validate().responseJSON { response in
            print(response.response)
            
        }
        Alamofire.request(.PUT, hueBaseUrl + "/lights/\(spr86LightNumber)/state/", parameters: spr86Param, encoding: .JSON).validate().responseJSON { response in
            print(response.response)
            
        }
        Alamofire.request(.PUT, hueBaseUrl + "/lights/\(spr25LightNumber)/state/", parameters: spr25Param, encoding: .JSON).validate().responseJSON { response in
            print(response.response)
            
        }
        
        
        
        
    }
    
    
    
    
    
    @IBAction func button1(sender: AnyObject) {
        getLightStatuses()
    }
    
    
    
    @IBAction func button2(sender: AnyObject) {
        turnAllLightsOn()

    }
    

    @IBAction func button3(sender: AnyObject) {
        turnAllLightsOff()
    }
    
    
    
    @IBAction func button(sender: AnyObject) {
        getBusTimes()
    }
    
    
    
    
    func update()
    {
        
        getBusTimes()
        printTimes()
        updateLights()
        
        print("doing it now")
    }
    
    @IBAction func button5(sender: AnyObject) {
        
        var helloWorldTimer = NSTimer.scheduledTimerWithTimeInterval(15.0, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        
        
        
        /*
        func stopTimer() {
            dispatch_source_cancel(timer)
            timer = nil
        }
        */
        
        
    }
    
    
    @IBAction func ShowBusTimesLogged(sender: AnyObject) {
        printTimes()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

