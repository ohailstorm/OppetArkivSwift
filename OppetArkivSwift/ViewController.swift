//
//  ViewController.swift
//  OppetArkivSwift
//
//  Created by Oscar Hallström on 2016-09-17.
//  Copyright © 2016 Oscar Hallström. All rights reserved.
//

import UIKit
import Alamofire
import HTMLReader


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let parser = SVTParser()
    let reuseIdentifier = "PersonCell"
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        buildAllProgramsList("http://www.oppetarkiv.se/program")
//        let array = parser.programsList
        tableView.dataSource = self
        tableView.delegate = self
        
//        self.tableView.registerNib(UINib(nibName: "ProgramListCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)

//        self.tableView.reloadData()
        
    }
    

    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var programsList : [HTMLElement] = []
    
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
    func buildOneProgramsList(url: String){
        
        
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
                let tables = doc.nodesMatchingSelector(".svtJsLoadHref")
                
                var chartsTable:HTMLElement?
                for table in tables {
                    //                    if let tableElement = table as? HTMLElement {
                    //                        if self.isChartsTable(tableElement) {
                    //                            chartsTable = tableElement
                    //                            break
                    //                        }
                    print(table.textContent)
                }
                self.updateProgramsList(tables)
                
        }
        
    }

    func updateProgramsList(newList : [HTMLElement]) {
        self.programsList = newList
        for element in newList {
//            print(element)
        }
        self.tableView.reloadData()
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return programsList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell =  UITableViewCell()
        //        cell.textLabel = parser.programsList[indexPath.row].textContent
//        cell.programName.text = programsList[indexPath.row].textContent
        cell.textLabel?.text = programsList[indexPath.row].textContent
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let baseUrl = "http://www.oppetarkiv.se"
        if let link = programsList[indexPath.row].attributes["href"] {
            let url = baseUrl + link
            print(programsList[indexPath.row].attributes)
            buildOneProgramsList(baseUrl + link)
        }
       
    }

}

