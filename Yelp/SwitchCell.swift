//
//  SwitchCell.swift
//  Yelp
//
//  Created by Jaimin Shah on 9/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

//this protcol is optional, hence the "@objc"
@objc protocol SwitchCellDelegate {
    optional func switchCell(switchCell:SwitchCell, didValueChange val:Bool)  //function name = what view is firing the function
}

class SwitchCell: UITableViewCell {

    @IBOutlet weak var categoryLabel: UILabel!
    
    weak var delegate:SwitchCellDelegate? // '?' because the delegate is optional
    
    @IBOutlet weak var onSwitch: UISwitch!
    override func awakeFromNib() {
        super.awakeFromNib()

        onSwitch.addTarget(self, action: "switchValueChanged", forControlEvents: UIControlEvents.ValueChanged)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func switchValueChanged(){
        
        delegate?.switchCell?(self, didValueChange: onSwitch.on)
        
    }

}
