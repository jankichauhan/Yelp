//
//  FilterViewController.swift
//  Yelp
//
// Created by Janki Chauhan on 9/22/15.
//

import UIKit

@objc protocol FilterViewControllerDelegate{
    
    optional func filterViewController(filterviewcontroller:FilterViewController, didUpdateValue filter: [String:AnyObject])
}

class FilterViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,SwitchCellDelegate {

        
    @IBOutlet weak var tableView: UITableView!
    var data:[(String,[AnyObject])]!
    var arrayForBool : NSMutableArray = NSMutableArray()
    var categories: [[String:String]]!
    var distances: [String]!
    var sortBy: [String]!
    var switchStates = [Int:Bool]()
    var radius: String! = "0"
    var sort: String! = "0"
    var deals: Bool! = false
    var isCategoryCollapsed = true

    weak var delegate:FilterViewControllerDelegate?
    
    let CellIdentifier = "TableViewCell", HeaderViewIdentifier = "TableViewHeaderView"

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.barTintColor = UIColor(red: 196.0/255.0, green: 18.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        
        categories = yelpCategories()
        distances = yelpDistance()
        sortBy = yelpSortBy()

        data = [("Deal", ["Offers a deal"]),
            ("Distance", ["Default"]),
            ("Sort By", ["Best Match"]),
            ("Category", yelpCategories())]
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: HeaderViewIdentifier)
        self.tableView.tableFooterView = UIView()


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func onSearchButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        
        var filters = [String : AnyObject]()
        var selectedCategories = [String]()
        
