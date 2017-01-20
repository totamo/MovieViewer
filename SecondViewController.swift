//
//  SecondViewController.swift
//  MovieViewer
//
//  Created by Steve Buza on 1/8/16.
//  Copyright © 2016 Steve Buza. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    var movie: NSDictionary!
    var image = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)
        let title = movie["title"] as? String
        titleLabel.text = title
        var overview = movie["overview"] as? String
        if overview == ""{
            overview = "Overview coming soon..."
        }
        overviewLabel.text = overview
        overviewLabel.sizeToFit()
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        var posterPath = String()
        if movie["poster_path"] is NSNull{
            posterPath = ""
        }
        else{
            posterPath = movie["poster_path"] as! String
        }
        var imageUrl: NSURL
        if posterPath == ""{
            imageUrl = NSURL(string: "http://usedrobotstrade.com/img/products/thumb_unavailable.jpg")!
        }
        else{
            imageUrl = NSURL(string: baseUrl + posterPath)!
        }
        posterView.setImageWithURL(imageUrl)
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
