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

class ProgramListTableViewController: UITableViewController {
    var programsList : [HTMLElement] = []
    var sectionedProgramsList : Dictionary<String, Array<String>> = [:]
    let baseUrl = "http://www.oppetarkiv.se"
    
    
    
    var sections : [(index: Int, length :Int, title: String)] = Array()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        buildAllProgramsList("http://www.oppetarkiv.se/program")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return programsList.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProgramListCell", forIndexPath: indexPath)

        // Configure the cell...
        cell.textLabel?.text = programsList[indexPath.row].textContent
        
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
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let cell = sender as? UITableViewCell {
            if let index = self.tableView.indexPathForCell(cell) {
                if let href = programsList[index.row].attributes["href"] {
                    if let newController = segue.destinationViewController as? EpisodeListTableViewController {
                        newController.requestUrl = baseUrl + href
                        print(newController.requestUrl)
                    }
                }
            }
            
        }
    }
 

    func updateProgramsList(newList : [HTMLElement]) {
        self.programsList = newList
        var nameArray : [String] = []
        for element in newList {
            //            print(element)
            nameArray.append(element.textContent)
        }
        self.tableView.reloadData()
        
        var index = 0;
        var array = nameArray
        for ( var i = 0; i < array.count; i++ ) {
            
            let commonPrefix = array[i].commonPrefixWithString(array[index], options: .CaseInsensitiveSearch)
            
            if (commonPrefix.characters.count == 0 ) {
                
                let string = array[index].uppercaseString;
                
                let firstCharacter = string[string.startIndex]
                
                let title = "\(firstCharacter)"
                
                let newSection = (index: index, length: i - index, title: title)
                
                sections.append(newSection)
                
                index = i;
                
            }
            
        }
        
        print(sections)

    }
    
    func buildAllProgramsList(url: String){
        
        
        //       "http://www.oppetarkiv.se/program"
        
        Alamofire.request(.GET, url)
            .responseString { responseString in
                guard responseString.result.error == nil else {
                    // completionHandler(responseString.result.error!)
                    return
                    
                }
                guard let htmlAsString = responseString.result.value else {
                    let error = Error.errorWithCode(.StringSerializationFailed, failureReason: "Could not get HTML as String")
                    // completionHandler(error)
                    
                    return
                }
                //                print(htmlAsString)
                let doc = HTMLDocument(string: htmlAsString)
                
                //                // find the table of charts in the HTML
                let tables = doc.nodesMatchingSelector(".svtoa-anchor-list-link")
                
                var chartsTable:HTMLElement?
                for table in tables {
                    //                    if let tableElement = table as? HTMLElement {
                    //                        if self.isChartsTable(tableElement) {
                    //                            chartsTable = tableElement
                    //                            break
                    //                        }
                    //print(table.textContent)
                }
                self.updateProgramsList(tables)
                
        }
        
    }
}
