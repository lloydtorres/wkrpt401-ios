//
//  UserResponse.swift
//  WKRPT401
//
//  Created by Lloyd Torres on 2016-12-22.
//  Copyright © 2016 Lloyd Torres. All rights reserved.
//

import Gloss

struct UserResponse: Decodable {
    let response: String
    
    init?(json: JSON) {
        guard let response: String = "response" <~~ json else {
            return nil
        }
        
        self.response = response
    }
}
