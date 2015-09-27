//
//  DetailViewController.swift
//  Yelp
//
//  Created by Jaimin Shah on 9/26/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import GoogleMaps

class DetailViewController: UIViewController {

    @IBOutlet weak var backdropImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var locationMapView: GMSMapView!
    
    var business: Business!

    override func viewDidLoad() {
        super.viewDidLoad()

         self.navigationController?.navigationBar.barTintColor = UIColor(red: 196.0/255.0, green: 18.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        
        titleLabel.text = business.name
        reviewLabel.text = "\(business.reviewCount!) Reviews"
        categoryLabel.text = business.categories
        phoneLabel.text = business.contactNumber
        distanceLabel.text = business.distance
        addressLabel.text = business.address
        ratingImageView.setImageWithURL(business.ratingImageURL)
        backdropImageView.setImageWithURL(business.imageURL)
       
        loadMap()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func loadMap() {
        
        var camera = GMSCameraPosition.cameraWithLatitude(business.latitude!, longitude: business.longitude!, zoom: 15)
        locationMapView.camera = camera
        locationMapView.myLocationEnabled = true
        
        var marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(business.latitude!, business.longitude!)
        marker.title = business.name!
        marker.map = locationMapView
    }

    @IBAction func onCancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)

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
