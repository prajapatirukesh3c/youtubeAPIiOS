//
//  PlayerViewController.swift
//  YTDemo
//
//  Created by Rukesh Prajapati on 7/12/17.
//  Copyright © 2017 callistos. All rights reserved.
//

import UIKit

class PlayerViewController: UIViewController {

    
    @IBOutlet weak var playerView: YTPlayerView!
    var videoID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
      guard let videoID = videoID else {
        return
      }
      playerView.load(withVideoId: videoID)
    }

}
