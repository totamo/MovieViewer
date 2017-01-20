//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Steve Buza on 1/6/16.
//  Copyright © 2016 Steve Buza. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController,UICollectionViewDataSource, UISearchBarDelegate, UICollectionViewDelegate{
    
    //Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    //Instance Variables
    var movies: [NSDictionary]?
    var imageUrl = NSURL()
    var filteredMovies: [NSDictionary]?
    var refreshControl: UIRefreshControl!
    var endpoint: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.endEditing(true)
        //networkErrorView.hidden = true
        //Refresh
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        collectionView.insertSubview(refreshControl, atIndex: 0)
        
        
        
        collectionView.dataSource = self
        collectionView.delegate = self
        searchBar.delegate = self
        
        //Network Request
        networkCall()  
        
        
        // Do any additional setup after loading the view.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func onRefresh() {
        print("Refreshing")
        
        //Network Request
        networkCall()
        
        delay(2, closure: {
            self.refreshControl.endRefreshing()
        })
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let filteredMovies = filteredMovies{
            return filteredMovies.count
        }
        else{
            return 0
        }
        
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 91/255, green: 173/255, blue: 255/255, alpha: 1)
        cell.selectedBackgroundView = backgroundView
        
        let movie = filteredMovies![indexPath.item]
        let title = movie["title"] as! String
        
        let rating = movie["vote_average"] as! Double
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        var posterPath = String()
        if movie["poster_path"] is NSNull{
            posterPath = ""
        }
        else{
            posterPath = movie["poster_path"] as! String
        }
        
        if posterPath == ""{
            imageUrl = NSURL(string: "http://usedrobotstrade.com/img/products/thumb_unavailable.jpg")!
        }
        else{
            imageUrl = NSURL(string: baseUrl + posterPath)!
        }
        
        cell.titleLabel.text = title
        cell.posterView.setImageWithURL(imageUrl)
        
        if rating == 0.0{
            cell.ratingLabel.text = "Unrated"
        }
        else{
            cell.ratingLabel.text = "Rating: \(rating)/10"
        }
        
        print("row \(indexPath.row)")
        
        return cell

    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        self.view.endEditing(true)
        
        print("prepare for segue")
        
        let cell = sender as! UICollectionViewCell
        let indexPath = collectionView.indexPathForCell(cell)
        let movie = filteredMovies![indexPath!.row]
        
        let secondViewController = segue.destinationViewController as! SecondViewController

        secondViewController.movie = movie
        
    }
    
    func networkCall(){
        
        //Activity
        let spinningActivity = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        spinningActivity.labelText = "Loading..."
        
        //Network Request
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            NSLog("response: \(responseDictionary)")
                            
                            print("Network is fine")
                            
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            self.filteredMovies = self.movies
                            self.collectionView.reloadData()
                    
                            spinningActivity.hide(true)
                            self.refreshControl.endRefreshing()
                            self.networkErrorView.hidden = true
                    }
                }
                else{
                    self.networkErrorView.hidden = false
                    print("Network error triggered")
                    spinningActivity.hide(true)
                }
        });
        task.resume()
      
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredMovies = movies
        } else {
            filteredMovies = movies?.filter({ (movie: NSDictionary) -> Bool in
                if let title = movie["title"] as? String {
                    if title.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                        
                        return  true
                    } else {
                        return false
                    }
                }
                return false
            })
        }
        collectionView.reloadData()
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

} // end of class
