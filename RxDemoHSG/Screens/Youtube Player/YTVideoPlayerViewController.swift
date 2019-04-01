//
//  YTVideoPlayerViewController.swift
//  RxDemoHSG
//
//  Created by HienSiGa on 4/1/19.
//  Copyright © 2019 HSG. All rights reserved.
//

import UIKit
import XCDYouTubeKit

class YTVideoPlayerViewController: UIViewController {

    var videoId: String!
    @IBOutlet weak var playerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadVideo(id: videoId)
    }
    
    func loadVideo(id: String) {
        let playerViewController = XCDYouTubeVideoPlayerViewController(videoIdentifier: videoId)
        // playerViewController.moviePlayer.backgroundPlaybackEnabled = true
        playerViewController.present(in: playerView)
        playerViewController.moviePlayer.prepareToPlay()
        playerViewController.moviePlayer.shouldAutoplay = true
    }

    @IBAction func tapClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
