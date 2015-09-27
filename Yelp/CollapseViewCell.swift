//
//  CollapseViewCell.swift
//  Yelp
//
//  Created by Jaimin Shah on 9/26/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol CollapseViewCellDelegate {
    optional func selectCell(collaspeViewCell: CollapseViewCell, didSelect arrowImage:UIImage)
}

class CollapseViewCell: UITableViewCell {

    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var optionsLabel: UILabel!
    
    var delegate: CollapseViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        println(" arrow selected")
        
        if delegate != nil {
            delegate?.selectCell?(self, didSelect: arrowImageView.image!)
        }
    }

}
