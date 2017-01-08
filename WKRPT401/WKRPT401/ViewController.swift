//
//  ViewController.swift
//  WKRPT401
//
//  Created by Lloyd Torres on 2016-12-20.
//  Copyright © 2016 Lloyd Torres. All rights reserved.
//

import UIKit
import GRPCClient
import wkrpt401_grpc
import Alamofire
import Gloss

class ViewController: UIViewController {
    
    // MARK: Static constants
    static let baseHost = "0.0.0.0"
    static let grpcHost = ViewController.baseHost + ":50051"
    static let restHost = "http://" + ViewController.baseHost + ":50069/api/best-personality"
    
    // MARK: User "Emilia" data
    let emiliaName = "Emilia"
    let emiliaToken = "best-girl-01"
    let emiliaLevel = 9
    let emiliaKindnessKey = "kindness"
    let emiliaKindnessAmount = 10
    let emiliaMagicKey = "magic"
    let emiliaMagicAmount = 7
    
    // MARK: gRPC Objects
    let userManager = WPUserManager(host: ViewController.grpcHost)
    
    // MARK: Request counters
    var grpcRequests = 0
    var restfulApiRequests = 0

    // MARK: Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set non-HTTPS gRPC requests
        GRPCCall.useInsecureConnections(forHost: ViewController.grpcHost)
    }
    
    // MARK: Helper functions
    // Create gRPC model
    func getGrpcEmiliaModel() -> WPUserData {
        let grpcEmilia = WPUserData()
        grpcEmilia.name = self.emiliaName
        grpcEmilia.token = self.emiliaToken
        grpcEmilia.level = UInt32(self.emiliaLevel)
        
        let grpcKindness = WPPersonalityData()
        grpcKindness.name = self.emiliaKindnessKey
        grpcKindness.amount = UInt32(self.emiliaKindnessAmount)
        let grpcMagic = WPPersonalityData()
        grpcMagic.name = self.emiliaMagicKey
        grpcMagic.amount = UInt32(self.emiliaMagicAmount)
        let grpcPersonality = NSMutableArray()
        grpcPersonality.add(grpcKindness)
        grpcPersonality.add(grpcMagic)
        grpcEmilia.personalityArray = grpcPersonality
        
        return grpcEmilia
    }
    
    // Create REST model
    func getJsonEmiliaModel() -> JSON? {
        let kindnessPersonality = PersonalityData(name: self.emiliaKindnessKey, amount: self.emiliaKindnessAmount)
        let magicPersonality = PersonalityData(name: self.emiliaMagicKey, amount: self.emiliaMagicAmount)
        let personalityData = [kindnessPersonality, magicPersonality]
        let restEmilia = UserData(name: self.emiliaName, token: self.emiliaToken, level: self.emiliaLevel, personality: personalityData)
        let jsonEmilia = restEmilia.toJSON()
        
        return jsonEmilia
    }
    
    func showAlert(_ message: String) {
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func getUnixTimeInSeconds() -> TimeInterval {
        return Date().timeIntervalSince1970
    }
    
    func getLatencyAlert(startTime: TimeInterval, endTime: TimeInterval) {
        let latencyInMs = (endTime - startTime) * 1000;
        self.showAlert("Latency: \(latencyInMs) ms")
    }

    // MARK: Actions
    @IBAction func sendSingleRequestOnGrpc(_ sender: UIButton) {
        let startUnixTime = self.getUnixTimeInSeconds()
        
        userManager.getBestPersonality(withRequest: self.getGrpcEmiliaModel()) { (response: WPUserResponse?, error: Error?) in
            if let res = response {
                print("RESPONSE: \(res)")
                let endUnixTime = self.getUnixTimeInSeconds()
                self.getLatencyAlert(startTime: startUnixTime, endTime: endUnixTime)
            } else if let err = error {
                print("ERROR: \(err)")
                self.showAlert(err.localizedDescription)
            }
        }
    }

    @IBAction func sendSingleRequestOnRestfulApi(_ sender: UIButton) {
        let startUnixTime = self.getUnixTimeInSeconds()
        
        Alamofire.request(ViewController.restHost, method: .post, parameters: self.getJsonEmiliaModel(), encoding: JSONEncoding.default, headers: nil).validate().responseJSON { response in
            switch response.result {
            case .success(let response):
                if let userResponse = UserResponse(json: response as! Gloss.JSON) {
                    print("RESPONSE: \(userResponse)")
                    let endUnixTime = self.getUnixTimeInSeconds()
                    self.getLatencyAlert(startTime: startUnixTime, endTime: endUnixTime)
                } else {
                    self.showAlert("Whoops, something wrong happened with JSON deserialization.")
                }
            case .failure(let error):
                print("ERROR: \(error)")
                self.showAlert(error.localizedDescription)
            }
        }
    }
    
    @IBAction func sendHundredRequestsOnGrpc(_ sender: UIButton) {
        self.grpcRequests = 0
        let startUnixTime = self.getUnixTimeInSeconds()
        self.sendHundredRequestsOnGrpc(startTime: startUnixTime)
    }
    
    func sendHundredRequestsOnGrpc(startTime: TimeInterval) {
        userManager.getBestPersonality(withRequest: self.getGrpcEmiliaModel()) { (response: WPUserResponse?, error: Error?) in
            if let res = response {
                if self.grpcRequests < 100 {
                    self.grpcRequests += 1
                    self.sendHundredRequestsOnGrpc(startTime: startTime)
                } else {
                    print("RESPONSE: \(res)")
                    let endUnixTime = self.getUnixTimeInSeconds()
                    self.getLatencyAlert(startTime: startTime, endTime: endUnixTime)
                }
            } else if let err = error {
                print("ERROR: \(err)")
                self.showAlert(err.localizedDescription)
            }
        }
    }
    
    @IBAction func sendHundredRequestsOnRestfulApi(_ sender: UIButton) {
        self.restfulApiRequests = 0
        let startUnixTime = self.getUnixTimeInSeconds()
        self.sendHundredRequestsOnRestfulApi(startTime: startUnixTime)
    }
    
    func sendHundredRequestsOnRestfulApi(startTime: TimeInterval) {
        Alamofire.request(ViewController.restHost, method: .post, parameters: self.getJsonEmiliaModel(), encoding: JSONEncoding.default, headers: nil).validate().responseJSON { response in
            switch response.result {
            case .success(let response):
                if let userResponse = UserResponse(json: response as! Gloss.JSON) {
                    if self.restfulApiRequests < 100 {
                        self.restfulApiRequests += 1
                        self.sendHundredRequestsOnRestfulApi(startTime: startTime)
                    } else {
                        print("RESPONSE: \(userResponse)")
                        let endUnixTime = self.getUnixTimeInSeconds()
                        self.getLatencyAlert(startTime: startTime, endTime: endUnixTime)
                    }
                } else {
                    self.showAlert("Whoops, something wrong happened with JSON deserialization.")
                }
            case .failure(let error):
                print("ERROR: \(error)")
                self.showAlert(error.localizedDescription)
            }
        }
    }
}
