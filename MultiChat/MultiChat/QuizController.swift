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
    var LEVEL_COLOR: UIColor?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LEVEL_COLOR = UIColor(red:202.0/255.0, green:228.0/255.0, blue:230.0/255.0, alpha:1.0)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func selectAnswer(_ sender: UIButton) {
        switch sender {
        case A_Button:
            A_Button = animateChoice(button: A_Button)
            break
        case B_Button:
            B_Button = animateChoice(button: B_Button)
            break
        case C_Button:
             C_Button = animateChoice(button: C_Button)
            break
        case D_Button:
            D_Button = animateChoice(button: D_Button)
            break
        default:
            break
        }
    }
    
    func animateChoice(button:UIButton) -> UIButton{
        let changedButton: UIButton = button
        let selectedImage = UIImage(named: "Selected_button")
        changedButton.setBackgroundImage(selectedImage, for: .normal)
        changedButton.setTitleColor(UIColor.white, for: .normal)
        return changedButton
    }

}
