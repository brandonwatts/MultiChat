//
//  Quiz.swift
//  MultiChat
//
//  Created by Ben on 4/22/17.
//  Copyright © 2017 Brandon Watts. All rights reserved.
//

import Foundation

class Quiz {
    
    var questionArray: [Question]!
    var topic: String!
    var numberOfQuestions: Int!
    
    init(qArray: [Question], top: String, numQ: Int){
        questionArray = qArray
        topic = top
        numberOfQuestions = numQ
    }
    
}
