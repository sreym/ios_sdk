//
//  VideoListViewController.swift
//  spark-demo
//
//  Created by alexeym on 01/03/2018.
//  Copyright © 2018 holaspark. All rights reserved.
//

import UIKit

class VideoListViewController: UIViewController {
    @IBOutlet weak var videosTable: UITableView!
    @IBOutlet weak var errorView: UIView?
    @IBOutlet weak var loaderView: UIView?

    private var pendingTask: URLSessionDataTask? {
        didSet {
            updateMessageView()
        }
    }

    private var loaded = false
    private var needUpdateTable = false

    var selectedVideo: VideoPage?

    var customerID: String! {
        didSet {
            updateVideos()
        }
    }

    var videosFetchError: Error? {
        didSet {
            updateMessageView()
        }
    }

    var videoList: [VideoItem] = [] {
        didSet {
            guard loaded else {
                needUpdateTable = true
                return
            }

            DispatchQueue.main.async() {
                self.videosTable.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        loaded = true

        updateMessageView()

        if (needUpdateTable) {
            needUpdateTable = false
            self.videosTable.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //self.navigationController?.navigationBar.isHidden = true
        //self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        if let selected = videosTable.indexPathForSelectedRow {
            videosTable.deselectRow(at: selected, animated: false)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateMessageView() {
        let view: UIView?

        if (self.pendingTask != nil) {
            view = loaderView
        } else if (self.videosFetchError != nil) {
            view = errorView
        } else {
            view = nil
        }

        DispatchQueue.main.async() {
            self.loaderView?.isHidden = view != self.loaderView
            self.errorView?.isHidden = view != self.errorView
        }

        guard let viewToUpdate = view else {
            return
        }

        DispatchQueue.main.async() {
            viewToUpdate.isHidden = false
            self.view.bringSubview(toFront: viewToUpdate)
        }
    }

    func updateVideos() {
        videosFetchError = nil
        if let task = self.pendingTask {
            task.cancel()
            self.pendingTask = nil
        }
        
        self.pendingTask = VideoItem.getVideoItems()
        { (items, error) in
            self.pendingTask = nil
            guard let videos = items, error == nil else {
                self.videosFetchError = error
                return
            }
            self.videosFetchError = nil
            self.videoList = videos
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard identifier == "video" else {
            return super.shouldPerformSegue(withIdentifier: identifier, sender: sender)
        }

        return selectedVideo != nil
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            segue.identifier == "video",
            let vc = segue.destination as? ViewController
        else {
            return
        }

        vc.customerID = customerID
        if let info = selectedVideo {
            vc.info = info
        }
    }
    
    @IBAction func onRefreshButton(_ sender: Any) {
        updateVideos()
    }
}

extension VideoListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return videoList.count
        }

        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "videoCell", for: indexPath)
        let row = indexPath.row

        if (row >= videoList.count) {
            return cell
        }

        guard let videoCell = cell as? VideoTableViewCell else {
            return cell
        }

        videoCell.video = videoList[indexPath.row]

        return videoCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            let cell = tableView.cellForRow(at: indexPath) as? VideoTableViewCell,
            let video = cell.video,
            let text = cell.descriptionText
        else {
            selectedVideo = nil
            return
        }

        selectedVideo = VideoPage(video: video, text: text)
        self.performSegue(withIdentifier: "video", sender: self)
    }

}
