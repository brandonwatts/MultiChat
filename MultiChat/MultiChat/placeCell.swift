//
//  placeCell.swift
//  MultiChat
//
//  Created by Brandon Watts on 4/25/17.
//  Copyright © 2017 Brandon Watts. All rights reserved.
//

import UIKit

class placeCell: UITableViewCell {
    
    @IBOutlet weak var playerImage: UIImageView!
    @IBOutlet weak var playerPlace: UILabel!
    @IBOutlet weak var playerScore: UILabel!
    
    override func awakeFromNib() { super.awakeFromNib() }
    
    override func setSelected(_ selected: Bool, animated: Bool) { super.setSelected(selected, animated: animated) }
}

