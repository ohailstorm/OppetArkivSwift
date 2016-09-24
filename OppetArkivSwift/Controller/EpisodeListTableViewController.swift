//
//  EpisodeListTableViewController.swift
//  OppetArkivSwift
//
//  Created by Oscar Hallström on 2016-09-19.
//  Copyright © 2016 Oscar Hallström. All rights reserved.
//

import UIKit
import Alamofire
import HTMLReader

class EpisodeListTableViewController: UITableViewController {
    
    var requestUrl = ""
    let baseUrl = "http://www.oppetarkiv.se"
    var episodeList : [HTMLElement] = []
    var imageList : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        buildOneProgramsList()
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
        return episodeList.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EpisodeListCell", forIndexPath: indexPath)

        // Configure the cell...
        cell.textLabel?.text = episodeList[indexPath.row].textContent
        //print(episodeList[indexPath.row].attributes)
        
        let url = NSURL(string: "http:" + self.imageList[indexPath.row])
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
            dispatch_async(dispatch_get_main_queue(), { [unowned self] in
                cell.imageView?.image = UIImage(data: data!)
                cell.layoutSubviews()
            });
        }


        return cell
    }
 
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 200
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
        print("preparing")
        if let cell = sender as? UITableViewCell {
            if let index = self.tableView.indexPathForCell(cell) {
//                print(episodeList[index.row].attributes)
                if let href = episodeList[index.row].attributes["href"] {
                    let videoId = href.componentsSeparatedByString("/")[2]
//                    print(videoId)
                    if let newController = segue.destinationViewController as? EpisodeDetailsViewController {
                        newController.videoId = videoId
                        newController.detailsUrl = baseUrl + href
//                        print(newController.detailsUrl)
                    }
                }
            }
            
        }
    }
 
    
    func updateProgramsList(newList : [HTMLElement]) {
        self.episodeList.appendContentsOf(newList)
        for element in newList {
            //            print(element)
        }
        self.tableView.reloadData()
        
    }
    
    func buildOneProgramsList(){

        
        //       "http://www.oppetarkiv.se/program"
        
        Alamofire.request(.GET, requestUrl)
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
                let tables = doc.nodesMatchingSelector(".svtJsLoadHref")
                
                var chartsTable:HTMLElement?
                for table in tables {
                    //                    if let tableElement = table as? HTMLElement {
                    //                        if self.isChartsTable(tableElement) {
                    //                            chartsTable = tableElement
                    //                            break
                    //                        }
//                    print(table.textContent)
                }
                
                let images = doc.nodesMatchingSelector(".svtHide-No-Js")
                
                for image in images {
                    if let src = image.attributes["srcset"]?.componentsSeparatedByString(" ").first {
//                        print(src)
                        self.imageList.append(src)
                    }
                }
                self.updateProgramsList(tables)
                
                //check if there is more content to load
                if let moreTitlesAvailable = doc.nodesMatchingSelector(".svtoa-js-search-step-button").filter({ $0.attributes["data-page-dir"] != "-1"}).first {
                    print(moreTitlesAvailable.attributes)
                    if let suffix = moreTitlesAvailable.attributes["href"]{
                        self.requestUrl =  self.baseUrl + suffix
                        self.buildOneProgramsList()
                    }
                    
                }
                
                
        }
        
    }

}
