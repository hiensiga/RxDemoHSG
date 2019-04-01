//
//  YTVideoTableViewCell.swift
//  RxDemoHSG
//
//  Created by HienSiGa on 3/27/19.
//  Copyright © 2019 HSG. All rights reserved.
//

import UIKit
import SwifterSwift

class YTVideoTableViewCell: UITableViewCell {

    @IBOutlet weak var ivThumbnail: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblChannel: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(_ item: YTVideo) {
        if let thumbnail = item.snippet?.thumbnail, let url = URL(string: thumbnail) {
            self.ivThumbnail.af_setImage(withURL: url)
        }
        self.lblTitle.text = item.snippet?.title
        self.lblChannel.text = item.snippet?.channelTitle
        self.lblDate.text = item.snippet?.publishedAt?.string(withFormat: "yyyy-MM-dd hh:mm:ss")
    }
    
    func configCell(_ item: YTSearchResult) {
        if let thumbnail = item.snippet?.thumbnail, let url = URL(string: thumbnail) {
            self.ivThumbnail.af_setImage(withURL: url)
        }
        self.lblTitle.text = item.snippet?.title
        self.lblChannel.text = item.snippet?.channelTitle
        self.lblDate.text = item.snippet?.publishedAt?.string(withFormat: "yyyy-MM-dd hh:mm:ss")
    }

}
