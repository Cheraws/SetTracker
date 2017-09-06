//
//  Item.swift
//  FairHelper
//
//  Created by Robert Chang on 12/6/16.
//  Copyright © 2016 Robert. All rights reserved.
//

import Foundation


class Item: NSObject, NSCoding {
    
    var uuid: String = UUID().uuidString
    var name: String = ""
    
    // MARK: -
    // MARK: Initialization
    init(name: String) {
        super.init()
        
        self.name = name
    }
    
    
    // MARK: -
    // MARK: NSCoding Protocol
    required init?(coder decoder: NSCoder) {
        super.init()
        
        if let archivedUuid = decoder.decodeObject(forKey: "uuid") as? String {
            uuid = archivedUuid
        }

        if let archivedName = decoder.decodeObject(forKey: "name") as? String {
            name = archivedName
        }

    }
    
    func encode(with coder: NSCoder) {
        coder.encode(uuid, forKey: "uuid")
        coder.encode(name, forKey: "name")
    }
    
}
