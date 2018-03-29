//
//  VideoTableViewCell.swift
//  spark-demo
//
//  Created by alexeym on 01/03/2018.
//  Copyright © 2018 holaspark. All rights reserved.
//

import UIKit

class VideoTableViewCell: UITableViewCell {
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var loaderActivity: UIActivityIndicatorView!

    static var defaultDescription = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla dictum, dolor nec vestibulum lacinia, justo lectus pretium risus, id sollicitudin arcu eros maximus ante. In non quam posuere mi tempor venenatis. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis pulvinar mauris sit amet ullamcorper cursus. Etiam convallis dictum mauris porttitor porta. Nulla facilisi. In scelerisque vulputate mauris eu pretium. Proin in turpis ut neque vestibulum ultrices. Aliquam erat volutpat. Donec molestie quam in facilisis viverra. Ut bibendum, nisi ut feugiat feugiat, risus metus mollis quam, vitae lacinia augue nulla ut erat. Vestibulum orci dolor, egestas vitae elit ut, auctor vestibulum turpis.

Donec eleifend at mauris sed pretium. Vivamus non blandit ligula, nec iaculis enim. Sed quis dolor nec dui viverra varius sed eget quam. Nulla sit amet vehicula nisl. Suspendisse potenti. Sed a elementum lorem, vel convallis metus. Phasellus malesuada tellus ipsum, sed condimentum nisl consectetur aliquet. Nam eu posuere lectus. Sed sem nisi, hendrerit nec sapien vel, sollicitudin luctus magna. Nam in nibh nulla. Nullam ultricies urna ipsum. Integer mattis libero risus, a gravida ipsum consequat ac. Aliquam malesuada ante et dolor interdum, et consectetur urna iaculis.

Praesent bibendum malesuada augue at gravida. Quisque vestibulum tellus quis aliquam cursus. Mauris fringilla nibh sapien, vitae egestas ante dapibus vel. Sed dolor erat, facilisis nec quam eget, porttitor blandit turpis. Fusce iaculis metus non justo pellentesque iaculis. Sed at tortor tortor. Curabitur fermentum porta nibh, sit amet scelerisque arcu porta ut. Curabitur porttitor commodo varius. Aenean nisl diam, pharetra in dapibus vitae, hendrerit sit amet lectus. Morbi cursus dui rutrum eros facilisis, ut tincidunt velit interdum. Pellentesque suscipit leo sit amet imperdiet vestibulum. In eget mollis eros. Nulla et lacinia eros. Nullam sagittis porta magna, sed ullamcorper eros sagittis vitae. Quisque vitae maximus eros. Nam non arcu justo.
"""

    var video: VideoItem? {
        didSet {
            self.setup()
        }
    }

    var descriptionText: String?

    func setup() {
        guard let video = self.video else {
            return
        }

        titleLable.text = video.getTitle()
        descriptionText = VideoTableViewCell.defaultDescription

        descriptionLabel.text = descriptionText

        self.previewImage.image = nil

        loaderActivity.isHidden = false
        loaderActivity.startAnimating()

        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            if let image = video.getPosterImage() {
                DispatchQueue.main.async {
                    self.previewImage.image = image
                    self.loaderActivity.stopAnimating()
                    self.loaderActivity.isHidden = true
                }
            } else {
                DispatchQueue.main.async {
                    self.loaderActivity.stopAnimating()
                    self.loaderActivity.isHidden = true
                }
            }
        }
    }
}
