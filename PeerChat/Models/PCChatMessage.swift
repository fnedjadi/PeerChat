//
//  PCChatMessage.swift
//  PeerChat
//
//  Created by Farah Nedjadi on 12/06/2018.
//  Copyright © 2018 mti. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class PCChatMessage: NSObject {
    var sender: String
    var message: String
    
    init(sender: String, message: String) {
        self.sender = sender
        self.message = message
    }
}
