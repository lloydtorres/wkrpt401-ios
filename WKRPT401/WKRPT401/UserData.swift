//
//  UserData.swift
//  WKRPT401
//
//  Created by Lloyd Torres on 2016-12-22.
//  Copyright © 2016 Lloyd Torres. All rights reserved.
//

import Gloss

struct UserData: Encodable {
    let name: String
    let token: String
    let level: Int
    let personality: [PersonalityData]?
    
    func toJSON() -> JSON? {
        return jsonify([
            "name" ~~> self.name,
            "token" ~~> self.token,
            "level" ~~> self.level,
            "personality" ~~> self.personality?.toJSONArray()
        ])
    }
}