        for (row, isSelected) in switchStates {
            if(isSelected) {
                selectedCategories.append(categories[row]["code"]!)
            }
        }
        
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories
        }
        
        println("radius \(radius)")
        println(" sort \(sort)")
        println(" deals \(deals)")
        
        filters["radius"] = radius
        filters["sort"] = sort
        filters["deals"] = deals
        
        delegate?.filterViewController?(self, didUpdateValue: filters)

    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 1
        case 3:
            return categories.count + 1
        case 4:
            return 1
        default:
            break
        }
        
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
       // let sectionSelected = data[indexPath.section].1
        println(indexPath.row)
        switch indexPath.section {
        case 0:
            // Deal area
            let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
          
            cell.categoryLabel.text = "Offering a deal"
            cell.onSwitch.hidden = false
            cell.sortControl.hidden = true
            cell.radiusSlider.hidden = true
            cell.sliderLabel.hidden = true
            cell.delegate = self
            
            return cell
            
        case 1:
            // Radius area
            
            let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
            
            cell.categoryLabel.hidden = true
            cell.sortControl.hidden = true
            cell.radiusSlider.hidden = false
            cell.onSwitch.hidden = true
            cell.sliderLabel.hidden = false
            cell.delegate = self
            
            return cell
            
        case 2:
            // Sort area
            let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
           
            cell.categoryLabel.hidden = true
            cell.sortControl.hidden = false
            cell.radiusSlider.hidden = true
            cell.onSwitch.hidden = true
            cell.sliderLabel.hidden = true
            cell.delegate = self
            
            return cell
            
        case 3:
            // Category area
            
            
            if indexPath.row != categories.count {
                let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
                
                cell.categoryLabel.text = categories[indexPath.row]["name"]
                cell.delegate = self
                
                cell.onSwitch.on = switchStates[indexPath.row] ?? false
                
                cell.onSwitch.hidden = false
                cell.sortControl.hidden = true
                cell.radiusSlider.hidden = true
                cell.sliderLabel.hidden = true
                cell.delegate = self
                
                cell.onSwitch.on = switchStates[indexPath.row] ?? false
                
                setCategoryCellVisible(indexPath.row, cell: cell)
                
                return cell

            } else {
                
                println("in else")
                let cell = tableView.dequeueReusableCellWithIdentifier("SeeAllCell", forIndexPath: indexPath) as! SeeAllCell
                
                let clickToSeeAll = UITapGestureRecognizer(target: self, action: "clickToSeeAll:")
                cell.addGestureRecognizer(clickToSeeAll)
                
                return cell
                
            }
            
        case 4:
            // Reset row
            
            let cell = tableView.dequeueReusableCellWithIdentifier("SeeAllCell", forIndexPath: indexPath) as! SeeAllCell
            cell.seeAllLabel.text = "Reset filters"
            cell.seeAllLabel.textColor = UIColor(red: 190/255, green: 38/255, blue: 37/255, alpha: 1.0)
            let clickToReset = UITapGestureRecognizer(target: self, action: "clickToReset:")
            cell.addGestureRecognizer(clickToReset)
            
            return cell
            
        default:
            let cell = UITableViewCell()
            return cell
        }

            //println(indexPath.section+indexPath.row)
        
    }
    
    func switchCell(switchCell: SwitchCell, didValueChange val: Bool) {
        println(" switch cell change \(val)")
        let indexPath = tableView.indexPathForCell(switchCell)!
        
        // first row is for deals
        if indexPath.row == 0 {
            deals = val
        } else {
            switchStates[indexPath.row] = val
        }
        
    }
    
    func switchCellSlider(sliderLabel: UILabel, didValueChange val: Int) {
        radius = "\(val)"
    }
    
    func switchCellSegment(sortSegment: UISegmentedControl, didValueChange val: Int) {
            sort = "\(val)"
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier(HeaderViewIdentifier) as! UITableViewHeaderFooterView
        
        switch section {
        case 0:
            header.textLabel.text = "Deal"
            break
        case 1:
            header.textLabel.text = "Distance"
            break
        case 2:
            header.textLabel.text = "Sort By"
            break
        case 3:
            header.textLabel.text = "Category"
            break
        default:
            return nil
        }

        return header
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 3:
            if isCategoryCollapsed {
                if indexPath.row > 2 && indexPath.row != categories.count {
                    return 0
                }
            }
            break
        default:
            break
        }
        
        return 50.0
    }

    
    func setCategoryCellVisible(row: Int, cell: SwitchCell) {
        
        println("in setCategoryCellVisible")
        if isCategoryCollapsed && row > 2 && row != categories.count {
            println("in setCategoryCellVisible \(row)")
            cell.categoryLabel.hidden = true
            cell.onSwitch.hidden = true
            return
        }
        
        cell.categoryLabel.hidden = false
        cell.onSwitch.hidden = false
    }
    
    func clickToSeeAll(sender:UITapGestureRecognizer) {
        
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: categories.count, inSection: 3)) as! SeeAllCell
        
        if cell.seeAllLabel.text == "See All" {
            cell.seeAllLabel.text = "Collapse"
            isCategoryCollapsed = false
        } else {
            cell.seeAllLabel.text = "See All"
            isCategoryCollapsed = true
        }
        
        tableView.reloadData()
    }

    func clickToReset(sender:UITapGestureRecognizer) {
        
      //  filters["deal"] = false
        //filters["radius"] = radii[0]
        //filters["sort"] = 0
        switchStates.removeAll(keepCapacity: false)
        
        tableView.reloadData()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func yelpSortBy() -> [String] {
        return ["Best Match", "Distance", "Best Rated"]
    }
    
    func yelpDistance() -> [String] {
        return ["Default","0.5", "1.0", "10.0", "20.0"]
    }
    
    func yelpCategories() -> [[String:String]] {
        return [["name" : "Afghan", "code": "afghani"],
        ["name" : "African", "code": "african"],
        ["name" : "American, New", "code": "newamerican"],
        ["name" : "American, Traditional", "code": "tradamerican"],
//        ["name" : "Arabian", "code": "arabian"],
//        ["name" : "Argentine", "code": "argentine"],
//        ["name" : "Armenian", "code": "armenian"],
        ["name" : "Asian Fusion", "code": "asianfusion"],
//        ["name" : "Asturian", "code": "asturian"],
//        ["name" : "Australian", "code": "australian"],
//        ["name" : "Austrian", "code": "austrian"],
//        ["name" : "Baguettes", "code": "baguettes"],
//        ["name" : "Bangladeshi", "code": "bangladeshi"],
//        ["name" : "Barbeque", "code": "bbq"],
//        ["name" : "Basque", "code": "basque"],
//        ["name" : "Bavarian", "code": "bavarian"],
//        ["name" : "Beer Garden", "code": "beergarden"],
//        ["name" : "Beer Hall", "code": "beerhall"],
//        ["name" : "Beisl", "code": "beisl"],
//        ["name" : "Belgian", "code": "belgian"],
        ["name" : "Bistros", "code": "bistros"],
//        ["name" : "Black Sea", "code": "blacksea"],
//        ["name" : "Brasseries", "code": "brasseries"],
//        ["name" : "Brazilian", "code": "brazilian"],
        ["name" : "Breakfast & Brunch", "code": "breakfast_brunch"],
//        ["name" : "British", "code": "british"],
        ["name" : "Buffets", "code": "buffets"],
//        ["name" : "Bulgarian", "code": "bulgarian"],
//        ["name" : "Burgers", "code": "burgers"],
        ["name" : "Burmese", "code": "burmese"],
//        ["name" : "Cafes", "code": "cafes"],
//        ["name" : "Cafeteria", "code": "cafeteria"],
        ["name" : "Cajun/Creole", "code": "cajun"],
//        ["name" : "Cambodian", "code": "cambodian"],
//        ["name" : "Canadian", "code": "New)"],
//        ["name" : "Canteen", "code": "canteen"],
        ["name" : "Caribbean", "code": "caribbean"],
//        ["name" : "Catalan", "code": "catalan"],
//        ["name" : "Chech", "code": "chech"],
        ["name" : "Cheesesteaks", "code": "cheesesteaks"],
//        ["name" : "Chicken Shop", "code": "chickenshop"],
//        ["name" : "Chicken Wings", "code": "chicken_wings"],
//        ["name" : "Chilean", "code": "chilean"],
        ["name" : "Chinese", "code": "chinese"],
//        ["name" : "Comfort Food", "code": "comfortfood"],
//        ["name" : "Corsican", "code": "corsican"],
        ["name" : "Creperies", "code": "creperies"],
        ["name" : "Cuban", "code": "cuban"],
//        ["name" : "Curry Sausage", "code": "currysausage"],
//        ["name" : "Cypriot", "code": "cypriot"],
        ["name" : "Czech", "code": "czech"],
//        ["name" : "Czech/Slovakian", "code": "czechslovakian"]
//        ["name" : "Danish", "code": "danish"],
//        ["name" : "Delis", "code": "delis"],
        ["name" : "Diners", "code": "diners"],
//        ["name" : "Dumplings", "code": "dumplings"],
//        ["name" : "Eastern European", "code": "eastern_european"],
        ["name" : "Ethiopian", "code": "ethiopian"],
        ["name" : "Fast Food", "code": "hotdogs"],
//        ["name" : "Filipino", "code": "filipino"],
        ["name" : "Fish & Chips", "code": "fishnchips"],
        ["name" : "Fondue", "code": "fondue"],
//        ["name" : "Food Court", "code": "food_court"],
//        ["name" : "Food Stands", "code": "foodstands"],
        ["name" : "French", "code": "french"],
//        ["name" : "French Southwest", "code": "sud_ouest"],
//        ["name" : "Galician", "code": "galician"],
//        ["name" : "Gastropubs", "code": "gastropubs"],
//        ["name" : "Georgian", "code": "georgian"],
        ["name" : "German", "code": "german"],
//        ["name" : "Giblets", "code": "giblets"],
//        ["name" : "Gluten-Free", "code": "gluten_free"],
        ["name" : "Greek", "code": "greek"],
        ["name" : "Halal", "code": "halal"],
        ["name" : "Hawaiian", "code": "hawaiian"],
//        ["name" : "Heuriger", "code": "heuriger"],
        ["name" : "Himalayan/Nepalese", "code": "himalayan"],
//        ["name" : "Hong Kong Style Cafe", "code": "hkcafe"],
//        ["name" : "Hot Dogs", "code": "hotdog"],
//        ["name" : "Hot Pot", "code": "hotpot"],
//        ["name" : "Hungarian", "code": "hungarian"],
//        ["name" : "Iberian", "code": "iberian"],
        ["name" : "Indian", "code": "indpak"],
//        ["name" : "Indonesian", "code": "indonesian"],
        ["name" : "International", "code": "international"],
        ["name" : "Irish", "code": "irish"],
//        ["name" : "Island Pub", "code": "island_pub"],
//        ["name" : "Israeli", "code": "israeli"],
        ["name" : "Italian", "code": "italian"],
        ["name" : "Japanese", "code": "japanese"],
//        ["name" : "Jewish", "code": "jewish"],
//        ["name" : "Kebab", "code": "kebab"],
        ["name" : "Korean", "code": "korean"],
//        ["name" : "Kosher", "code": "kosher"],
//        ["name" : "Kurdish", "code": "kurdish"],
//        ["name" : "Laos", "code": "laos"],
       ["name" : "Laotian", "code": "laotian"],
       ["name" : "Latin American", "code": "latin"],
//        ["name" : "Live/Raw Food", "code": "raw_food"],
//        ["name" : "Lyonnais", "code": "lyonnais"],
        ["name" : "Malaysian", "code": "malaysian"],
//        ["name" : "Meatballs", "code": "meatballs"],
        ["name" : "Mediterranean", "code": "mediterranean"],
        ["name" : "Mexican", "code": "mexican"],
        ["name" : "Middle Eastern", "code": "mideastern"],
//        ["name" : "Milk Bars", "code": "milkbars"],
//        ["name" : "Modern Australian", "code": "modern_australian"],
//        ["name" : "Modern European", "code": "modern_european"],
        ["name" : "Mongolian", "code": "mongolian"],
        ["name" : "Moroccan", "code": "moroccan"],
//        ["name" : "New Zealand", "code": "newzealand"],
//        ["name" : "Night Food", "code": "nightfood"],
//        ["name" : "Norcinerie", "code": "norcinerie"],
//        ["name" : "Open Sandwiches", "code": "opensandwiches"],
//        ["name" : "Oriental", "code": "oriental"],
        ["name" : "Pakistani", "code": "pakistani"],
//        ["name" : "Parent Cafes", "code": "eltern_cafes"],
//        ["name" : "Parma", "code": "parma"],
//        ["name" : "Persian/Iranian", "code": "persian"],
//        ["name" : "Peruvian", "code": "peruvian"],
//        ["name" : "Pita", "code": "pita"],
        ["name" : "Pizza", "code": "pizza"],
//        ["name" : "Polish", "code": "polish"],
//        ["name" : "Portuguese", "code": "portuguese"],
//        ["name" : "Potatoes", "code": "potatoes"],
//        ["name" : "Poutineries", "code": "poutineries"],
//        ["name" : "Pub Food", "code": "pubfood"],
//        ["name" : "Rice", "code": "riceshop"],
//        ["name" : "Romanian", "code": "romanian"],
//        ["name" : "Rotisserie Chicken", "code": "rotisserie_chicken"],
//        ["name" : "Rumanian", "code": "rumanian"],
        ["name" : "Russian", "code": "russian"],
//        ["name" : "Salad", "code": "salad"],
//        ["name" : "Sandwiches", "code": "sandwiches"],
        ["name" : "Scandinavian", "code": "scandinavian"],
//        ["name" : "Scottish", "code": "scottish"],
        ["name" : "Seafood", "code": "seafood"],
//        ["name" : "Serbo Croatian", "code": "serbocroatian"],
//        ["name" : "Signature Cuisine", "code": "signature_cuisine"],
//        ["name" : "Singaporean", "code": "singaporean"],
//        ["name" : "Slovakian", "code": "slovakian"],
//        ["name" : "Soul Food", "code": "soulfood"],
//        ["name" : "Soup", "code": "soup"],
//        ["name" : "Southern", "code": "southern"],
//        ["name" : "Spanish", "code": "spanish"],
        ["name" : "Steakhouses", "code": "steak"],
        ["name" : "Sushi Bars", "code": "sushi"],
//        ["name" : "Swabian", "code": "swabian"],
        ["name" : "Swedish", "code": "swedish"],
//        ["name" : "Swiss Food", "code": "swissfood"],
//        ["name" : "Tabernas", "code": "tabernas"],
//        ["name" : "Taiwanese", "code": "taiwanese"],
        ["name" : "Tapas Bars", "code": "tapas"],
//        ["name" : "Tapas/Small Plates", "code": "tapasmallplates"],
        ["name" : "Tex-Mex", "code": "tex-mex"],
        ["name" : "Thai", "code": "thai"],
//        ["name" : "Traditional Norwegian", "code": "norwegian"],
//        ["name" : "Traditional Swedish", "code": "traditional_swedish"],
//        ["name" : "Trattorie", "code": "trattorie"],
//        ["name" : "Turkish", "code": "turkish"],
//        ["name" : "Ukrainian", "code": "ukrainian"],
//        ["name" : "Uzbek", "code": "uzbek"],
        ["name" : "Vegan", "code": "vegan"],
        ["name" : "Vegetarian", "code": "vegetarian"],
//        ["name" : "Venison", "code": "venison"],
        ["name" : "Vietnamese", "code": "vietnamese"],
//        ["name" : "Wok", "code": "wok"],
//        ["name" : "Wraps", "code": "wraps"],
//        ["name" : "Yugoslav", "code": "yugoslav"]
        ]}

}
