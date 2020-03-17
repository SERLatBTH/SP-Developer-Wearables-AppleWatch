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
    
    var controlOk = ""
    var checkOk = ""
    var sendOk = ""
    
    var watchSession : WCSession! = nil
    var lastHeartRate = ""
    
   
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
           /* if let response = response {
                print(response)
            }*/
          if let data = data {
                    do {
                       let posts = try JSONDecoder().decode(activityStatus.self, from: data)
                        
                        
                        if posts.success == true{
                            self.checkOk = "Check Ok"
                        }
                        else{
                            self.checkOk = "Check Failed"
                            }
                    }
                        catch{
                            print(error)
            
                    }
            }
            
        }.resume()
        jsonInfo.text = checkOk
    }
    
    @IBAction func displayHeartRate(_ sender: Any){
        jsonInfo.text = "current heartrate: " + lastHeartRate
        
    }
    @IBAction func postTapped(_ sender: Any){
        let serverURL = serverField.text! + "api/v1/activity/control"
        let deviceID = deviceField.text
        let parameters = ["device_id" : deviceID, "action" : "start", "type":"code review", "repo":"torvalds/linux", "commit": "asd123"]
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
            /*if let response = response{
                print(response)
            } */
            if let data = data {
                do {
                   let posts = try JSONDecoder().decode(activityControl.self, from: data)
                    
                    
                    if posts.success == true{
                        self.controlOk = "Post ok!"
                    }
                    else{
                         self.controlOk = "Post failed!"
                        }
                }
                    
                    catch{
                        print(error)
        
                }
                                   
            
            }
            
        }.resume()
              
        jsonInfo.text = controlOk
        
        
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
        postReq.setValue("11", forHTTPHeaderField: "ACTIVITY-ID")
        postReq.setValue("heatbeat", forHTTPHeaderField: "TYPE")
        guard let body = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        postReq.httpBody = body
        
        let session = URLSession.shared
        session.dataTask(with: postReq) {(data, response, error) in
            /*if let response = response{
                print(response)
            }*/
            if let data = data {
                do {
                    let posts = try JSONDecoder().decode(postData.self, from: data)
                    if posts.success == true {
                        self.sendOk = "Data posted successfully!"
                    }
                    else{
                        self.sendOk = "Data could not be sent..."
                    }
                    
                    }
                    catch{
                        print(error)
                    }
                }
                
            
        }.resume()
        jsonInfo.text = sendOk
        
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

