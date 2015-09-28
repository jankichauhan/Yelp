//
//  BusinessesViewController.swift
//  Yelp
//
// Created by Janki Chauhan on 9/22/15.


import UIKit

class BusinessesViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, FilterViewControllerDelegate, UISearchBarDelegate {

    var businesses: [Business]!
    var searchBar: UISearchBar!
    var searchLimit:Int!
    
    @IBOutlet weak var tableView: UITableView!
    var isLoading = false
    
    var loadingIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 196.0/255.0, green: 18.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [ NSForegroundColorAttributeName: UIColor.whiteColor()]

        searchLimit = 7
        searchBar = UISearchBar()
        searchBar.sizeToFit()
        searchBar.delegate = self
        navigationItem.titleView = searchBar

        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        var tableFooterView = UIView(frame: CGRectMake(0, 0, 320, 50))
        loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        loadingIndicator.startAnimating()
        loadingIndicator.center = tableFooterView.center
        tableFooterView.addSubview(loadingIndicator)
        
        self.tableView.tableFooterView = tableFooterView;

        Business.searchWithTerm("Thai", limit: searchLimit, completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
           //update table view when new data
            self.tableView.reloadData()
            
            for business in businesses {
                if business.reviewCount != nil {
                 println(business.reviewCount)
                }
                println(business.name!)
                println(business.address!)
            }
        })

    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        cell.business = businesses[indexPath.row]
        if indexPath.row == (searchLimit-1) && searchLimit < 19 {
            reloadData()
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil{
            return businesses!.count
        } else {
            return 0
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        Business.searchWithTerm(searchBar.text,limit:20, completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
        })
        self.searchBar.endEditing(true)

    }
        
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        //println("search change")
    }
    
    func reloadData(){
        
        if (!self.isLoading) {
            self.isLoading = true
            searchLimit = searchLimit + 2
        
            //sleep(10)
            Business.searchWithTerm("Thai",limit: searchLimit, completion: { (businesses: [Business]!, error: NSError!) -> Void in
                self.businesses = businesses
                self.tableView.reloadData()
            })
            self.loadingIndicator.stopAnimating()
            self.isLoading = false
        }
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let navigationController = segue.destinationViewController as! UINavigationController
        
        if navigationController.topViewController is FilterViewController {
            let filtersViewController = navigationController.topViewController as! FilterViewController
            filtersViewController.delegate = self
            
        } else if navigationController.topViewController is DetailViewController {
            let detailViewController = navigationController.topViewController as! DetailViewController
            var indexPath: AnyObject!
            indexPath = tableView.indexPathForCell(sender as! UITableViewCell)
            detailViewController.business = businesses[indexPath!.row]
        }

    }

    func filterViewController(filterviewcontroller: FilterViewController, didUpdateValue filter: [String : AnyObject]) {
        
        var categories = filter["categories"] as? [String]
        var radius = filter["radius"] as? Float?
        var deals = filter["deals"] as? Bool
        let sort = filter["sort"] as! Int
        var sortBy:YelpSortMode!
        
        switch sort{
            case 0:
                sortBy = YelpSortMode.BestMatched
            case 1:
                sortBy = YelpSortMode.Distance
            case 2:
                sortBy = YelpSortMode.HighestRated
        default:
            sortBy = YelpSortMode.BestMatched
        }
        var searchTerm = searchBar.text ?? "Resturants"
        println(" search filters \(categories), distance  \(radius), deals \(deals), sort by \(sort)" )
        
       Business.searchWithTerm(searchTerm, limit:20, sort: sortBy, categories: categories, deals: deals) { (businesses:[Business]!, error:NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
        }
    }

}
