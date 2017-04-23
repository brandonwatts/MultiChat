//
//  QuizController.swift
//  MultiChat
//
//  Created by Brandon Watts on 4/22/17.
//  Copyright © 2017 Brandon Watts. All rights reserved.
//

import UIKit

class QuizController: UIViewController {

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
    @IBOutlet weak var Next_Question_Button: UIImageView!
    @IBOutlet weak var Submit_Button: UIButton!
    @IBOutlet weak var levelTimer: KDCircularProgress!
    @IBOutlet weak var timeLabel: UILabel!
    
    var LEVEL_COLOR: UIColor?  // Current Color Scheme of the Level
    var CURRENT_CHOICE: UIButton? // Current Answer Choice Selected by the User
    var questionTimer: Timer!
    var QUESTION_TIME = 20
    var NUMBER_OF_ACTIVE_PLAYERS = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let avatars: [UIImageView] = [Player_1_Avatar, Player_2_Avatar, Player_3_Avatar, Player_4_Avatar]

        
        LEVEL_COLOR = UIColor(red:3.0/255.0, green:169.0/255.0, blue:244.0/255.0, alpha:1.0) // Nice Blue Color
        levelTimer.angle = 360
        timeLabel.text = String(QUESTION_TIME)
        levelTimer.animate(fromAngle: levelTimer.angle, toAngle: 0, duration: TimeInterval(QUESTION_TIME), completion: nil)
        questionTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        
        for index in (0 ... 3) {
            if(index > NUMBER_OF_ACTIVE_PLAYERS - 1){
                avatars[index].image = UIImage(named: "Blank_Avatar")
            }
        }
    }
    
    func updateTimer(){
        if (QUESTION_TIME != 0) {
            QUESTION_TIME = QUESTION_TIME - 1
            timeLabel.text = String(QUESTION_TIME)
        }
        else {
            questionTimer.invalidate()
            Finish_Display_Text.isHidden = false
            Next_Question_Button.isHidden = false
            //END GAME
        }
    }

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
    }
    
    func animateChoice(button:UIButton) -> UIButton{
        
        Submit_Button.isHidden = false
        
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
    
    @IBAction func submitAnswer(_ sender: Any) {
        let index = CURRENT_CHOICE?.titleLabel?.text?.index((CURRENT_CHOICE?.titleLabel?.text?.startIndex)!, offsetBy: 1)
        displayAnswer(forPlayer: 1, withAnswer: (CURRENT_CHOICE?.titleLabel?.text?.substring(to: index!))!)
        // TODO: Handle Answer Choice
    }

}
