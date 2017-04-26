//
//  GameOverViewController.swift
//  MultiChat
//
//  Created by Brandon Watts on 4/25/17.
//  Copyright © 2017 Brandon Watts. All rights reserved.
//

import UIKit

class GameOverViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var placeText: UILabel!
    @IBOutlet weak var replayButton: UIButton!
    @IBOutlet weak var places: UITableView!
    
    var dataSet: [Player]?
    var MY_ID : String?
    var shownIndexes : [IndexPath] = []
    var currentQuizNumber: Int?
    var nextQuizNumber: Int?
    var MAXIMUM_QUIZES: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        places.delegate = self
        places.dataSource = self
        places.isScrollEnabled = false;
        
        if( currentQuizNumber == MAXIMUM_QUIZES) {
            nextQuizNumber = 0
        } else {
            nextQuizNumber = currentQuizNumber! + 1
        }
        
        /*** Sort the players by thier score ***/
        let sortedData = dataSet?.sorted(by: sortFunc)
        dataSet = sortedData
        
        /*** Set the placeText based on what place you came in ***/
        setPlace(data: dataSet!)
        
        /*** Just tableView styling ***/
        places.tableFooterView = UIView(frame: .zero)
        
        /*** Animate in the place text ***/
        UIView.animate(withDuration: 0.8, delay: 0,  options: [.curveEaseIn],
                       animations: {
                        self.placeText.center.y += self.view.bounds.height
        }, 
                       completion: nil
        )
        
        /*** Animate in the Replay Button ***/
        UIView.animate(withDuration: 0.5, delay: 2,  usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.3, options: [.curveEaseIn],
                       animations: {
                        self.replayButton.center.x -= self.view.bounds.width
        },
                       completion: nil
        )
    }
    
    func setPlace(data: [Player]) {
        for (index,player) in (data.enumerated()) {
            if (player.getPlayerId() == MY_ID) {
                switch index {
                case 0:
                    placeText.text = "1st"
                case 1:
                    placeText.text = "2nd"
                case 2:
                    placeText.text = "3rd"
                case 3:
                    placeText.text = "4th"
                default:
                    break
                }
            }
        }
    }
    
    func sortFunc(player1: Player, player2: Player) -> Bool {
        return player2.getScore() < player1.getScore()
    }
    
    /*** Animation for TableView Cells ***/
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (shownIndexes.contains(indexPath) == false) {
            shownIndexes.append(indexPath)
            
            cell.transform = CGAffineTransform(translationX: 0, y: 100)
            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowOffset = CGSize(width: 10, height: 10)
            cell.alpha = 0
            
            UIView.beginAnimations("rotation", context: nil)
            UIView.setAnimationDuration(1)
            cell.transform = CGAffineTransform(translationX: 0, y: 0)
            cell.alpha = 1
            cell.layer.shadowOffset = CGSize(width: 0, height: 0)
            UIView.commitAnimations()
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath as IndexPath) as! placeCell
        
        cell.playerImage.image = UIImage(named: "avatar")                    // Set the player image
        cell.playerScore.text = String(dataSet![indexPath.row].playerScore)  // Set the player score
        cell.playerPlace.text = "\(indexPath.row + 1)"                       // Set the player place
        cell.selectionStyle = UITableViewCellSelectionStyle.none;            // Make the cell not clickable
        
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (dataSet?.count)!
    }
}
