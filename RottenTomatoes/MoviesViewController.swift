//
//  MoviesViewController.swift
//  RottenTomatoes
//
//  Created by Karen Levy on 5/8/15.
//  Copyright (c) 2015 Karen Levy. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating{
    
    @IBOutlet weak var tableView: UITableView!
    var clientId = "34248852d34847b68c4d871387bbad61"
    
    var movies: [NSDictionary]?
    var refreshController: UIRefreshControl?
    
    var tableData = [String]()
    var filteredTableData = [String]()
    var resultSearchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // I never got access to rottentomatoes api after a week of registration
        let url = NSURL(string: "https://gist.githubusercontent.com/timothy1ee/e41513a57049e21bc6cf/raw/b490e79be2d21818f28614ec933d5d8f467f0a66/gistfile1.json")!
        let request = NSURLRequest(URL: url)
        SVProgressHUD.show()
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if(error == nil){
                let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? NSDictionary
                if let json = json{
                    self.movies = json["movies"] as? [NSDictionary]
                    self.tableView.reloadData()
                    SVProgressHUD.dismiss()
                    
                    
                    for var i = 0; i <  self.movies!.count; i++
                    {
                        var movie = self.movies![i]
                        var t = movie["title"] as? String
                        var s = movie["synopsis"] as? String
                        var p = movie.valueForKeyPath("posters.thumbnail") as? String!
                        
                        self.tableData.append(t!)
                        
                        println((movie["title"] as? String))
                        println((movie["synopsis"] as? String))
                        println((movie.valueForKeyPath("posters.thumbnail") as? String!))
                    }
                }
                
            }else{
                println("error \(error.localizedDescription)")
            }
            
        }
        
        
        
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            
            self.tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        
        self.refreshController = UIRefreshControl()
        self.refreshController?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshController!)
        
        // specify a dataSource
        self.tableView.dataSource = self
        // capture all the events
        self.tableView.delegate = self
        
    }
    
    func refresh(sender:AnyObject)
    {
        let url = NSURL(string: "https://gist.githubusercontent.com/timothy1ee/e41513a57049e21bc6cf/raw/b490e79be2d21818f28614ec933d5d8f467f0a66/gistfile1.json")!
        let request = NSURLRequest(URL: url)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? NSDictionary
            if let json = json{
                self.movies = json["movies"] as? [NSDictionary]
                self.tableView.reloadData()
                self.refreshController?.endRefreshing()
            }
            // println(json)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        if (self.resultSearchController.active) {
            return self.filteredTableData.count
        }
        
        if let movies = movies{
            return movies.count
        }else{
            return 0
        }
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        let movie = movies![indexPath.row]
        
        
        
        if (self.resultSearchController.active) {
            cell.titleLabel.text = filteredTableData[indexPath.row]
            
            
        }else{
            cell.titleLabel.text = movie["title"] as? String
            cell.synopsisLabel.text = movie["synopsis"] as? String
            
            let url = NSURL(string: movie.valueForKeyPath("posters.thumbnail") as! String)!
            cell.posterView.setImageWithURL(url)
        }
        
      
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)!
        let movie = movies![indexPath.row]
        let movieDetailsViewController = segue.destinationViewController as! MovieDetailsViewController
        movieDetailsViewController.movie = movie
        
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        println("movies count: \(self.movies?.count)")
        if(self.movies?.count == nil){
            
            let myTimer : NSTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("cancelSpinner:"), userInfo: nil, repeats: false)
            if(section == 0) {
                var title: UILabel = UILabel()
                title.backgroundColor = UIColor.blueColor().colorWithAlphaComponent(0.1)
                title.textAlignment = NSTextAlignment.Center
                title.text = "Network Error"
                return title
            }
        }
        
        return nil
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(self.movies?.count == nil){
            return 50
        }else{
            return 0
        }
        
    }
    
    func cancelSpinner(timer : NSTimer) {
        SVProgressHUD.dismiss()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filteredTableData.removeAll(keepCapacity: false)
        
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text)
        let array = (tableData as NSArray).filteredArrayUsingPredicate(searchPredicate)
        filteredTableData = array as! [String]
        
        self.tableView.reloadData()
    }
    
    
    
}