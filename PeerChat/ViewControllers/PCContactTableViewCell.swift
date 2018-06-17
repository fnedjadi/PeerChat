//
//  PCContactTableViewCell.swift
//  PeerChat
//
//  Created by Farah Nedjadi on 12/06/2018.
//  Copyright © 2018 mti. All rights reserved.
//

import UIKit

class PCContactTableViewCell: UITableViewCell {

    @IBOutlet weak var additionalBackground: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.additionalBackground.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
