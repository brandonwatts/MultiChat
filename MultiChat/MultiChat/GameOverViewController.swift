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
    
    /*** Dataset of players from the previous screen (pass it through the segue) ***/
    var dataSet: [Player]?
    
    /*** Will need to set the ID (pass it through segue) ***/
    let MY_ID = 1
    
    /*** Used for the animation ***/
    var shownIndexes : [IndexPath] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        places.delegate = self
        places.dataSource = self
        places.isScrollEnabled = false;
        // need to place localUser in array, then remove to pass back to quiz
//        /*** DUMMY TEST DATA **/
//        let p1 = Player(pid: "1")
//        p1.playerScore = 5
//        p1.playerAvatar = UIImage(named: "avatar")
//        let p2 = Player(pid: "2")
//        p2.playerScore = 7
//        p2.playerAvatar = UIImage(named: "avatar")
//        let p3 = Player(pid: "3")
//        p3.playerScore = 9
//        p3.playerAvatar = UIImage(named: "avatar")
//        let p4 = Player(pid: "4")
//        p4.playerScore = 8
//        p4.playerAvatar = UIImage(named: "avatar")
//        dataSet = [p1, p2,p3,p4]
//        /**************************/
        
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
            if (player.playerId == String(MY_ID)) {
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
        
        cell.playerImage.image = dataSet![indexPath.row].getImage()          // Set the player image
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
