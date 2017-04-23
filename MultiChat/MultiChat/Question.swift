//
//  Question.swift
//  MultiChat
//
//  Created by Ben Leach on 4/22/17.
//  Copyright © 2017 Brandon Watts. All rights reserved.
//

import Foundation

class Question {
    var sentence: String!
    var possibilities: [String: String]!
    var correct: String!
    var questionNumber: Int!
    
    init(sentence: String,poss: [String: String], correct: String, qNum: Int) {
        self.sentence = sentence
        self.possibilities = poss
        self.correct = correct
        self.questionNumber = qNum
    }
    
    
    
}
