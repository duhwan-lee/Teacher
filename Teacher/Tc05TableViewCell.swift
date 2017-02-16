//
//  Tc05TableViewCell.swift
//  Teacher
//
//  Created by doohwan Lee on 2017. 2. 16..
//  Copyright © 2017년 doohwan Lee. All rights reserved.
//

import UIKit

class Tc05TableViewCell: UITableViewCell {

    @IBOutlet weak var answerText: UILabel!
    @IBOutlet weak var typeImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
