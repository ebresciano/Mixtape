//
//  ProfileTableViewCell.swift
//  Mixtape
//
//  Created by Eva Marie Bresciano on 7/27/16.
//  Copyright © 2016 Eva Bresciano. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var songTitleLabel: UILabel!
    
    @IBOutlet weak var artistNameLabel: UIView!
    
    @IBOutlet weak var albumArtImage: UIImageView!
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
