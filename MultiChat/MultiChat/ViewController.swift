//
//  ViewController.swift
//  MultipeerExample
//
//  Created by Eyuphan Bulut on 4/5/17.
//  Copyright © 2017 Eyuphan Bulut. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCBrowserViewControllerDelegate, MCSessionDelegate {
    
    var session: MCSession!
    var peerID: MCPeerID!
    
    var browser: MCBrowserViewController!
    var assistant: MCAdvertiserAssistant!
    
    var quizNum = 0
    var quizArray = [Quiz]()
    
    @IBOutlet weak var chatWindow: UITextView!
    @IBOutlet weak var messageTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        self.peerID = MCPeerID(displayName: UIDevice.current.name)
        self.session = MCSession(peer: peerID)
        self.browser = MCBrowserViewController(serviceType: "chat", session: session)
        self.assistant = MCAdvertiserAssistant(serviceType: "chat", discoveryInfo: nil, session: session)
        
        assistant.start()
        session.delegate = self
        browser.delegate = self
        
        obtainQuizPage()
        
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        
        let msg = messageTF.text
        let dataToSend =  NSKeyedArchiver.archivedData(withRootObject: msg!)
        
        do{
            try session.send(dataToSend, toPeers: session.connectedPeers, with: .unreliable)
        }
        catch let err {
            print("Error in sending data \(err)")
        }
        
        updateChatView(newText: msg!, id: peerID)
        
    }
    
    func updateChatView(newText: String, id: MCPeerID){
        
        let currentText = chatWindow.text
        var addThisText = ""
        
        if(id == peerID){
            addThisText = "Me: " + newText + "\n"
        }
        else
        {
            addThisText = "\(id.displayName): \(newText)\n"
        }
        chatWindow.text = currentText! + addThisText
        
    }
    
    @IBAction func connect(_ sender: UIButton) {
        
        present(browser, animated: true, completion: nil)
        
    }
    
    
    //**********************************************************
    // required functions for MCBrowserViewControllerDelegate
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        // Called when the browser view controller is dismissed
        dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        // Called when the browser view controller is cancelled
        dismiss(animated: true, completion: nil)
    }
    //**********************************************************
    
    
    
    
    //**********************************************************
    // required functions for MCSessionDelegate
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        // this needs to be run on the main thread
        DispatchQueue.main.async(execute: {
            
            if let receivedString = NSKeyedUnarchiver.unarchiveObject(with: data) as? String{
                self.updateChatView(newText: receivedString, id: peerID)
            }
            
        })
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
        // Called when a connected peer changes state (for example, goes offline)
        
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
            
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
            
        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")
        }
        
    }
    //**********************************************************
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func obtainQuizPage() {
        var quizQuestions = [Question]()
        quizNum = quizNum + 1
        let url = URL(string: "http://www.people.vcu.edu/~ebulut/jsonFiles/quiz\(quizNum).json")
        

        // had to change info.plist to use http since ios wants to use https only
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            if error != nil {
                print(error!)
            } else {
            
            do {
                
                let data = data
                if let json = try JSONSerialization.jsonObject(with: data!) as? [String: Any] {
                print(json)
                let topic = json["topic"] as! String
                let count = json["numberOfQuestions"] as! Int
                
                if let question = json["questions"] as? [[String: Any]] {
                    for quest in question {
                        let qNum = quest["number"] as! Int
                        let sentence = quest["questionSentence"] as! String
                        // works better to store as dictionary 
                        let opt = quest["options"] as! [String: String]
                        let correct = quest["correctOption"] as! String
                        
                        quizQuestions.append(Question(sentence: sentence, poss: opt, correct: correct, qNum: qNum))
                    }
                }
                
                
                self.quizArray.append(Quiz(qArray: quizQuestions, top: topic, numQ: count))
                }
                
            } catch {
                print("encountered error")
            }
                }
    
    
    
            }.resume()
    }
}

