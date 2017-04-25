//
//  Player.swift
//  MultiChat
//
//  Created by Ben Leach on 4/22/17.
//  Copyright © 2017 Brandon Watts. All rights reserved.
//

import Foundation

class Player {
    
    var playerId: String!
    var playerScore = 0
    var answer: String!
    
    
    init(pid: String) {
        playerId = pid
    }
    
    func updatePlayerScore(score: Int) {
        playerScore = playerScore + score
    }
    
    func updateAnswer(ans: String){
        answer = ans
    }
    
    func getScore() -> Int {
        return playerScore
    }
    
    func getPlayerId() -> String {
        return playerId
    }
    
    func getAnswer() -> String {
        return answer
    }
    
    
    
}
