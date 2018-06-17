//
//  PCChatViewController.swift
//  PeerChat
//
//  Created by Farah Nedjadi on 11/06/2018.
//  Copyright © 2018 mti. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class PCChatViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var bottomTextViewConstraint: NSLayoutConstraint!
    
    var appDelegate : AppDelegate?
    var messagesArray: [PCChatMessage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        navigationController?.navigationBar.tintColor = UIColor.black
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.handleNotification),
                                               name: NSNotification.Name("receivedPCDataNotification"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardShowNotification(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardHideNotification(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.didEnterBackground(notification:)),
                                               name: NSNotification.Name.UIApplicationDidEnterBackground,
                                               object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateTableview() {
        self.tableView.reloadData()
        
        if self.tableView.contentSize.height > self.tableView.frame.size.height {
            tableView.scrollToRow(at: IndexPath.init(row: messagesArray.count - 1, section: 0), at: .bottom, animated: true)
        }
    }
    
    @objc public func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func handleNotification(notification: NSNotification) {
        guard let received = notification.object as? PCDatasFromPeer else {
            return
        }
        
        if let data = received.data {
            let fromPeer = received.fromPeer
            
            let dictionary = NSKeyedUnarchiver.unarchiveObject(with: data) as? Dictionary<String, String>
            if let msg = dictionary?["message"] {
                if msg != "_end_chat_" {
                    let messages = PCChatMessage(sender: fromPeer.displayName, message: msg)
                    messagesArray.append(messages)
                    OperationQueue.main.addOperation {
                        self.updateTableview()
                    }
                } else {
                    let alert = UIAlertController(title: "", message: "\(fromPeer.displayName) ended this chat", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        self.appDelegate?.pcManager?.session?.disconnect()
                        self.dismissKeyboard()
                        self.dismiss(animated: true, completion: nil)
                    }))
                    
                    OperationQueue.main.addOperation {
                        self.present(alert, animated: true)
                    }
                }
            }
        }
    }
    
    @objc func keyboardShowNotification(notification: Notification) {
        if let userinfo = notification.userInfo {
            if let keyboardFrame = userinfo[UIKeyboardFrameEndUserInfoKey] as? NSValue,
                let duration = userinfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval {
                UIView.animate(withDuration: duration) {
                    self.bottomTextViewConstraint.constant = -keyboardFrame.cgRectValue.height
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    @objc func keyboardHideNotification(notification: Notification) {
        if let userinfo = notification.userInfo {
            if let duration = userinfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval {
                UIView.animate(withDuration: duration) {
                    self.bottomTextViewConstraint.constant = 0
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    @objc func didEnterBackground(notification: Notification) {
        self.endChatButtonAction(notification)
        self.appDelegate?.pcManager?.foundPeers = []
    }
    
    @IBAction func endChatButtonAction(_ sender: Any) {
        let message: [String: String] = ["message": "_end_chat_"]
        if let peer = self.appDelegate?.pcManager?.session?.connectedPeers.first {
            let sended = self.appDelegate?.pcManager?.send(withDatas: message, toPeer: peer) ?? false
            if sended {
                self.dismiss(animated: true) {
                    self.appDelegate?.pcManager?.session?.disconnect()
                }
            }
        }
    }
    
    @IBAction func sendButtonAction(_ sender: Any) {
        self.sendMessage()
    }
    
    
    func sendMessage() {
        if let text = self.textField.text {
            if text != "" {
                let message: [String: String] = ["message": text]
                if let peer = self.appDelegate?.pcManager?.session?.connectedPeers.first {
                    let sended = self.appDelegate?.pcManager?.send(withDatas: message, toPeer: peer) ?? false
                    if sended {
                        let newMessage = PCChatMessage(sender: "self", message: text)
                        self.messagesArray.append(newMessage)
                        self.updateTableview()
                    }
                }
            }
        }
        self.textField.text = ""
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PCChatViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messagesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "idChatCell") else {
            return UITableViewCell()
        }
        
        let currentMessage = messagesArray[indexPath.row]
        let sender = currentMessage.sender
        let message = currentMessage.message
        
        var senderLabelText: String
        var senderColor: UIColor
        
        if sender == "self" {
            senderLabelText = "Me"
            senderColor = UIColor(red:0.39, green:0.05, blue:0.69, alpha:1.0)
        } else {
            senderLabelText = "\(sender)"
            senderColor = UIColor(red:0.29, green:0.56, blue:0.89, alpha:1.0)
        }
        
        cell.detailTextLabel?.text = senderLabelText
        cell.detailTextLabel?.textColor = senderColor
        cell.textLabel?.text = message
        
        return cell
    }
}

extension PCChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.sendMessage()
        return true
    }
}
