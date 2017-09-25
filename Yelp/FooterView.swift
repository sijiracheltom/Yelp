//
//  FooterView.swift
//  Yelp
//
//  Created by Siji Rachel Tom on 9/24/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

class FooterView: UITableViewHeaderFooterView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.sizeToFit()
        let padding = 4.0 * 2 as CGFloat
        contentView.frame.size.height = (textLabel?.frame.size.height)! + padding
        textLabel?.center = contentView.center
    }

}
