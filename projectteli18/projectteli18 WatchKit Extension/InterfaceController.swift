//
//  InterfaceController.swift
//  projectteli18 WatchKit Extension
//
//  Created by Space Lab on 2020-03-04.
//  Copyright © 2020 Space Lab. All rights reserved.
//

import HealthKit
import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    
    
    var watchSession : WCSession!
    var healthStore: HKHealthStore?
    var lastHeartRate = 0.0
    let beatCountPerMinute = HKUnit(from: "count/min")
    var server = ""
    var activityID = ""
    var deviceID = ""
    var apiKey = ""
    var userID = ""
    
    @IBOutlet var bpmLabel: WKInterfaceLabel!
    @IBOutlet var gatherButton: WKInterfaceButton!
    @IBOutlet var postButton: WKInterfaceButton!
    
    @IBAction func gatherHeartRate(){
        //bpmLabel.setText("heartrate: ")
        let sampleType: Set<HKSampleType> = [HKSampleType.quantityType(forIdentifier: .heartRate)!]
            
            healthStore = HKHealthStore()
            
            healthStore?.requestAuthorization(toShare: sampleType, read: sampleType, completion: {(success, error)in
                if success{
                 self.startHeartRateQuery(quantityTypeIndentifier: .heartRate)
            }
        })
        
    }
    
    
    @IBAction func postHeartRate(){
        /*let heartRate = String(Int(lastHeartRate))
        let serverURL = server + "api/v1/data/in"
        let parameters = ["bpm" : heartRate, "message" : "asd123"]
        guard let url = URL(string: serverURL) else { return }
        var postReq = URLRequest(url: url)
        postReq.httpMethod = "POST"
        postReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
        postReq.setValue("10", forHTTPHeaderField: "USER-ID")
        postReq.setValue("260bd017128857113d7e", forHTTPHeaderField: "API-KEY")
        postReq.setValue("8", forHTTPHeaderField: "DEVICE-ID")
        postReq.setValue("11", forHTTPHeaderField: "ACTIVITY-ID")
        postReq.setValue("heatbeat", forHTTPHeaderField: "TYPE")
        guard let body = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        postReq.httpBody = body
        
        let session = URLSession.shared
        session.dataTask(with: postReq) { (data, response, error) in
            if let response = response{
                print(response)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                } catch{
                    print(error)
                }
            }
        }.resume() */
        let heartrate = String(Int(lastHeartRate))
        let message = ["message":heartrate]
        
        watchSession.sendMessage(message, replyHandler: nil) { (error) in
            print(error.localizedDescription)
        }
        
    }
    override func awake(withContext context: Any?) {
           super.awake(withContext: context)
          /*
           let sampleType: Set<HKSampleType> = [HKSampleType.quantityType(forIdentifier: .heartRate)!]
           
           healthStore = HKHealthStore()
           
           healthStore?.requestAuthorization(toShare: sampleType, read: sampleType, completion: {(success, error)in
               if success{
                self.startHeartRateQuery(quantityTypeIndentifier: .heartRate)
           }
       }) */
       }
       
       override func willActivate() {
           // This method is called when watch view controller is about to be visible to user
            super.willActivate()
            watchSession = WCSession.default
            watchSession.delegate = self
            watchSession.activate()
            
        
       }
       
       override func didDeactivate() {
          
           super.didDeactivate()
           
       }
      
    
        func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
             //code
         }
        
    func session(_ session: WCSession, didReceiveMessage serverMessage: [String : Any]) {
        let serverTxt = serverMessage["message"] as! String
        server = serverTxt
        
    }
    

        
        private func startHeartRateQuery(quantityTypeIndentifier: HKQuantityTypeIdentifier){
                   let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
                   
                   let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?,HKQueryAnchor?, Error?) -> Void = {
                       query, samples, deletedObjects, queryAnchor, error in
                       
                       guard let samples = samples as? [HKQuantitySample] else {
                           return
                       }
                    self.process(samples, type: quantityTypeIndentifier)
                   }
                   let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIndentifier)!, predicate: devicePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
                   
                   query.updateHandler = updateHandler
                   
                   healthStore?.execute(query)
                   
                   
              }
        private func process(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier){
            for sample in samples {
                if type == .heartRate {
                    lastHeartRate = sample.quantity.doubleValue(for: beatCountPerMinute)
                    print("Last heart rate was: \(lastHeartRate)")
                    
            }
                
                  updateHeartRateLabel()
               // updateHeartRateSpeedLabel()
              }
            
    }
        private func updateHeartRateLabel(){
                 let heartRate = "current rate " + String(Int(lastHeartRate))
                bpmLabel.setText(heartRate)
              }
        private func updateHeartRateSpeedLabel(){
                  
              }
}
