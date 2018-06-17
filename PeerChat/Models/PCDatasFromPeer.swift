//
//  PCDatasFromPeer.swift
//  PeerChat
//
//  Created by Farah Nedjadi on 13/06/2018.
//  Copyright © 2018 mti. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class PCDatasFromPeer: NSObject {
    var data : Data?
    var fromPeer : MCPeerID
    
    init(data: Data, fromPeer: MCPeerID) {
        self.data = data
        self.fromPeer = fromPeer
    }
}
