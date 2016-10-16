//
//  MoviesViewController.swift
//  MovieInfo
//
//  Created by Quy Tran on 10/14/16.
//  Copyright © 2016 Quy Tran. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD
import ReachabilitySwift

class MoviesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]?
    var endpoint: String!
    let refreshControl = UIRefreshControl()
    let reachability = Reachability()!
    var searchActive: Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        networkErrorView.isHidden = true
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        refreshControl.addTarget(self, action: #selector(MoviesViewController.loadMovies), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: ReachabilityChangedNotification,object: reachability)
        do {
            try reachability.startNotifier()
        } catch {
            print("could not start reachability notifier")
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMovies = self.movies?.filter({ (movie) -> Bool in
            let title = movie["title"] as! String
            return title.localizedStandardContains(searchText)
        })

        if(filteredMovies?.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        
        self.tableView.reloadData()
    }
    
    func reachabilityChanged(note: NSNotification) {
        let reachability = note.object as! Reachability
        if reachability.isReachable {
            networkErrorView.isHidden = true
            
            DispatchQueue.main.async {
                self.loadMovies()
            }
        } else {
            networkErrorView.isHidden = false
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: reachability)
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            return filteredMovies?.count ?? 0
        } else {
            if let movies = movies {
                return movies.count
            } else {
                return 0
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        cell.accessoryType = UITableViewCellAccessoryType.none
        
        var movie: NSDictionary?
        
        if searchActive {
            movie = filteredMovies?[indexPath.row]
        } else {
            movie = movies?[indexPath.row]
        }
        
        let title = movie?["title"] as! String
        cell.titleLabel.text = title
        let overview = movie?["overview"] as! String
        cell.overviewLabel.text = overview
        let basePosterUrl = "https://image.tmdb.org/t/p/w342"
        if let posterPath = movie?["poster_path"] as? String, let posterUrl = URL(string: basePosterUrl + posterPath) {
            cell.posterImage.setImageWith(posterUrl)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func loadMovies() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=\(apiKey)")
        
        let request = URLRequest(
            url: url!,
            cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue: OperationQueue.main
        )
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let task: URLSessionDataTask =
            session.dataTask(with: request,
                             completionHandler: { (dataOrNil, response, error) in
                                if (error != nil) {
                                    MBProgressHUD.hide(for: self.view, animated: true)
                                }
                                if let data = dataOrNil {
                                    if let responseDictionary = try! JSONSerialization.jsonObject(
                                        with: data, options:[]) as? NSDictionary {
                                        self.movies = responseDictionary["results"] as? [NSDictionary]
                                        self.tableView.reloadData()
                                        self.refreshControl.endRefreshing()
                                        MBProgressHUD.hide(for: self.view, animated: true)
                                    }
                                }
            })
        task.resume()
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = tableView.indexPathForSelectedRow
        let movie = movies?[(indexPath?.row)!]
        let movieDetailVC = segue.destination as! MovieDetailViewController
        
        movieDetailVC.movie = movie
    }
}
