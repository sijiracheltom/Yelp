//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, FiltersViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var businesses: [Business]!
    var searchedBusinesses : [Business]!
    var searchBar: UISearchBar!    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        searchBar = UISearchBar()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        
        navigationController?.navigationBar.barStyle = UIBarStyle.blackOpaque
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = UIColor(red: 215/255.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        Business.searchWithTerm(term: "Restaurants",
                                completion:
            { (businesses: [Business]?, error: Error?) -> Void in
                self.businesses = businesses
                self.searchedBusinesses = businesses
                self.tableView.reloadData()
        })
        
        /* Example of Yelp search with more search options specified
         Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
         self.businesses = businesses
         
         for business in businesses {
         print(business.name!)
         print(business.address!)
         }
         }
         */
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedBusinesses = searchText.isEmpty ? businesses : businesses.filter({ (business : Business) -> Bool in
            let businessName = business.name
            return businessName?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        })
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    override func viewWillLayoutSubviews() {
        searchBar.sizeToFit()
    }
    
    // MARK: - TableView methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchedBusinesses != nil {
            return searchedBusinesses.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        
        cell.business = searchedBusinesses[indexPath.row]
        
        return cell
    }
    
    // MARK: - Search bar delegate
    
    // MARK: - Navigation controller setup
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        searchBar.showsCancelButton = false
        searchBar.text = nil
        searchBar.resignFirstResponder()
        searchedBusinesses = businesses
        tableView.reloadData()
        
        let navigationController = segue.destination as! UINavigationController
        let filtersVC = navigationController.topViewController as! FiltersViewController
        filtersVC.delegate = self
    }
    
    // MARK: - Filters VC delegare
    func filtersViewController(filtersViewController: FiltersViewController, didSearchForFilters filters: [String : AnyObject]) {
        let restaurantCategories = filters["categories"] ?? nil
        let deals = filters["deals"] ?? nil
        let sortMode = filters["sortMode"] ?? nil
        let distanceMode = filters["radius"] ?? nil
        
        Business.searchWithTerm(term: "Restaurants", sort: sortMode as? YelpSortMode, categories: restaurantCategories as? [String], deals: deals as? Bool, radius: distanceMode as? YelpDistanceMode)
        { (businesses: [Business]?, error: Error?) -> Void in
            self.businesses = businesses
            self.searchedBusinesses = businesses
            self.tableView.reloadData()
        }
    }
    
}
