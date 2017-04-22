//
//  QuizController.swift
//  MultiChat
//
//  Created by Brandon Watts on 4/22/17.
//  Copyright © 2017 Brandon Watts. All rights reserved.
//

import UIKit

class QuizController: UIViewController {

    @IBOutlet weak var A_Button: UIButton!
    @IBOutlet weak var B_Button: UIButton!
    @IBOutlet weak var C_Button: UIButton!
    @IBOutlet weak var D_Button: UIButton!
    @IBOutlet weak var Submit_Button: UIButton!
    @IBOutlet weak var levelTimer: KDCircularProgress!
    @IBOutlet weak var timeLabel: UILabel!
    
    var LEVEL_COLOR: UIColor?  // Current Color Scheme of the Level
    var CURRENT_CHOICE: UIButton? // Current Answer Choice Selected by the User
    var questionTimer: Timer!
    var QUESTION_TIME = 25
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LEVEL_COLOR = UIColor(red:3.0/255.0, green:169.0/255.0, blue:244.0/255.0, alpha:1.0) // Nice Blue Color
        levelTimer.angle = 360
        timeLabel.text = String(QUESTION_TIME)
        levelTimer.animate(fromAngle: levelTimer.angle, toAngle: 0, duration: TimeInterval(QUESTION_TIME), completion: nil)
        questionTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    func updateTimer(){
        if (QUESTION_TIME != 0)
        {
            QUESTION_TIME = QUESTION_TIME - 1
            timeLabel.text = String(QUESTION_TIME)
        }
        else{
            questionTimer.invalidate()
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
    
    @IBAction func submitAnswer(_ sender: Any) {
        // TODO: Handle Answer Choice
    }

}
