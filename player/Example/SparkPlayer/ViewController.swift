//
//  ViewController.swift
//  SparkPlayer
//
//  Created by spark on 02/12/2018.
//  Copyright (c) 2018 spark. All rights reserved.
//

import UIKit
import AVKit
import SparkPlayer

class ViewController: UIViewController {
    @IBOutlet weak var playerView: UIView!

    var sparkPlayer: SparkPlayer!

    //var url = "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8"
    var url = "http://qthttp.apple.com.edgesuite.net/1010qwoeiuryfg/sl.m3u8"

    override func viewDidLoad() {
        super.viewDidLoad()

        sparkPlayer = SparkPlayer()
        self.addChildViewController(sparkPlayer)

        if let url = URL(string: self.url) {
            sparkPlayer.player = AVPlayer(url: url)
            playerView.addSubview(sparkPlayer.view)
            updatePlayerFrame()
        }
    }

    func updatePlayerFrame() {
        sparkPlayer.view.frame = CGRect(x: 0, y: 0, width: playerView.frame.width, height: playerView.frame.height)
    }

    override func viewDidAppear(_ animated: Bool) {

    }

    override func viewDidLayoutSubviews() {
        updatePlayerFrame()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "native") {
            if let native = segue.destination as? AVPlayerViewController {
                if let url = URL(string: self.url) {
                    native.player = AVPlayer(url: url)
                }
            }
        }
    }

}

