//
//  ViewController.swift
//  PeerChat
//
//  Created by Farah Nedjadi on 11/06/2018.
//  Copyright © 2018 mti. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class PCViewController: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    var appDelegate: AppDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.appDelegate = UIApplication.shared.delegate as? AppDelegate
        self.appDelegate?.pcManager?.delegate = self
        self.appDelegate?.pcManager?.browser?.startBrowsingForPeers()
        self.appDelegate?.pcManager?.advertiser?.startAdvertisingPeer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func advertisingSwitchAction(_ sender: UISwitch) {
        if sender.isOn {
            self.appDelegate?.pcManager?.advertiser?.stopAdvertisingPeer()
        } else {
            self.appDelegate?.pcManager?.advertiser?.startAdvertisingPeer()
        }
    }
}

extension PCViewController: PCManagerDelegate {
    func updatefoundedPeer() {
        self.tableview.reloadData()
    }
    
    func invitationWasReceived(fromPeer: String) {
        let alert = UIAlertController(title: "", message: "\(fromPeer) wants to start a chat with you", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: { (action) in
            self.appDelegate?.pcManager?.invitationHandler?(true, self.appDelegate?.pcManager?.session)
        }))
        alert.addAction(UIAlertAction.init(title: "Deny", style: .cancel, handler: { (action) in
            self.appDelegate?.pcManager?.invitationHandler?(false, nil)
        }))
        
        OperationQueue.main.addOperation {
            self.present(alert, animated: true)
        }
    }
    
    func connectedWithPeer(peerID: MCPeerID) {
        OperationQueue.main.addOperation {
            self.performSegue(withIdentifier: "idChatSegue", sender: self)
        }
    }
    
    func connectingWithPeer(peerID: MCPeerID) {
        // TODO
    }
}

extension PCViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.appDelegate?.pcManager?.foundPeers.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "idPeerCell") as? PCContactTableViewCell else {
            return UITableViewCell()
        }
        
        let name = self.appDelegate?.pcManager?.foundPeers[indexPath.row].displayName ?? "N/A"
        cell.nameLabel.text = name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedPeer = self.appDelegate?.pcManager?.foundPeers[indexPath.row],
            let session = self.appDelegate?.pcManager?.session else {
            return
        }
        
        self.appDelegate?.pcManager?.browser?.invitePeer(selectedPeer, to: session, withContext: nil, timeout: 20)
    }
}
