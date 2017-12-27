//
//  ItemTableCellTableViewCell.swift
//  Grocery List
//
//  Created by Aashana on 12/17/17.
//  Copyright © 2017 Aashana. All rights reserved.
//

import UIKit

class ItemTableCell: UITableViewCell {
    @IBOutlet var itemName : UILabel!
    @IBOutlet var quantity : UILabel!
    @IBOutlet var srno : UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
