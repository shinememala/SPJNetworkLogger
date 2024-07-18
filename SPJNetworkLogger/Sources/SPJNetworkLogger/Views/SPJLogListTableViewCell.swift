//
//  SPJLogListTableViewCell.swift
//  POC
//
//  Created by Shine PJ on 15/07/2024.
//

import UIKit

class SPJLogListTableViewCell: UITableViewCell {

    
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var responseTimeLabel: UILabel!
    @IBOutlet weak var retuestMethodLabel: UILabel!
    @IBOutlet weak var statusCodeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
