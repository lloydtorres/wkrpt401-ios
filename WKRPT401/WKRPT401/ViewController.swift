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
    
    // MARK: gRPC Calls
    let userManager = WPUserManager(host: ViewController.grpcHost)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set non-HTTPS gRPC requests
        GRPCCall.useInsecureConnections(forHost: ViewController.grpcHost)
    }

    @IBAction func sendDataOnGrpc(_ sender: UIButton) {
        // Create gRPC model
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
        
        userManager.getBestPersonality(withRequest: grpcEmilia) { (response: WPUserResponse?, error: Error?) in
            if let res = response {
                print("RESPONSE: \(res)")
                self.showAlert(res.response)
            } else if let err = error {
                print("ERROR: \(err)")
                self.showAlert(err.localizedDescription)
            }
        }
    }

    @IBAction func sendDataOnRestApi(_ sender: UIButton) {
        // Create REST model
        let kindnessPersonality = PersonalityData(name: self.emiliaKindnessKey, amount: self.emiliaKindnessAmount)
        let magicPersonality = PersonalityData(name: self.emiliaMagicKey, amount: self.emiliaMagicAmount)
        let personalityData = [kindnessPersonality, magicPersonality]
        let restEmilia = UserData(name: self.emiliaName, token: self.emiliaToken, level: self.emiliaLevel, personality: personalityData)
        let jsonEmilia = restEmilia.toJSON()
        
        Alamofire.request(ViewController.restHost, method: .post, parameters: jsonEmilia, encoding: JSONEncoding.default, headers: nil).validate().responseJSON { response in
            switch response.result {
            case .success(let response):
                if let userResponse = UserResponse(json: response as! Gloss.JSON) {
                    print("RESPONSE: \(userResponse)")
                    self.showAlert(userResponse.response)
                } else {
                    self.showAlert("Whoops, something wrong happened with JSON deserialization.")
                }
            case .failure(let error):
                print("ERROR: \(error)")
                self.showAlert(error.localizedDescription)
            }
        }
    }
    
    func showAlert(_ message: String) {
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
