//
//  ProgramListTableViewController.swift
//  OppetArkivSwift
//
//  Created by Oscar Hallström on 2016-09-19.
//  Copyright © 2016 Oscar Hallström. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import HTMLReader



class ProgramListTableViewController: UITableViewController, LetterSelectionDelegate {
    var programsList : [Program] = []
    
    let baseUrl = "http://www.oppetarkiv.se"
    var filteredProgramsList : [Program] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    var searchText = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
//        self.tableView.tableHeaderView = searchController.searchBar
        
        buildAllProgramsList("http://www.oppetarkiv.se/program")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredProgramsList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProgramListCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = filteredProgramsList[(indexPath as NSIndexPath).row].title
        
        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let cell = sender as? UITableViewCell {
            if let index = self.tableView.indexPath(for: cell) {
                let url = filteredProgramsList[(index as NSIndexPath).row].detailsUrl
                print(url)
//                if let href = filteredProgramsList[(index as NSIndexPath).row].attributes["href"] {
                    if let newController = segue.destination as? EpisodeListTableViewController {
                        newController.requestUrl = url
                        print(newController.requestUrl)
                    }
//                }
                // If CollectionViewCell used
//                if let href = filteredProgramsList[(index as NSIndexPath).row].attributes["href"] {
                    if let newController = segue.destination as? EpisodeListCollectionViewController {
                        newController.requestUrl = url
                        print(newController.requestUrl)
                    }
//                }
            }
            
        }
    }
    
//    func updateSearchResultsForSearchController(searchController: UISearchController) {
//        filteredProgramsList = programsList.filter({
//            if let programLetter = $0.textContent.lowercaseString.characters.first, let searchText = searchController.searchBar.text?.lowercaseString.characters.first where searchController.searchBar.text != ""{
//                print(programLetter)
//                print(searchText)
//                return programLetter == searchText
//            }
//            return false
//        })
////        print(filteredProgramsList)
////        print(searchController.searchBar.text)
////        self.tableView.reloadData()
//    }
// 

    func updateProgramsList(_ newList : [Program]) {
        self.programsList = newList
     
        self.filteredProgramsList = newList
    
//        self.tableView.reloadData()
    }
    
    func buildAllProgramsList(_ url: String){
        
        
        //       "http://www.oppetarkiv.se/program"
        
        Alamofire.request(url)
            .responseString { responseString in
                guard responseString.result.error == nil else {
                    // completionHandler(responseString.result.error!)
                    return
                    
                }
                guard let htmlAsString = responseString.result.value else {
                
                    // completionHandler(error)
                    
                    return
                }
                //                print(htmlAsString)
                let doc = HTMLDocument(string: htmlAsString)
                
                //                // find the table of charts in the HTML
                let tables = doc.nodes(matchingSelector: ".svtoa-anchor-list-link")
                
                var programList : [Program] = []
                
                
                for table in tables {
                    //                    if let tableElement = table as? HTMLElement {
                    //                        if self.isChartsTable(tableElement) {
                    //                            chartsTable = tableElement
                    //                            break
                    //                        }
                    print(table.attributes)
                    if let url = table.attributes["href"] {
                        programList.append(Program(title: table.textContent, detailsUrl: url))
                    }
                    
                }
                
                
                
                self.updateProgramsList(programList)
                
        }
        
    }
    
    func letterSelected(_ filterLetter: Character?) {
        guard filterLetter != nil else {
            filteredProgramsList = programsList
//            self.tableView.reloadData()
            return
        }
        print(filterLetter)
        guard filterLetter != "#".characters.first else {
            
            filteredProgramsList = programsList.filter({
                if let substr = $0.title.characters.first {
                    return Int(String(substr)) != nil
                }
                return false
            })
                
            return
        }
        
        
        filteredProgramsList = programsList.filter({
            if let programLetter = $0.title.lowercased().characters.first {
                return programLetter == filterLetter
            }
            return false
        })
        //        print(filteredProgramsList)
        //        print(searchController.searchBar.text)
        
//        self.tableView.reloadData()
    }
}
