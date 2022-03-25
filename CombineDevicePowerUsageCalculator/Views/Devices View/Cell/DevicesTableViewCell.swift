//
//  DevicesTableViewCell.swift
//  CombineDevicePowerUsageCalculator
//
//  Created by Kacper Trębacz on 23/03/2022.
//

import UIKit

class DevicesTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var powerLabel: UILabel!
    @IBOutlet weak var timeOfUsageLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupCell(device: DeviceModel) {
        nameLabel.text = device.name
        powerLabel.text = "Power: \(device.power)W"
        timeOfUsageLabel.text = "Time of usage: \(device.timeOfUsage)h"
        priceLabel.text = String(device.price)
    }
}
