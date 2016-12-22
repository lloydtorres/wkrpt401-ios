//
//  PersonalityData.swift
//  WKRPT401
//
//  Created by Lloyd Torres on 2016-12-22.
//  Copyright © 2016 Lloyd Torres. All rights reserved.
//

import Gloss

struct PersonalityData: Encodable {
    let name: String
    let amount: Int
    
    func toJSON() -> JSON? {
        return jsonify([
            "name" ~~> self.name,
            "amount" ~~> self.amount
        ])
    }
}
