//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Siji Rachel Tom on 9/23/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    @objc optional func filtersViewController(filtersViewController: FiltersViewController, didSearchForFilters  filters:[String : AnyObject])
}

class FiltersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwitchCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var categories: [[String : String]]!
    var selectionArray = [Int : [Int : Bool]]()
    weak var delegate : FiltersViewControllerDelegate?
    
    enum TableSection : Int {
        case deals = 0
        case distance
        case sortBy
        case category
        case totalCount
    }        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        navigationController?.navigationBar.barStyle = UIBarStyle.blackOpaque
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = UIColor(red: 215/255.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        categories = yelpCategories()
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = UIColor.white
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func selectedCategories(categoryList : [Int : Bool]) -> [String]? {
        var selectedCategories = [String]()
        
        for (row, switchSelectedState) in categoryList {
            if switchSelectedState {
                selectedCategories.append(categories[row]["code"]!)
            }
        }
        
        if selectedCategories.count > 0 {
            return selectedCategories
        } else {
            return nil
        }
    }
    
    func isDealSelected(selectionList : [Int : Bool]) -> Bool? {
        for (_, isSelected) in selectionList {
            if isSelected {
                return isSelected
            }
        }
        
        return nil
    }
    
    func sortByModeSelected(selectionList : [Int : Bool]) -> YelpSortMode? {
        for (row, isSelected) in selectionList {
            if isSelected {
                let selectedSortMode = YelpSortMode(rawValue: row)
                return selectedSortMode
            }
        }
        
        return nil
    }
    
    func selectedDistance(selectionList : [Int : Bool]) -> YelpDistanceMode? {
        for (row, isSelected) in selectionList {
            if isSelected {
                let selectedDistanceMode = YelpDistanceMode(rawValue: row)
                return selectedDistanceMode
            }
        }
        
        return nil
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        var selectedFilter = [String : AnyObject]()
        
        for (section, filters) in selectionArray {
            
            // Get value of row for each section type
            if let tableSection = TableSection(rawValue : section) {
                switch tableSection {
                case .category:
                    if let categoryList = selectedCategories(categoryList: filters) {
                        selectedFilter["categories"] = categoryList as AnyObject
                    }
                case .deals:
                    if let isDealFilterOn = isDealSelected(selectionList: filters) {
                        selectedFilter["deals"] = isDealFilterOn as AnyObject
                    }
                case .sortBy:
                    if let selectedSortMode = sortByModeSelected(selectionList: filters) {
                        selectedFilter["sortMode"] = selectedSortMode as AnyObject
                    }
                case .distance:
                    if let selectedDistanceMode = selectedDistance(selectionList: filters) {
                        selectedFilter["radius"] = selectedDistanceMode as AnyObject
                    }
                case .totalCount:
                    break
                }
            }
        }
        
        self.delegate?.filtersViewController?(filtersViewController: self, didSearchForFilters: selectedFilter)
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK : - Tableview methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numRows : Int!
        if let tableSection = TableSection(rawValue: section) {
            switch tableSection {
            case .deals:
                numRows = 1
            case .category:
                numRows = self.categories.count
            case .distance:
                numRows = YelpDistanceMode.totalCount.rawValue
            case .sortBy:
                numRows = YelpSortMode.totalCount.rawValue
            case .totalCount:
                numRows = 0
            }
        }
        
        return numRows
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return TableSection.totalCount.rawValue
    }
    
    func switchText(indexPath : IndexPath) -> String {
        
        var text : String!
        if let section = TableSection(rawValue: indexPath.section) {
            switch section {
            case .deals:
                text = "Offering a Deal"
            case .category:
                text = categories[indexPath.row]["name"]!
            case .sortBy:
                text = sortModeText(sortMode: YelpSortMode(rawValue: indexPath.row)!)
            case .distance:
                text = distanceModeText(distanceMode: YelpDistanceMode(rawValue: indexPath.row)!)
            case .totalCount:
                text = ""
            }
        }
        
        return text
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
        cell.switchLabel.text = switchText(indexPath: indexPath)
        cell.delegate = self
        cell.onSwitch.setOn(selectionArray[indexPath.section]?[indexPath.row] ?? false, animated: false)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var title : String?
        
        if let tableSection = TableSection(rawValue: section) {
            switch tableSection {
            case .deals:
                title = ""
            case .category:
                title = "Category"
            case .distance:
                title = "Distance"
            case .sortBy:
                title = "Sort By"
            case .totalCount:
                title = ""
            }
        }
        
        return title
    }
    
    // MARK : - SwitchCellDelegate methods
    
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexpath = tableView.indexPath(for: switchCell)!
        var selectionArraySection = selectionArray[indexpath.section] ?? [:]
        selectionArraySection[indexpath.row] = value
        selectionArray[indexpath.section] = selectionArraySection
    }
    
    // MARK : - Predefined categories, convenience method
    
    func yelpCategories() -> [[String : String]] {
        return [["name" : "Afghan", "code": "afghani"],
                ["name" : "African", "code": "african"],
                ["name" : "American, New", "code": "newamerican"],
                ["name" : "American, Traditional", "code": "tradamerican"],
                ["name" : "Arabian", "code": "arabian"],
                ["name" : "Argentine", "code": "argentine"],
                ["name" : "Armenian", "code": "armenian"],
                ["name" : "Asian Fusion", "code": "asianfusion"],
                ["name" : "Asturian", "code": "asturian"],
                ["name" : "Australian", "code": "australian"],
                ["name" : "Austrian", "code": "austrian"],
                ["name" : "Baguettes", "code": "baguettes"],
                ["name" : "Bangladeshi", "code": "bangladeshi"],
                ["name" : "Barbeque", "code": "bbq"],
                ["name" : "Basque", "code": "basque"],
                ["name" : "Bavarian", "code": "bavarian"],
                ["name" : "Beer Garden", "code": "beergarden"],
                ["name" : "Beer Hall", "code": "beerhall"],
                ["name" : "Beisl", "code": "beisl"],
                ["name" : "Belgian", "code": "belgian"],
                ["name" : "Bistros", "code": "bistros"],
                ["name" : "Black Sea", "code": "blacksea"],
                ["name" : "Brasseries", "code": "brasseries"],
                ["name" : "Brazilian", "code": "brazilian"],
                ["name" : "Breakfast & Brunch", "code": "breakfast_brunch"],
                ["name" : "British", "code": "british"],
                ["name" : "Buffets", "code": "buffets"],
                ["name" : "Bulgarian", "code": "bulgarian"],
                ["name" : "Burgers", "code": "burgers"],
                ["name" : "Burmese", "code": "burmese"],
                ["name" : "Cafes", "code": "cafes"],
                ["name" : "Cafeteria", "code": "cafeteria"],
                ["name" : "Cajun/Creole", "code": "cajun"],
                ["name" : "Cambodian", "code": "cambodian"],
                ["name" : "Canadian", "code": "New)"],
                ["name" : "Canteen", "code": "canteen"],
                ["name" : "Caribbean", "code": "caribbean"],
                ["name" : "Catalan", "code": "catalan"],
                ["name" : "Chech", "code": "chech"],
                ["name" : "Cheesesteaks", "code": "cheesesteaks"],
                ["name" : "Chicken Shop", "code": "chickenshop"],
                ["name" : "Chicken Wings", "code": "chicken_wings"],
                ["name" : "Chilean", "code": "chilean"],
                ["name" : "Chinese", "code": "chinese"],
                ["name" : "Comfort Food", "code": "comfortfood"],
                ["name" : "Corsican", "code": "corsican"],
                ["name" : "Creperies", "code": "creperies"],
                ["name" : "Cuban", "code": "cuban"],
                ["name" : "Curry Sausage", "code": "currysausage"],
                ["name" : "Cypriot", "code": "cypriot"],
                ["name" : "Czech", "code": "czech"],
                ["name" : "Czech/Slovakian", "code": "czechslovakian"],
                ["name" : "Danish", "code": "danish"],
                ["name" : "Delis", "code": "delis"],
                ["name" : "Diners", "code": "diners"],
                ["name" : "Dumplings", "code": "dumplings"],
                ["name" : "Eastern European", "code": "eastern_european"],
                ["name" : "Ethiopian", "code": "ethiopian"],
                ["name" : "Fast Food", "code": "hotdogs"],
                ["name" : "Filipino", "code": "filipino"],
                ["name" : "Fish & Chips", "code": "fishnchips"],
                ["name" : "Fondue", "code": "fondue"],
                ["name" : "Food Court", "code": "food_court"],
                ["name" : "Food Stands", "code": "foodstands"],
                ["name" : "French", "code": "french"],
                ["name" : "French Southwest", "code": "sud_ouest"],
                ["name" : "Galician", "code": "galician"],
                ["name" : "Gastropubs", "code": "gastropubs"],
                ["name" : "Georgian", "code": "georgian"],
                ["name" : "German", "code": "german"],
                ["name" : "Giblets", "code": "giblets"],
                ["name" : "Gluten-Free", "code": "gluten_free"],
                ["name" : "Greek", "code": "greek"],
                ["name" : "Halal", "code": "halal"],
                ["name" : "Hawaiian", "code": "hawaiian"],
                ["name" : "Heuriger", "code": "heuriger"],
                ["name" : "Himalayan/Nepalese", "code": "himalayan"],
                ["name" : "Hong Kong Style Cafe", "code": "hkcafe"],
                ["name" : "Hot Dogs", "code": "hotdog"],
                ["name" : "Hot Pot", "code": "hotpot"],
                ["name" : "Hungarian", "code": "hungarian"],
                ["name" : "Iberian", "code": "iberian"],
                ["name" : "Indian", "code": "indpak"],
                ["name" : "Indonesian", "code": "indonesian"],
                ["name" : "International", "code": "international"],
                ["name" : "Irish", "code": "irish"],
                ["name" : "Island Pub", "code": "island_pub"],
                ["name" : "Israeli", "code": "israeli"],
                ["name" : "Italian", "code": "italian"],
                ["name" : "Japanese", "code": "japanese"],
                ["name" : "Jewish", "code": "jewish"],
                ["name" : "Kebab", "code": "kebab"],
                ["name" : "Korean", "code": "korean"],
                ["name" : "Kosher", "code": "kosher"],
                ["name" : "Kurdish", "code": "kurdish"],
                ["name" : "Laos", "code": "laos"],
                ["name" : "Laotian", "code": "laotian"],
                ["name" : "Latin American", "code": "latin"],
                ["name" : "Live/Raw Food", "code": "raw_food"],
                ["name" : "Lyonnais", "code": "lyonnais"],
                ["name" : "Malaysian", "code": "malaysian"],
                ["name" : "Meatballs", "code": "meatballs"],
                ["name" : "Mediterranean", "code": "mediterranean"],
                ["name" : "Mexican", "code": "mexican"],
                ["name" : "Middle Eastern", "code": "mideastern"],
                ["name" : "Milk Bars", "code": "milkbars"],
                ["name" : "Modern Australian", "code": "modern_australian"],
                ["name" : "Modern European", "code": "modern_european"],
                ["name" : "Mongolian", "code": "mongolian"],
                ["name" : "Moroccan", "code": "moroccan"],
                ["name" : "New Zealand", "code": "newzealand"],
                ["name" : "Night Food", "code": "nightfood"],
                ["name" : "Norcinerie", "code": "norcinerie"],
                ["name" : "Open Sandwiches", "code": "opensandwiches"],
                ["name" : "Oriental", "code": "oriental"],
                ["name" : "Pakistani", "code": "pakistani"],
                ["name" : "Parent Cafes", "code": "eltern_cafes"],
                ["name" : "Parma", "code": "parma"],
                ["name" : "Persian/Iranian", "code": "persian"],
                ["name" : "Peruvian", "code": "peruvian"],
                ["name" : "Pita", "code": "pita"],
                ["name" : "Pizza", "code": "pizza"],
                ["name" : "Polish", "code": "polish"],
                ["name" : "Portuguese", "code": "portuguese"],
                ["name" : "Potatoes", "code": "potatoes"],
                ["name" : "Poutineries", "code": "poutineries"],
                ["name" : "Pub Food", "code": "pubfood"],
                ["name" : "Rice", "code": "riceshop"],
                ["name" : "Romanian", "code": "romanian"],
                ["name" : "Rotisserie Chicken", "code": "rotisserie_chicken"],
                ["name" : "Rumanian", "code": "rumanian"],
                ["name" : "Russian", "code": "russian"],
                ["name" : "Salad", "code": "salad"],
                ["name" : "Sandwiches", "code": "sandwiches"],
                ["name" : "Scandinavian", "code": "scandinavian"],
                ["name" : "Scottish", "code": "scottish"],
                ["name" : "Seafood", "code": "seafood"],
                ["name" : "Serbo Croatian", "code": "serbocroatian"],
                ["name" : "Signature Cuisine", "code": "signature_cuisine"],
                ["name" : "Singaporean", "code": "singaporean"],
                ["name" : "Slovakian", "code": "slovakian"],
                ["name" : "Soul Food", "code": "soulfood"],
                ["name" : "Soup", "code": "soup"],
                ["name" : "Southern", "code": "southern"],
                ["name" : "Spanish", "code": "spanish"],
                ["name" : "Steakhouses", "code": "steak"],
                ["name" : "Sushi Bars", "code": "sushi"],
                ["name" : "Swabian", "code": "swabian"],
                ["name" : "Swedish", "code": "swedish"],
                ["name" : "Swiss Food", "code": "swissfood"],
                ["name" : "Tabernas", "code": "tabernas"],
                ["name" : "Taiwanese", "code": "taiwanese"],
                ["name" : "Tapas Bars", "code": "tapas"],
                ["name" : "Tapas/Small Plates", "code": "tapasmallplates"],
                ["name" : "Tex-Mex", "code": "tex-mex"],
                ["name" : "Thai", "code": "thai"],
                ["name" : "Traditional Norwegian", "code": "norwegian"],
                ["name" : "Traditional Swedish", "code": "traditional_swedish"],
                ["name" : "Trattorie", "code": "trattorie"],
                ["name" : "Turkish", "code": "turkish"],
                ["name" : "Ukrainian", "code": "ukrainian"],
                ["name" : "Uzbek", "code": "uzbek"],
                ["name" : "Vegan", "code": "vegan"],
                ["name" : "Vegetarian", "code": "vegetarian"],
                ["name" : "Venison", "code": "venison"],
                ["name" : "Vietnamese", "code": "vietnamese"],
                ["name" : "Wok", "code": "wok"],
                ["name" : "Wraps", "code": "wraps"],
                ["name" : "Yugoslav", "code": "yugoslav"]]
    }
}
