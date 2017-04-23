import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCBrowserViewControllerDelegate, MCSessionDelegate {
    
    var session: MCSession!
    var peerID: MCPeerID!
    
    var browser: MCBrowserViewController!
    var assistant: MCAdvertiserAssistant!
    
    @IBOutlet weak var SingleOrMulti: UISegmentedControl!
    var quizNum = 0
    var quizArray = [Quiz]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        self.peerID = MCPeerID(displayName: UIDevice.current.name)
        self.session = MCSession(peer: peerID)
        
        self.browser = MCBrowserViewController(serviceType: "multichat", session: session)
        self.assistant = MCAdvertiserAssistant(serviceType: "multichat", discoveryInfo: nil, session: session)
        
        
        assistant.start()
        session.delegate = self
        browser.delegate = self
        browser.maximumNumberOfPeers = 4
        
        
        
        obtainQuizPage()
        
    }
    @IBAction func connect(_ sender: Any) {
        present(browser, animated: true, completion: nil)

    }
    
    @IBAction func startQuiz(_ sender: Any) {
        
        // we need to separate multi from single
        
        print("peers connected: \(session.connectedPeers.count)")
        
        if SingleOrMulti.selectedSegmentIndex == 0 {
            performSegue(withIdentifier: "quiz", sender: nil)
        }
        
        else if session.connectedPeers.count >= 1 && SingleOrMulti.selectedSegmentIndex == 1 {
            let send = ["segue": "quiz"] as [String: Any]
            let data = NSKeyedArchiver.archivedData(withRootObject: send)
            do {
                try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            } catch {
                print("sending error")
            }
            performSegue(withIdentifier: "quiz", sender: nil)
        }
        else{
            alertUser(alert: "Get some friends, need atleast two users for this option!")
        }
        
    }
    
    func alertUser(alert: String) {
        
        let alert = UIAlertController(title: "Invalid Option", message: alert, preferredStyle: .alert)
        let myAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(myAction)
        present(alert, animated: true, completion: nil)
        
    }
    // we need to pass this session on over to the quiz, to keep our connections
    // to check via terminal if connections (browse for services) are available or being advertised type
    //
    // dns-sd -B _services._dns-sd._udp
    //
    // everything looks fine on this end.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "quiz" {
            if let multi = segue.destination as? QuizController {
                multi.session = session as MCSession
                multi.quizArray = self.quizArray
            }
        }
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        // this needs to be run on the main thread
        DispatchQueue.main.async(execute: {
            
            if let info = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: Any]{
                //self.updateChatView(newText: receivedString, id: peerID)
                if let seg = info["segue"] as? String {
                self.performSegue(withIdentifier: seg, sender: nil)
                }
            }
            
        })
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID){
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
        // Called when a connected peer changes state (for example, goes offline)
        
        
        
        switch state {
        case MCSessionState.connected:
//            if session.connectedPeers.count == 4 {
//                assistant.stop()
//                browser.browser?.stopBrowsingForPeers()
//            }
            print("Connected: \(peerID.displayName)")
            
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
            
        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")
//            if session.connectedPeers.count <= 3 {
//                self.assistant.start()
//                self.browser.browser?.startBrowsingForPeers()
            
//            }
            
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

