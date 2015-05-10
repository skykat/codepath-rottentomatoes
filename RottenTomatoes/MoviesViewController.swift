//
//  MoviesViewController.swift
//  RottenTomatoes
//
//  Created by Karen Levy on 5/8/15.
//  Copyright (c) 2015 Karen Levy. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var tableView: UITableView!
    var clientId = "34248852d34847b68c4d871387bbad61"
    // I do not have access to rotten tomatoes just yet
    var movies: [NSDictionary]?
    var refreshController: UIRefreshControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        //let url = NSURL(string: "https://api.instagram.com/v1/media/popular?client_id=\(clientId)")!
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
                }
               
            }else{
                println("error \(error.localizedDescription)")
            }
           
        }
        
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
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
        
        cell.titleLabel.text = movie["title"] as? String
        cell.synopsisLabel.text = movie["synopsis"] as? String
    
        let url = NSURL(string: movie.valueForKeyPath("posters.thumbnail") as! String)!
        cell.posterView.setImageWithURL(url)
        
        
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

    
  
    

}
