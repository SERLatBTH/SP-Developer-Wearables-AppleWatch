//
//  ViewController.swift
//  projectteli18
//
//  Created by Space Lab on 2020-03-04.
//  Copyright © 2020 Space Lab. All rights reserved.
//

import UIKit
import HealthKit
import WatchConnectivity



struct postData: Decodable {
    let success: Bool
    let errors: [Int]
    
}

struct activityStatus : Decodable{
    let success: Bool
    let errors: [Int]
    let activity_id: Int
}

struct activityControl : Decodable{
    let success: Bool
    let errors: [Int]
    let activity_id: Int
}
class ViewController: UIViewController, WCSessionDelegate {

    @IBOutlet var postButton: UIButton!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var getButton: UIButton!
    @IBOutlet var userField: UITextField!
    @IBOutlet var deviceField: UITextField!
    @IBOutlet var serverField: UITextField!
    @IBOutlet var APIField: UITextField!
    @IBOutlet var jsonInfo: UITextView!
    
   
    var watchSession : WCSession! = nil
    var lastHeartRate = ""
    var activityId = 0
    var activityRunning = false
  
    
   
    @IBAction func getTapped(_ sender: Any) {
        
        let serverURL = serverField.text! + "api/v1/activity/status"
        guard let url = URL(string: serverURL)else{ return }
        var getReq = URLRequest(url: url)
        getReq.httpMethod = "GET"
        getReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
        getReq.setValue(userField.text, forHTTPHeaderField: "USER-ID")
        getReq.setValue(APIField.text, forHTTPHeaderField: "API-KEY")
        let session = URLSession.shared
        session.dataTask(with: getReq) { (data, response, error) in
          if let data = data {
                    do {
                       let posts = try JSONDecoder().decode(activityStatus.self, from: data)
                        
                        
                       if posts.success == true{
                        if posts.activity_id != 0 {
                        DispatchQueue.main.async {
                            self.jsonInfo.text = "Activity is running successfully. Activity ID: " + String(self.activityId)
                        }
                        }
                        else{
                            DispatchQueue.main.async {
                                self.jsonInfo.text = "No activity is currently running"
                            }
                        }
                       }
                        else{
                        DispatchQueue.main.async {
                            self.jsonInfo.text = self.handleError(code: posts.errors[0])
                        }
                            
                            }
                    }
                        catch{
                            DispatchQueue.main.async {
                                self.jsonInfo.text = "Check unsuccessful, check network connection"
                            }
                            print(error)
                            
            }
            }
            
        }.resume()
       
    }
    
    @IBAction func displayHeartRate(_ sender: Any){
        jsonInfo.text = "current heartrate: " + lastHeartRate
        
    }
    
    func startActivity(start: Bool) -> String {
        if start == true{
            return "stop"
        }
        else{
            return "start"
        }
    }
    @IBAction func postTapped(_ sender: Any){
        //var activityRunning = false
        let serverURL = serverField.text! + "api/v1/activity/control"
        let deviceID = deviceField.text
        let parameters = ["device_id" : deviceID, "action" : startActivity(start: activityRunning), "type":"code review", "repo":"torvalds/linux", "commit": "asd123"]
        guard let url = URL(string: serverURL)else { return }
        var postReq = URLRequest(url: url)
        postReq.httpMethod = "POST"
        postReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
        postReq.setValue(userField.text, forHTTPHeaderField: "USER-ID")
        postReq.setValue(APIField.text, forHTTPHeaderField: "API-KEY")
        guard let body = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        postReq.httpBody = body
        
        let session = URLSession.shared
        session.dataTask(with: postReq) { (data, response, error) in
           
            if let data = data {
                do {
                   let posts = try JSONDecoder().decode(activityControl.self, from: data)
                    if posts.success == true{
                        
                        DispatchQueue.main.async {
                            if self.activityRunning == true{
                                self.activityId = posts.activity_id
                                self.jsonInfo.text = "Activity is started successfully. Activity ID: " + String(self.activityId)
                                }
                            else{
                                self.activityId = posts.activity_id
                                self.jsonInfo.text = "Activity has been stopped"
                            }
                        }
                            
                        
                    }
                    else{
                        DispatchQueue.main.async {
                        self.jsonInfo.text = self.handleError(code: posts.errors[0])
                        }
                    }
                }
                    catch{
                        DispatchQueue.main.async {
                            self.jsonInfo.text = "Post unsuccessful, check network connection"
                        }
                        print(error)
                }
            }
        }.resume()
        if activityRunning == false && activityId != 0 {
            activityRunning = true
            postButton.setTitle("Stop Activity", for: .normal)
        }
        else{
            activityRunning = false
            postButton.setTitle("Start Activity", for: .normal)
        }
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        let heartRateText = message["message"] as! String
        lastHeartRate = heartRateText
    }
    
    @IBAction func sendTapped(_ sender: Any){
      
        let heartRate = lastHeartRate
        let serverURL = serverField.text! + "api/v1/data/in"
        let parameters = ["bpm" : heartRate, "message" : "asd123"]
        guard let url = URL(string: serverURL) else { return }
        var postReq = URLRequest(url: url)
        postReq.httpMethod = "POST"
        postReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
        postReq.setValue(userField.text, forHTTPHeaderField: "USER-ID")
        postReq.setValue(APIField.text, forHTTPHeaderField: "API-KEY")
        postReq.setValue(deviceField.text, forHTTPHeaderField: "DEVICE-ID")
        postReq.setValue(String(activityId), forHTTPHeaderField: "ACTIVITY-ID")
        postReq.setValue("heatbeat", forHTTPHeaderField: "TYPE")
        guard let body = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        postReq.httpBody = body
        
        let session = URLSession.shared
        session.dataTask(with: postReq) {(data, response, error) in
            if let data = data {
                do {
                    let jsonPost = try JSONDecoder().decode(postData.self, from: data)
                 
                   if jsonPost.success == true {
                    
                    DispatchQueue.main.async {
                        if (self.lastHeartRate != "" && self.activityRunning == true){
                        self.jsonInfo.text = "Data posted successfully"
                        }
                        else {
                            self.jsonInfo.text = "Activity Not running or no heartrate to send"
                        }
                    }
                       
                        print(jsonPost)
                        
                    }
                    else{
                    DispatchQueue.main.async {
                        self.jsonInfo.text = self.handleError(code: jsonPost.errors[0])
                        print(jsonPost)
                    }
                    }
                    
                    }
                    catch{
                        DispatchQueue.main.async {
                            self.jsonInfo.text = "Send unsuccessful, check network connection"
                        }
                        print(error)
                    }
                }
                
            
        }.resume()
       
        
    }
    
    func handleError(code: Int) -> String {
        switch code {
        case 100:
            return "Error code 100: Invalid API key or user ID"
        case 101:
            return "Error code 101: Invalid API permissions"
        case 200:
            return "Error code 200: No activity available"
        case 201:
            return "Error code 201: Wrong activity_id in request"
        case 300:
            return "Error code 300: General server error"
        case 301:
            return "Error code 301: Invalid parameter used"
        case 302:
            return "Error code 302: Malformed request"
        case 303:
            return "Error code 303: Device doesnt belong to user"
        case 304:
            return "Error code 304: device_id doesn't exist"
        case 400:
            return "Error code 400: JSON not valid"
        default:
            return "Error"
        }
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        watchSession = WCSession.default
        watchSession.delegate = self
        watchSession.activate()
        
        
        userField.delegate = self
        deviceField.delegate = self
        serverField.delegate = self
        APIField.delegate = self
    }
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //code
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        //kod
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        //kod
    }
}

extension ViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

