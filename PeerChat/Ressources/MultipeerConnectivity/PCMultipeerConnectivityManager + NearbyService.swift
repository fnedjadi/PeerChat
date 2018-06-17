//
//  PCMultipeerConnectivityManager + NearbyService.swift
//  PeerChat
//
//  Created by Farah Nedjadi on 13/06/2018.
//  Copyright © 2018 mti. All rights reserved.
//

import Foundation
import MultipeerConnectivity

extension PCMultipeerConnectivityManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        self.foundPeers.append(peerID)
        delegate?.updatefoundedPeer()
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        if let index = foundPeers.index(of: peerID) {
            foundPeers.remove(at: index)
        }
        delegate?.updatefoundedPeer()
    }
}

extension PCMultipeerConnectivityManager : MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        self.invitationHandler = invitationHandler
        delegate?.invitationWasReceived(fromPeer: peerID.displayName)
    }
}
