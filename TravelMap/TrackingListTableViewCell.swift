//
//  TrackingListTableViewCell.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/10/07.
//

import UIKit

class TrackingListTableViewCell: UITableViewCell {

    @IBOutlet weak var trackingName: UILabel!
    @IBOutlet weak var trackingTime: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
