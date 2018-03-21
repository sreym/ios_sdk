//
//  SparkPlayerMenu.swift
//  SparkPlayer
//
//  Created by alexeym on 02/03/2018.
//

import UIKit

class SparkPlayerMenu: UIView {

    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var cancelButton: UIView!
    @IBOutlet weak var cancelLabel: UILabel!
    @IBOutlet weak var cancelIcon: UIImageView!

    var topBorder: CALayer?

    override func awakeFromNib() {
        super.awakeFromNib()

        cancelLabel.textColor = UIColor.SparkPlayer.menuColor
        topBorder = cancelButton.addBorder(toSide: .Top, withColor: UIColor.SparkPlayer.menuSeparator, andThickness: 1)

        if let collection = self.collectionView {
            let menuCellNib = UINib(nibName: "SparkPlayerMenuCell", bundle: SparkPlayer.getResourceBundle())
            collection.register(menuCellNib, forCellWithReuseIdentifier: "menuCell")

            collection.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "footerView")
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if let border = self.topBorder {
            border.frame.size.width = self.frame.width
        }
    }

    func setupCancelButton(_ item: MenuItem) {
        cancelLabel.text = item.text
        cancelIcon.image = item.icon
    }

}
