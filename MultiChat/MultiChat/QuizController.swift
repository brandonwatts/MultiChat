//
//  QuizController.swift
//  MultiChat
//
//  Created by Brandon Watts on 4/22/17.
//  Copyright © 2017 Brandon Watts. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import CoreMotion


class QuizController: UIViewController, MCBrowserViewControllerDelegate, MCSessionDelegate {
    
    /*** Answer Buttons ***/
    @IBOutlet weak var A_Button: UIButton!
    @IBOutlet weak var B_Button: UIButton!
    @IBOutlet weak var C_Button: UIButton!
    @IBOutlet weak var D_Button: UIButton!
    
    /*** Player Scores ***/
    @IBOutlet weak var Player_1_Score: UILabel!
    @IBOutlet weak var Player_2_Score: UILabel!
    @IBOutlet weak var Player_3_Score: UILabel!
    @IBOutlet weak var Player_4_Score: UILabel!
    
    /*** Player Avatars ***/
    @IBOutlet weak var Player_1_Avatar: UIImageView!
    @IBOutlet weak var Player_2_Avatar: UIImageView!
    @IBOutlet weak var Player_3_Avatar: UIImageView!
    @IBOutlet weak var Player_4_Avatar: UIImageView!
    
    /*** Player Answers ***/
    @IBOutlet weak var Player_1_Answer: UILabel!
    @IBOutlet weak var Player_2_Answer: UILabel!
    @IBOutlet weak var Player_3_Answer: UILabel!
    @IBOutlet weak var Player_4_Answer: UILabel!
    
    /*** Players Speech Bubbles ***/
    @IBOutlet weak var Player_1_Speech_Bubble: UIView!
    @IBOutlet weak var Player_2_Speech_Bubble: UIView!
    @IBOutlet weak var Player_3_Speech_Bubble: UIView!
    @IBOutlet weak var Player_4_Speech_Bubble: UIView!
    
    
    @IBOutlet weak var Question_Text: UILabel!
    @IBOutlet weak var Finish_Display_Text: UILabel!
    @IBOutlet weak var Submit_Button: UIButton!
    @IBOutlet weak var levelTimer: KDCircularProgress!
    @IBOutlet weak var timeLabel: UILabel!
    
    var LEVEL_COLOR: UIColor?           // Current Color Scheme of the Level
    var CURRENT_CHOICE: UIButton?       // Current Answer Choice Selected by the User
    var questionTimer: Timer!           // Timer for the current Question
    var QUESTION_TIME = 20              // Alloted time to answer the question
    var shouldShake = true              // Variable to allow the user to shake the device
    var NUMBER_OF_ACTIVE_PLAYERS: Int!  // Number of players currently in the game
    var selectionMatrix: [[Int]]!       // Matrix used to decide direction of answer choice
    var motionManager: CMMotionManager! // Handles Motion stuff

    var quizArray: [Quiz]!
    var quizArrayCount = 0
    var questionCount = 0
    var nextQuiz = false
    
    var localPlayer: Player!
    
    /*** Connection Handling ***/
    var session: MCSession!
    var peerID: MCPeerID!
    
    var browser: MCBrowserViewController!
    var assistant: MCAdvertiserAssistant! // not sure if we still need to advertise here.
    
    var playerArray = [Player]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        selectionMatrix = Array(repeating: Array(repeating: 0, count: 2), count: 2)  // Initialize the matrix to all 0's
        
        /*** Setup Motion Manager ***/
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
        motionManager.deviceMotionUpdateInterval = 0.1
        
        if motionManager.isAccelerometerAvailable == true {
            motionManager.startDeviceMotionUpdates(
                to: OperationQueue.current!, withHandler: {
                    (deviceMotion, error) -> Void in
                    
                    if(error == nil) {
                        self.handleDeviceMotionUpdate(deviceMotion: deviceMotion!)
                    } else {
                        //handle the error
                        print("motion error handled with print statement")
                    }
            })
        }
        
        self.peerID = MCPeerID(displayName: UIDevice.current.name)
        
        self.browser = MCBrowserViewController(serviceType: "multichat", session: session)
        session.delegate = self
        browser.delegate = self
        
        localPlayer = Player(pid: peerID.displayName)
        
        addPlayersToArray()
        NUMBER_OF_ACTIVE_PLAYERS = playerArray.count
        
        print("number active: \(NUMBER_OF_ACTIVE_PLAYERS!)")
        
        generateQuizScreen()
        
