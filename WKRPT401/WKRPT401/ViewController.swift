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

class ViewController: UIViewController {
    
    // MARK: Static constants
    static let baseHost = "192.168.0.120"
    static let grpcHost = ViewController.baseHost + ":50051"
    static let restHost = ViewController.baseHost + ":50069"
    
    // MARK: User "Emilia" data
    let emiliaName = "Emilia"
    let emiliaToken = "best-girl-01"
    let emiliaLevel = 9
    let emiliaKindnessKey = "kindness"
    let emiliaKindnessAmount = 10
    let emiliaMagicKey = "magic"
    let emiliaMagicAmount = 7

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
        
        
    }

    @IBAction func sendDataOnRestApi(_ sender: UIButton) {
        // Create REST model
        let kindnessPersonality = PersonalityData(name: self.emiliaKindnessKey, amount: self.emiliaKindnessAmount)
        let magicPersonality = PersonalityData(name: self.emiliaMagicKey, amount: self.emiliaMagicAmount)
        let personalityData = [kindnessPersonality, magicPersonality]
        let restEmilia = UserData(name: self.emiliaName, token: self.emiliaToken, level: self.emiliaLevel, personality: personalityData)
    }
}

