//
//  PCMultipeerConnectivityManager + Session.swift
//  PeerChat
//
//  Created by Farah Nedjadi on 13/06/2018.
//  Copyright © 2018 mti. All rights reserved.
//

import Foundation
import MultipeerConnectivity

extension PCMultipeerConnectivityManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            delegate?.connectedWithPeer(peerID: peerID)
        case .connecting:
            delegate?.connectingWithPeer(peerID: peerID)
        default:
            return
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let datas = PCDatasFromPeer(data: data, fromPeer: peerID)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "receivedPCDataNotification"), object: datas)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }
}
