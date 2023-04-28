//
//  TableViewCell.swift
//  CodingChallenge
//
//  Created by chinmai swaraj on 27/4/2023.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var callTimeValue: UILabel!
    @IBOutlet weak var titleValue: UILabel!
    @IBOutlet weak var statusValue: UILabel!
    @IBOutlet weak var typeIconValue: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
