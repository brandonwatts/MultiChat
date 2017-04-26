//
//  Player.swift
//  MultiChat
//
//  Created by Ben Leach on 4/22/17.
//  Copyright © 2017 Brandon Watts. All rights reserved.
//

import Foundation
import UIKit

class Player {
    
    var playerId: String!
    var playerScore = 0
    var answer: String!
    var playerAvatar: UIImage!
    var submitted: Bool!
    
    init(pid: String) {
        playerId = pid
        playerAvatar = UIImage(named: "Blank_Avatar")
        submitted = false
        answer = "F"
    }
    
    func hasSubmitted(sub: Bool) {
        submitted = sub
    }
    
    func updatePlayerScore(score: Int) {
        playerScore = playerScore + score
    }
    
    func setPlayerScore(score: Int) {
        playerScore = score
    }
    
    func updateAnswer(ans: String){
        answer = ans
    }
    
    func setImage(img: UIImage) {
        self.playerAvatar = img
    }
    
    func getScore() -> Int {
        return playerScore
    }
    
    func getImage() -> UIImage {
        return playerAvatar
    }
    
    func getPlayerId() -> String {
        return playerId
    }
    
    func getAnswer() -> String {
        return answer
    }
    
    
    
}