        /*** Set the level color ***/
        LEVEL_COLOR = UIColor(red:3.0/255.0, green:169.0/255.0, blue:244.0/255.0, alpha:1.0)
        
        /*** The timer starts all the way filled at 360 degrees and 20 seconds on the clock **/
        levelTimer.angle = 360
        timeLabel.text = String(QUESTION_TIME)
        
        levelTimeSet()
        startTimer()
        
        /*** Logic used to place Blank Avatars if the game is not full ***/
        let avatars: [UIImageView] = [Player_1_Avatar, Player_2_Avatar, Player_3_Avatar, Player_4_Avatar]
        for index in (1 ... 3) {
            if(index > NUMBER_OF_ACTIVE_PLAYERS!) {
                avatars[index].image = UIImage(named: "Blank_Avatar")
            }
        }
        
        // default choice set
        A_Button = animateChoice(button: A_Button)
        CURRENT_CHOICE = A_Button
    }
    
    func levelTimeSet() {
        levelTimer.stopAnimation()
        levelTimer.angle = 360
        /*** Every second we decrease the timer by 1 and take a little off the display ***/
        levelTimer.animate(fromAngle: levelTimer.angle, toAngle: 0, duration: TimeInterval(QUESTION_TIME), completion: nil)
    }
    
    /*** Shake the device to get a random answer choice ***/
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        
        if(shouldShake){
            
            if (motion == .motionShake) {
                
                let randomChoice = Int(arc4random_uniform(4))
                
                switch randomChoice {
                    
                case 0:  // A
                    CURRENT_CHOICE = A_Button
                    updateSelectionMatrix()
                    _ = animateChoice(button: A_Button)
                case 1:  // B
                    CURRENT_CHOICE = B_Button
                    updateSelectionMatrix()
                    _ = animateChoice(button: B_Button)
                case 2:  // C
                    CURRENT_CHOICE = C_Button
                    updateSelectionMatrix()
                    _ = animateChoice(button: C_Button)
                case 3:  // D
                    CURRENT_CHOICE = D_Button
                    updateSelectionMatrix()
                    _ = animateChoice(button: D_Button)
                default:
                    break
                }
            }
        }
    }
    
    func updateTimer(){
        
        /*** If there is still time in the game ***/
        if (QUESTION_TIME != 0) {
            QUESTION_TIME = QUESTION_TIME - 1
            timeLabel.text = String(QUESTION_TIME)
            checkEarlyFinish()
        }
            
            /*** The quiz has ended ***/
        else {
            // need to display the answer...
            // then undisplay it.
            
            // 3 second delay, to be efficient
            timeLabel.isHidden = true
            levelTimer.pauseAnimation()
            Question_Text.text = "Correct Answer: \(quizArray[quizArrayCount].questionArray[questionCount].getCorrect())"
            motionManager.stopDeviceMotionUpdates()
            checkCorrectness()
            questionCount += 1
            QUESTION_TIME = 23 // dumb
            resetTimer()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.levelTimeSet()
                self.generateQuizScreen()
                self.timeLabel.isHidden = false
                self.levelTimer.isHidden = false
                self.resetChoices()
            }
        }
    }
    
    func checkEarlyFinish() {
        var allDone = 0
        
        if NUMBER_OF_ACTIVE_PLAYERS > 0 {
            for player in playerArray {
                if player.submitted {
                    print("someone else submitted")
                    allDone += 1
                    
                }
            }
            if allDone >= NUMBER_OF_ACTIVE_PLAYERS && localPlayer.submitted {
                for player in playerArray {
                    player.hasSubmitted(sub: false)
                }
                localPlayer.submitted = false
                QUESTION_TIME = 0
            }
        }
        else {
            if localPlayer.submitted {
                QUESTION_TIME = 0
                localPlayer.hasSubmitted(sub: false)
            }
        }
    }
    
    func startTimer(){
        questionTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(QuizController.updateTimer), userInfo: "timer", repeats: true)
    }
    
    func resetTimer(){
        questionTimer.invalidate()
        startTimer()
    }
    
    func resetChoices() {
        Submit_Button.isHidden = false
        motionManager.stopDeviceMotionUpdates()
        A_Button.isUserInteractionEnabled = true
        B_Button.isUserInteractionEnabled = true
        C_Button.isUserInteractionEnabled = true
        D_Button.isUserInteractionEnabled = true
        shouldShake = true
        Player_1_Speech_Bubble.isHidden = true
        Player_2_Speech_Bubble.isHidden = true
        Player_3_Speech_Bubble.isHidden = true
        Player_4_Speech_Bubble.isHidden = true
        
    }
    
    
    /*** Helper function to select answer based on shift ***/
    func shiftMatrix(direction: String) {
        
        if(direction == "left") {
            
            if (selectionMatrix [1][0] == 1) {  // If answer was "B"
                CURRENT_CHOICE = A_Button
                updateSelectionMatrix()
                _ = animateChoice(button: A_Button)
            }
            else if (selectionMatrix [1][1] == 1) { // If answer was "D"
                CURRENT_CHOICE = C_Button
                updateSelectionMatrix()
                _ = animateChoice(button: C_Button)
            }
        }
        if(direction == "right") {
            
            if (selectionMatrix [0][0] == 1) { // If answer was "A"
                CURRENT_CHOICE = B_Button
                updateSelectionMatrix()
                _ = animateChoice(button: B_Button)
            }
            else if (selectionMatrix [0][1] == 1) { // If answer was "C"
                CURRENT_CHOICE = D_Button
                updateSelectionMatrix()
                _ = animateChoice(button: D_Button)
            }
        }
        if(direction == "down") {
            
            if (selectionMatrix [1][0] == 1) { // If answer was "B"
                CURRENT_CHOICE = D_Button
                updateSelectionMatrix()
                _ = animateChoice(button: D_Button)
            }
            else if (selectionMatrix [0][0] == 1) { // If answer was "A"
                CURRENT_CHOICE = C_Button
                updateSelectionMatrix()
                _ = animateChoice(button: C_Button)
            }
        }
        if(direction == "up") {
            
            if (selectionMatrix [0][1] == 1) { // If answer was "C"
                CURRENT_CHOICE = A_Button
                updateSelectionMatrix()
                _ = animateChoice(button: A_Button)
            }
            else if (selectionMatrix [1][1] == 1) { // If answer was "D"
                CURRENT_CHOICE = B_Button
                updateSelectionMatrix()
                _ = animateChoice(button: B_Button)
            }
        }
    }
    
    
    func handleDeviceMotionUpdate(deviceMotion:CMDeviceMotion) {
        
        let acceleration = deviceMotion.userAcceleration
        let attitude = deviceMotion.attitude
        let roll = degrees(radians: attitude.roll)
        let pitch = degrees(radians: attitude.pitch)
        let yaw = degrees(radians: attitude.yaw)
        
        
        /*** We only want to be able to switch by tilting if an answer has been chosen ***/
        if(CURRENT_CHOICE != nil)
        {
            print("Roll: \(roll) Pitch: \(pitch) Yaw: \(yaw) Acceleration: \(acceleration.z)")
            if(roll > 45.0)
            {
                shiftMatrix(direction: "right")
            }
            else if(roll < -45.0)
            {
                shiftMatrix(direction: "left")
            }
            else if(pitch < -45.0)
            {
                if(pitch < -75.0) {
                    submitAnswer(CURRENT_CHOICE!)
                } else {
                    shiftMatrix(direction: "up")
                }
            }
            else if(pitch > 45.0)
            {
                if(pitch > 75.0) {
                    submitAnswer(CURRENT_CHOICE!)
                } else {
                    shiftMatrix(direction: "down")
                }
            }
            if (acceleration.z < -1.0) {
                submitAnswer(CURRENT_CHOICE!)
            }
        }
    }
    
    func degrees(radians:Double) -> Double {
        return 180 / .pi * radians
    }
    
    func checkCorrectness() {
        let playerScores = [Player_2_Score, Player_3_Score, Player_4_Score]
        
        // local player score
        if localPlayer.getAnswer() == quizArray[quizArrayCount].questionArray[questionCount].getCorrect() {
            localPlayer.updatePlayerScore(score: 1)
            Player_1_Score.text = String(localPlayer.getScore())
            Finish_Display_Text.text = "Correct!"
        }
        else {
            Finish_Display_Text.text = "Wrong!"
        }
        
        UIView.animate(withDuration: 2, delay: 0,  usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.3, options: [.autoreverse, .curveEaseInOut],
                       animations: {
                        self.Finish_Display_Text.isHidden = false
                        self.Finish_Display_Text.center.x -= self.view.bounds.width
        },
                       completion: {
                        (value: Bool) in
                        self.Finish_Display_Text.isHidden = true
        }
        )

        
        // update other players score
        for player in playerArray {
            if player.getAnswer() == quizArray[quizArrayCount].questionArray[questionCount].getCorrect() {
                player.updatePlayerScore(score: 1)
            }
        }
        if playerArray.count > 0 {
            for i in 0 ... playerArray.count - 1 {
                playerScores[i]?.text = String(playerArray[i].getScore())
            }
        }
        
    }
    
    // may be easier to set each button to tag then just check answer that way. nah.
    @IBAction func selectAnswer(_ sender: UIButton) {
        switch sender {
        case A_Button:
            A_Button = animateChoice(button: A_Button)
            CURRENT_CHOICE = A_Button
            break
        case B_Button:
            B_Button = animateChoice(button: B_Button)
            CURRENT_CHOICE = B_Button
            break
        case C_Button:
            C_Button = animateChoice(button: C_Button)
            CURRENT_CHOICE = C_Button
            break
        case D_Button:
            D_Button = animateChoice(button: D_Button)
            CURRENT_CHOICE = D_Button
            break
        default:
            break
        }
        updateSelectionMatrix()
    }
    
    func updateSelectionMatrix(){
        let index = CURRENT_CHOICE?.titleLabel?.text?.index((CURRENT_CHOICE?.titleLabel?.text?.startIndex)!, offsetBy: 1)
        let answer = CURRENT_CHOICE?.titleLabel?.text?.substring(to: index!)
        
        selectionMatrix = Array(repeating: Array(repeating: 0, count: 2), count: 2)
        
        switch answer! {
        case "A":
            selectionMatrix[0][0] = 1
        case "B":
            selectionMatrix[1][0] = 1
        case "C":
            selectionMatrix[0][1] = 1
        case "D":
            selectionMatrix[1][1] = 1
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gameOver" {
            if let view = segue.destination as? GameOverViewController {
                questionTimer.invalidate()
                let playersAndMe = playerArray + [localPlayer]
                view.dataSet = playersAndMe
                view.MY_ID = localPlayer.getPlayerId()
                view.currentQuizNumber = quizArrayCount
                view.MAXIMUM_QUIZES = quizArray.count
                view.session = self.session as MCSession
                view.browser = self.browser
                view.localPlayer = self.localPlayer
                view.playerArray = self.playerArray
            }
        }
    }
    
    func generateQuizScreen() {
        
        // end of current quiz
        if quizArray[quizArrayCount].numberOfQuestions == questionCount {
            quizArrayCount += 1
            questionCount = 0
        }
        
        // for each separate quiz
        if quizArrayCount == quizArray.count {
            nextQuiz = true
        }
        
        if !nextQuiz {
            
            
            // set title
            navigationItem.title = "\(quizArray[quizArrayCount].topic!)"
        
            // for each question in a quiz
            displayQuestion(question: quizArray[quizArrayCount].questionArray[questionCount].sentence, answers: quizArray[quizArrayCount].questionArray[questionCount].possibilities)
        } else {
            performSegue(withIdentifier: "gameOver", sender: nil)
        }
        
        print("num quiz \(quizArrayCount)")
        print("num questions \(questionCount)")
        
        
    }
    
    func displayQuestion(question: String, answers: [String: String]!){
        Question_Text.text = question;
        A_Button.setTitle("A) \(answers["A"]!)", for: .normal)
        B_Button.setTitle("B) \(answers["B"]!)", for: .normal)
        C_Button.setTitle("C) \(answers["C"]!)", for: .normal)
        D_Button.setTitle("D) \(answers["D"]!)", for: .normal)
    }
    
    func animateChoice(button:UIButton) -> UIButton{
                
        /***** Set Buttons back to original color ***/
        let orignialBackground = UIImage(named: "Button")
        A_Button.setBackgroundImage(orignialBackground, for: .normal)
        A_Button.setTitleColor(LEVEL_COLOR, for: .normal)
        B_Button.setBackgroundImage(orignialBackground, for: .normal)
        B_Button.setTitleColor(LEVEL_COLOR, for: .normal)
        C_Button.setBackgroundImage(orignialBackground, for: .normal)
        C_Button.setTitleColor(LEVEL_COLOR, for: .normal)
        D_Button.setBackgroundImage(orignialBackground, for: .normal)
        D_Button.setTitleColor(LEVEL_COLOR, for: .normal)
        
        /***** Update our new button to be the current choice *****/
        let changedButton: UIButton = button
        let selectedImage = UIImage(named: "Selected_button")
        changedButton.setBackgroundImage(selectedImage, for: .normal)
        changedButton.setTitleColor(UIColor.white, for: .normal)
        return changedButton
    }
    
    // note: users currently will be displayed by their index in playerArray,
    // not player1 however
    func displayAnswer(forPlayer: Int, withAnswer: String) {
        
        switch(forPlayer){
        case 1:
            Player_1_Speech_Bubble.isHidden = false
            Player_1_Answer.text = withAnswer
            break
        case 2:
            Player_2_Speech_Bubble.isHidden = false
            Player_2_Answer.text = withAnswer
            break
        case 3:
            Player_3_Speech_Bubble.isHidden = false
            Player_3_Answer.text = withAnswer
            break
        case 4:
            Player_4_Speech_Bubble.isHidden = false
            Player_4_Answer.text = withAnswer
            break
        default:
            break
        }
    }
    
    func displayScore(forPlayer: Int, withAnswer: String) {
        
        switch(forPlayer){
        case 1:
            Player_1_Score.text = withAnswer
            break
        case 2:
            Player_2_Score.text = withAnswer
            break
        case 3:
            Player_3_Score.text = withAnswer
            break
        case 4:
            Player_4_Score.text = withAnswer
            break
        default:
            print("something is very wrong")
            break
        }
    }
    
    /*** The player has clicked "Replay" on the Game Over screen ***/
    @IBAction func backToQuiz(segue: UIStoryboardSegue) {
        if let sourceViewController = segue.source as? GameOverViewController {
            quizArrayCount = sourceViewController.nextQuizNumber!
            session = sourceViewController.session as MCSession
            browser = sourceViewController.browser
            peerID = sourceViewController.peerID
            localPlayer = sourceViewController.localPlayer
            playerArray = sourceViewController.playerArray
        }
        session.delegate = self
        browser.delegate = self
        QUESTION_TIME = 20
        questionCount = 0
        nextQuiz = false
        for player in playerArray {
            player.playerScore = 0
        }
        localPlayer.playerScore = 0
        
        //Ugly and will fix
        displayScore(forPlayer: 0, withAnswer: "0")
        displayScore(forPlayer: 1, withAnswer: "0")
        displayScore(forPlayer: 2, withAnswer: "0")
        displayScore(forPlayer: 3, withAnswer: "0")

        levelTimeSet()
        generateQuizScreen()
        resetTimer()
    }
    
    // hold our players, referenced by index
    // not in use currently.
    func addPlayer(player: Player) {
        playerArray.append(player)
    }
    
    func addPlayersToArray() {
        // note: the only players in this array are your opponents
        for users in session.connectedPeers {
            playerArray.append(Player(pid: users.displayName))
        }
    }
    
    @IBAction func submitAnswer(_ sender: Any) {
        
        Submit_Button.isHidden = true
        motionManager.stopDeviceMotionUpdates()
        A_Button.isUserInteractionEnabled = false
        B_Button.isUserInteractionEnabled = false
        C_Button.isUserInteractionEnabled = false
        D_Button.isUserInteractionEnabled = false
        shouldShake = false
        
        
        let index = CURRENT_CHOICE?.titleLabel?.text?.index((CURRENT_CHOICE?.titleLabel?.text?.startIndex)!, offsetBy: 1)
        displayAnswer(forPlayer: 1, withAnswer: (CURRENT_CHOICE?.titleLabel?.text?.substring(to: index!))!)
        localPlayer.updateAnswer(ans: (CURRENT_CHOICE?.titleLabel?.text?.substring(to: index!))!)
        localPlayer.hasSubmitted(sub: true)
        // send this data to each player
        // read in below, since this user is always added first, we know index 0 will always be current user.
        let sending = ["pid": peerID.displayName, "answer": CURRENT_CHOICE?.titleLabel?.text?.substring(to: index!) as Any, "submit": true] as [String : Any]
        let data = NSKeyedArchiver.archivedData(withRootObject: sending)
        
        do {
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("error s  ending answer")
        }
        //checkEarlyFinish()
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID){
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
            // take back to home?
        }
        
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        // this needs to be run on the main thread
        DispatchQueue.main.async(execute: {
            
            if let player = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: Any] {
                
                // need to create the other user each time information is sent?
                if let playId = player["pid"] as? String {
                    if let playAns = player["answer"] as? String {
                        if let playSubmit = player["submit"] as? Bool {
                // we can now use this info to update each users choice.
                // search through array?!
                var tempCount = 2
                for user in self.playerArray {
                    let id = user.getPlayerId()
            
                    if playId == id {
                        user.hasSubmitted(sub: playSubmit)
                        user.updateAnswer(ans: playAns)
                        self.displayAnswer(forPlayer: tempCount, withAnswer: user.getAnswer())
                    }
                    tempCount += 1
                }
                        }
                    }
                }
                
            }
            
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
