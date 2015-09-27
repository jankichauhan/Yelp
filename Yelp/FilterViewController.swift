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

class FilterViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,SwitchCellDelegate,CollapseViewCellDelegate {

        
    @IBOutlet weak var tableView: UITableView!

    var categories: [[String:String]]!
    var distances: [Float?]!
    var sortBy: [String]!
    
    var switchStates = [Int:Bool]()
    var filters = [String : AnyObject]()
    
    var radius: String! = "0"
    var sort: String! = "0"
    var deals: Bool! = false
    
    var isCategoryCollapsed = true
    var isDistanceCollapsed = true
    var isSortByCollapsed = true


    weak var delegate:FilterViewControllerDelegate?
    
    let CellIdentifier = "TableViewCell", HeaderViewIdentifier = "TableViewHeaderView"

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.barTintColor = UIColor(red: 196.0/255.0, green: 18.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        
        categories = yelpCategories()
        distances = yelpDistance()
        sortBy = yelpSortBy()

        filters["deals"] = false
        filters["radius"] = distances[0]
        filters["sort"] = 0
        
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
        
        var selectedCategories = [String]()
        
        for (row, isSelected) in switchStates {
            if(isSelected) {
                selectedCategories.append(categories[row]["code"]!)
            }
        }
        
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories
        }
        
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
            return distances.count
        case 2:
            return 3
        case 3:
            return categories.count + 1
        default:
            break
        }
        
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
       // println(indexPath.row)
        switch indexPath.section {
        case 0:
            // Deal area
            let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
          
            cell.categoryLabel.text = "Offering a deal"
            cell.onSwitch.hidden = false
            
            cell.onSwitch.on = filters["deals"] as? Bool ?? false

            cell.delegate = self
            
            return cell
            
        case 1:
            
            let cell = tableView.dequeueReusableCellWithIdentifier("CollapseViewCell", forIndexPath: indexPath) as! CollapseViewCell
            cell.delegate = self

            if indexPath.row == 0{
                cell.optionsLabel.text = "Auto"
            } else if indexPath.row == 1 {
                cell.optionsLabel.text = String(format: "%g", distances[indexPath.row]!) + " mile"
            } else {
                cell.optionsLabel.text = String(format: "%g", distances[indexPath.row]!) + " miles"
            }
            
            setDistanceIcon(indexPath.row, iconView: cell.arrowImageView)
            setDistanceCellVisible(indexPath.row, cell: cell)

            return cell
            
        case 2:
            
            let cell = tableView.dequeueReusableCellWithIdentifier("CollapseViewCell", forIndexPath: indexPath) as! CollapseViewCell
            cell.delegate = self

            switch indexPath.row {
            case 0:
                cell.optionsLabel.text = "Best Match"
                break
            case 1:
                cell.optionsLabel.text = "Distance"
                break
            case 2:
                cell.optionsLabel.text = "Best Rated"
                break
            default:
                break
            }
            
            setSortByIcon(indexPath.row, iconView: cell.arrowImageView)
            setSortByCellVisible(indexPath.row, cell: cell)
            

            return cell
            
        case 3:
            
            if indexPath.row != categories.count {
                let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
                
                cell.categoryLabel.text = categories[indexPath.row]["name"]
                cell.delegate = self
                
                cell.onSwitch.on = switchStates[indexPath.row] ?? false
                
                setCategoryCellVisible(indexPath.row, cell: cell)
                
                return cell

            } else {
                
              //  println("in else")
                let cell = tableView.dequeueReusableCellWithIdentifier("SeeAllCell", forIndexPath: indexPath) as! SeeAllCell
                
                let clickToSeeAll = UITapGestureRecognizer(target: self, action: "clickToSeeAll:")
                cell.addGestureRecognizer(clickToSeeAll)
                
                return cell
                
            }
            
         default:
            let cell = UITableViewCell()
            return cell
        }
        
    }
    
    func switchCell(switchCell: SwitchCell, didValueChange val: Bool) {
        println(" switch cell change \(val)")
        let indexPath = tableView.indexPathForCell(switchCell)!
        
        // first row is for deals
        if indexPath.section == 0 {
            self.filters["deals"] = val
        } else {
            switchStates[indexPath.row] = val
        }
        
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier(HeaderViewIdentifier) as! UITableViewHeaderFooterView
        
        switch section {
        case 0:
            header.textLabel.text = "Deals"
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
        
        case 1:
            if isDistanceCollapsed {
                let radiusValue = filters["radius"] as! Float?
                if radiusValue != distances[indexPath.row] {
                        return 0
                }
            }
            break
        case 2:
            if isSortByCollapsed {
                let sortValue = getSortByValue()
                if sortValue != indexPath.row {
                    return 0
                }
            }
            break
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
        
       // println("in setCategoryCellVisible")
        if isCategoryCollapsed && row > 2 && row != categories.count {
           // println("in setCategoryCellVisible \(row)")
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
    
    func setDistanceIcon(row: Int, iconView: UIImageView) {
        
        let radiusValue = filters["radius"] as! Float?
        
        if radiusValue == distances[row] {
            if isDistanceCollapsed {
                iconView.image = UIImage(named: "Arrow")
            } else {
                iconView.image = UIImage(named: "Tick")
            }
            return
        }
        
        iconView.image = UIImage(named: "Circle")
    }
    
    func setDistanceCellVisible(row: Int, cell: CollapseViewCell) {
        
        let radiusValue = filters["radius"] as! Float?
        if isDistanceCollapsed && distances[row] != radiusValue {
            cell.optionsLabel.hidden = true
            cell.arrowImageView.hidden = true
            return
        }
        
        cell.optionsLabel.hidden = false
        cell.arrowImageView.hidden = false
    }

    func setSortByIcon(row: Int, iconView: UIImageView) {
        
        let sortValue = getSortByValue()
        
        if sortValue == row {
            if isSortByCollapsed {
                iconView.image = UIImage(named: "Arrow")
            } else {
                iconView.image = UIImage(named: "Tick")
            }
            return
        }
        
        iconView.image = UIImage(named: "Circle")
    }
    
    func setSortByCellVisible(row: Int, cell: CollapseViewCell) {
        
        let sortValue = getSortByValue()
        
        if isSortByCollapsed && row != sortValue {
            cell.optionsLabel.hidden = true
            cell.arrowImageView.hidden = true
            return
        }
        
        cell.optionsLabel.hidden = false
        cell.arrowImageView.hidden = false
    }
    
    func getSortByValue() -> Int {
        
        let sortValue = filters["sort"] as? Int
        
        if sortValue != nil {
            return sortValue!
        } else {
            return 0
        }
    }


    func selectCell(collaspeViewCell: CollapseViewCell, didSelect arrowImage: UIImage) {
        
        let indexPath = tableView.indexPathForCell(collaspeViewCell)
        
        println(indexPath)
        println("collapseViewCell ")
        
        if indexPath != nil {
            if indexPath!.section == 1 {
            
                switch arrowImage {
                case UIImage(named: "Arrow")!:
                    isDistanceCollapsed = false
                    break
                case UIImage(named: "Tick")!:
                    isDistanceCollapsed = true
                    break
                case UIImage(named: "Circle")!:
                    filters["radius"] = distances[indexPath!.row]
                    isDistanceCollapsed = true
                    break
                default:
                    break
                }
            } else if indexPath!.section == 2 {
            
                switch arrowImage {
                case UIImage(named: "Arrow")!:
                    isSortByCollapsed = false
                    break
                case UIImage(named: "Tick")!:
                    isSortByCollapsed = true
                    break
                case UIImage(named: "Circle")!:
                    filters["sort"] =  NSNumber(unsignedInteger: indexPath!.row)
                    isSortByCollapsed = true
                    break
                default:
                    break
                }
            }
        tableView.reloadData()
      }

   }     /*
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
    
    func yelpDistance() -> [Float?] {
        return [0.5,1,10,20]
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
