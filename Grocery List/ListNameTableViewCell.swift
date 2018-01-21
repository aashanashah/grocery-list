//
//  ListNameTableViewCell.swift
//  Grocery List
//
//  Created by Aashana on 11/13/17.
//  Copyright © 2017 Aashana. All rights reserved.
//

import UIKit

class ListNameTableViewCell: UITableViewCell {
    @IBOutlet var name : UIButton!
    @IBOutlet var listName : UITableView!
    @IBOutlet var delete : UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        delete.isHidden = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
