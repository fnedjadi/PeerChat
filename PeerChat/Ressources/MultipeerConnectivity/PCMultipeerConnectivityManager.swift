//
//  PCMultipeerConnectivityManager.swift
//  PeerChat
//
//  Created by Farah Nedjadi on 11/06/2018.
//  Copyright © 2018 mti. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol PCManagerDelegate {
    func updatefoundedPeer()
    func invitationWasReceived(fromPeer: String)
    func connectedWithPeer(peerID: MCPeerID)
    func connectingWithPeer(peerID: MCPeerID)
}

class PCMultipeerConnectivityManager: NSObject {
    var delegate: PCManagerDelegate?
    
    var session: MCSession?
    var peer: MCPeerID?
    var browser: MCNearbyServiceBrowser?
    var advertiser: MCNearbyServiceAdvertiser?
    
    var foundPeers = [MCPeerID]()
    var invitationHandler: ((Bool, MCSession?)->Void)?
    
    override init() {
        super.init()
        
        self.peer = MCPeerID(displayName: UIDevice.current.name)
        
        if let peer = self.peer {
            // Init session
            self.session = MCSession(peer: peer)
            self.session?.delegate = self
            // Init browser
            self.browser = MCNearbyServiceBrowser(peer: peer, serviceType: "mti-peerchat")
            self.browser?.delegate = self
            // Init advertiser
            self.advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: "mti-peerchat")
            self.advertiser?.delegate = self
        }
    }
    
    func send(withDatas dictionary: Dictionary<String, String>, toPeer targetPeer: MCPeerID) -> Bool {
        let data = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        let peers = [targetPeer]

        do {
            try session?.send(data, toPeers: peers, with: .reliable)
            return true
        } catch _ {
            return false
        }
    }
}
