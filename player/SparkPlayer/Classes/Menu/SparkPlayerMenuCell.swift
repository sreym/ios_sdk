//
//  SparkPlayerMenuCell.swift
//  SparkPlayer
//
//  Created by alexeym on 06/03/2018.
//

import UIKit

class SparkPlayerMenuCell: UICollectionViewCell {
    @IBOutlet weak var menuImage: UIImageView!
    @IBOutlet weak var menuLabel: UILabel!

    func setup(_ item: MenuItem) {
        self.backgroundColor = UIColor.SparkPlayer.menuBackground
        if let icon = item.icon {
            menuImage.image = icon
        } else {
            menuImage.image = nil
        }

        menuLabel.text = item.text
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
