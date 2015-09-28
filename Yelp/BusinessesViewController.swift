//
//  BusinessesViewController.swift
//  Yelp
//
// Created by Janki Chauhan on 9/22/15.


import UIKit
import GoogleMaps

class BusinessesViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, FilterViewControllerDelegate, UISearchBarDelegate, GMSMapViewDelegate {

    var businesses: [Business]!
    var searchBar: UISearchBar!
    var searchLimit:Int!
    
    @IBOutlet weak var mapButoon: UIBarButtonItem!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var tableView: UITableView!
    
    var isLoading = false
    var totalNumberOfResult = 0
    var darkColor = UIColor(red: 190/255, green: 38/255, blue: 37/255, alpha: 1.0)
    var lightColor = UIColor(red: 220/255, green: 140/255, blue: 140/255, alpha: 1.0)

    
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

        Business.searchWithTerm("", limit: searchLimit, completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.totalNumberOfResult = businesses.count
           //update table view when new data
            self.tableView.reloadData()
            self.setTableViewVisible()
            self.createMarkers()
            for business in businesses {
                println(business.name!)
                println(business.address!)
            }
        })
        
        mapView.delegate = self
        mapView.hidden = true

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
            self.createMarkers()

        })
        
        self.setTableViewVisible()
        searchBar.resignFirstResponder()
        self.searchBar.endEditing(true)

    }
        
    func setTableViewVisible() {
        
        if totalNumberOfResult > 0 {
            var buttonText = mapButoon.title
            if buttonText == "Map" {
                tableView.hidden = false
                mapView.hidden = true
            } else {
                tableView.hidden = true
                mapView.hidden = false
            }
        } else {
            tableView.hidden = true
            mapView.hidden = true
        }
    }
    
    func reloadData(){
        
        if (!self.isLoading) {
            self.isLoading = true
            searchLimit = searchLimit + 2
            var searchTerm = searchBar.text ?? ""
            
            //sleep(10)
            Business.searchWithTerm(searchTerm,limit: searchLimit, completion: { (businesses: [Business]!, error: NSError!) -> Void in
                self.businesses = businesses
                self.tableView.reloadData()
            })
            self.loadingIndicator.stopAnimating()
            self.isLoading = false
        }
    }
    
    @IBAction func onMapButton(sender: AnyObject) {
        
        var buttonText = mapButoon.title
        if buttonText == "Map" {
            tableView.hidden = true
            mapView.hidden = false
            
            mapButoon.title = "List"
        } else {
            tableView.hidden = false
            mapView.hidden = true
            
            mapButoon.title = "Map"
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

    func createMarkers() {
        
        // Clear all markers before creating new ones
        mapView.clear()
        
        if businesses.count > 0 {
            var camera = GMSCameraPosition.cameraWithLatitude(businesses[0].latitude!, longitude: businesses[0].longitude!, zoom: 15)
            mapView.camera = camera
            mapView.myLocationEnabled = true
            
            // Create maker for each business
            for i in 0..<businesses!.count {
                var marker = GMSMarker()
                marker.position = CLLocationCoordinate2DMake(businesses[i].latitude!, businesses[i].longitude!)
                marker.title = businesses[i].name
                marker.map = mapView
            }
        }
    }

    func mapView(mapView: GMSMapView!, markerInfoWindow marker: GMSMarker!) -> UIView! {
        
        var (business, index) = getBusinessDetailFromMarker(marker)
        
        var window = UIView(frame: CGRect(x: 0, y: 0, width: 250, height: 90))
//        window.layer.backgroundColor = UIColor(red: 250/255, green: 234/255, blue: 234/255, alpha: 1).CGColor
        window.layer.backgroundColor = UIColor.whiteColor().CGColor

        
        window.layer.cornerRadius = 5
       // window.layer.borderColor = UIColor(red: 190/255, green: 38/255, blue: 37/255, alpha: 1.0).CGColor
        window.layer.borderColor = UIColor.grayColor().CGColor

        window.layer.borderWidth = 1
        
        var titleLabel = UILabel(frame: CGRect(x: 8, y: 8, width: 184, height: 18))
        titleLabel.text = String(index + 1) + ". " + business!.name!
        titleLabel.font = UIFont.boldSystemFontOfSize(14)
        titleLabel.textColor = UIColor.blackColor()
        titleLabel.numberOfLines = 0
        titleLabel.sizeToFit()
        window.addSubview(titleLabel)
        
        var distanceLabel = UILabel(frame: CGRect(x: 200, y: 8, width: 42, height: 14))
        distanceLabel.text = business!.distance
        distanceLabel.font = UIFont.systemFontOfSize(12)
        distanceLabel.textColor = UIColor.grayColor()
        window.addSubview(distanceLabel)
        
        var ratings = titleLabel.bounds.origin.y + titleLabel.frame.height + 12
        var ratingImageView = UIImageView(frame: CGRect(x: 8, y: ratings, width: 83, height: 15))
        ratingImageView.setImageWithURL(business!.ratingImageURL)
        window.addSubview(ratingImageView)
        
        var reviewsLabel = UILabel(frame: CGRect(x: 99, y: ratings, width: 78, height: 14))
        reviewsLabel.text = "\(business!.reviewCount!) Reviews"
        reviewsLabel.font = UIFont.systemFontOfSize(12)
        reviewsLabel.textColor = UIColor.grayColor()
        window.addSubview(reviewsLabel)
        
        var priceLabel = UILabel(frame: CGRect(x: 228, y: ratings, width: 14, height: 14))
        priceLabel.text = "$$"
        priceLabel.font = UIFont.systemFontOfSize(12)
        priceLabel.textColor = UIColor.grayColor()
        window.addSubview(priceLabel)
        
        var address = ratings + ratingImageView.frame.height + 4
        var addressLabel = UILabel(frame: CGRect(x: 8, y: address, width: 234, height: 14))
        addressLabel.text = business!.address!
        addressLabel.font = UIFont.systemFontOfSize(12)
        addressLabel.textColor = UIColor.blackColor()
        addressLabel.numberOfLines = 0
        addressLabel.sizeToFit()
        window.addSubview(addressLabel)
        
        var categories = address + addressLabel.frame.height + 4
        var categoriesLabel = UILabel(frame: CGRect(x: 8, y: categories, width: 234, height: 14))
        categoriesLabel.text = business!.categories!
        categoriesLabel.font = UIFont.systemFontOfSize(12)
        categoriesLabel.textColor = UIColor.grayColor()
        categoriesLabel.numberOfLines = 0
        categoriesLabel.sizeToFit()
        window.addSubview(categoriesLabel)
        
        var viewHeight = categories + categoriesLabel.frame.height + 8
        window.frame = CGRect(x: 0, y: 0, width: 250, height: viewHeight)
        
        return window
    }
    
    func mapView(mapView: GMSMapView!, didTapInfoWindowOfMarker marker: GMSMarker!) {
        
        var detailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("DetailNavigationController") as! DetailViewController
        var navigationController = UINavigationController(rootViewController: detailViewController)
        
        var (business, index) = getBusinessDetailFromMarker(marker)
        detailViewController.business = business
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func getBusinessDetailFromMarker(marker: GMSMarker) -> (Business?, Int) {
        
        var latitude = Double(marker.position.latitude)
        var longitude = Double(marker.position.longitude)
        
        for i in 0..<businesses!.count {
            let businessLatitude = businesses[i].latitude as Double!
            let businessLongitude = businesses[i].longitude as Double!
            if businessLatitude == latitude && businessLongitude == longitude {
                return (businesses[i], i)
            }
        }
        
        return (nil, -1)
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
        var searchTerm = searchBar.text ?? ""
        println(" search filters \(categories), distance  \(radius), deals \(deals), sort by \(sort)" )
        
       Business.searchWithTerm(searchTerm, limit:20, sort: sortBy, categories: categories, deals: deals) { (businesses:[Business]!, error:NSError!) -> Void in
        
            self.totalNumberOfResult = businesses.count
            self.businesses = businesses
            self.tableView.reloadData()
            self.createMarkers()
        }
        self.setTableViewVisible()

    }

}
