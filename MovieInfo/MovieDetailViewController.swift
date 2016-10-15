//
//  MovieDetailViewController.swift
//  MovieInfo
//
//  Created by Quy Tran on 10/14/16.
//  Copyright © 2016 Quy Tran. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var detailTopNavigation: UINavigationItem!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let title = movie?["title"] as! String
        titleLabel.text = title
        detailTopNavigation.title = title
        let releaseDate = movie?["release_date"] as! String
        dateLabel.text = releaseDate
        let averageRating = movie?["vote_average"] as! Float
        ratingLabel.text = String(averageRating) + " %"
        let likeCount = movie?["vote_count"] as! Int
        likeLabel.text = String(likeCount)
        
        let overview = movie?["overview"] as! String
        overviewLabel.text = overview
        overviewLabel.sizeToFit()
        
        let basePosterUrl = "https://image.tmdb.org/t/p/w500"
        if let posterPath = movie?["poster_path"] as? String, let posterUrl = URL(string: basePosterUrl + posterPath) {
            posterImage.setImageWith(posterUrl)
        }
        
        scrollView.contentSize = CGSize(width: scrollView.bounds.size.width, height: infoView.frame.origin.y + infoView.frame.size.height + 10)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
