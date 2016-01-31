//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Makhmud Sunnatovich on 1/22/16.
//  Copyright © 2016 makhmudislamov. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorMessageView: UIView!
    @IBOutlet weak var filmSearchBar: UISearchBar!
    
    
   
    
    var movies: [NSDictionary]?
   var filteredMovieData: [NSDictionary]?
    var refreshControl: UIRefreshControl!
    var endpoint: String!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        filmSearchBar.delegate = self
        
        
//        let smallImageRequest = NSURLRequest(URL: NSURL(string: "https://image.tmdb.org/t/p/w45")
//        
//        let largeImageRequest = NSURLRequest(URL: NSURL(string: "https://image.tmdb.org/t/p/original")
//            
//            self.myImageView.setImageWithURLRequest(
//                smallImageRequest,
//                placeholderImage: nil,
//                success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
//                    
//                    // smallImageResponse will be nil if the smallImage is already available
//                    // in cache (might want to do something smarter in that case).
//                    self.myImageView.alpha = 0.0
//                    self.myImageView.image = smallImage;
//                    
//                    UIView.animateWithDuration(0.3, animations: { () -> Void in
//                        
//                        self.myImageView.alpha = 1.0
//                        
//                        }, completion: { (sucess) -> Void in
//                            
//                            // The AFNetworking ImageView Category only allows one request to be sent at a time
//                            // per ImageView. This code must be in the completion block.
//                            self.myImageView.setImageWithURLRequest(
//                                largeImageRequest,
//                                placeholderImage: smallImage,
//                                success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
//                                    
//                                    self.myImageView.image = largeImage;
//                                    
//                                },
//                                failure: { (request, response, error) -> Void in
//                                    // do something for the failure condition of the large image request
//                                    // possibly setting the ImageView's image to a default image
//                            })
//                    })
//                },
//                failure: { (request, response, error) -> Void in
//                    // do something for the failure condition
//                    // possibly try to get the large image
//            })
        
        
        
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        let spin = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        spin.labelText = "Loading"
        spin.detailsLabelText = "Please Wait"
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            NSLog("response: \(responseDictionary)")
                            
                            self.movies = responseDictionary["results"] as! [NSDictionary]
                            self.filteredMovieData = self.movies
                            self.tableView.reloadData()
                            
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                            
                    }
                }
                if error != nil {
                    self.errorMessageView.hidden = false
                    
                }else{
                
                    self.errorMessageView.hidden = true
                }
                
        })
        task.resume()
        
        
        
        networkRequest()
        
        
        
        
        // Do any additional setup after loading the view.
    }
    

    
    func networkRequest() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
        // ... Create the NSURLRequest (myRequest) ...
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        
        // Configure session so that completion handler is executed on main UI thread
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (data, response, error) in
                
                // ... Use the new data to update the data source ...
                
                // Reload the tableView now that there is new data
                self.tableView.reloadData()
                
                // Tell the refreshControl to stop spinning
                refreshControl.endRefreshing()	
        });
        task.resume()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = filteredMovieData {
            return movies.count
        } else{
            return 0
        }
        
        return movies!.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = filteredMovieData! [indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        
        
        if let posterPath = movie["poster_path"] as? String{
        let imageUrl = NSURL(string: baseUrl + posterPath)
        cell.posterView.setImageWithURL(imageUrl!)
            
        
            cell.selectionStyle = .None
            
            
            
        }
        
        
        print ("row \(indexPath.row)")
        return cell
        
    }
    
    
    
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        print("here")
        if searchText.isEmpty {
            filteredMovieData = movies
        } else {
            filteredMovieData = movies?.filter({ (movie: NSDictionary) -> Bool in
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
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.filmSearchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filteredMovieData = movies
        self.tableView.reloadData()
    }
    
   
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        
        let indexPath = tableView.indexPathForCell(cell)
        let movies = filteredMovieData![indexPath!.row]
        
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movie = movies
        print ("prepare for segue call")
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    }



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


