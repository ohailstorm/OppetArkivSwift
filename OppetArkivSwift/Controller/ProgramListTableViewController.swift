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
    
    let requestUrl = "https://www.oppetarkiv.se/program"
    var filteredProgramsList : [Program] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var searchText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildAllProgramsList(requestUrl)
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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let cell = sender as? UITableViewCell {
            if let index = self.tableView.indexPath(for: cell) {
                let url = filteredProgramsList[(index as NSIndexPath).row].detailsUrl
                
                if let newController = segue.destination as? EpisodeListTableViewController {
                    newController.requestUrl = url
                    print(newController.requestUrl)
                }

                // If CollectionViewCell used
                if let newController = segue.destination as? EpisodeListCollectionViewController {
                    newController.requestUrl = url
                    print(newController.requestUrl)
                }

            }
            
        }
    }
    
    func updateProgramsList(_ newList : [Program]) {
        self.programsList = newList
        self.filteredProgramsList = newList
    }
    
    func buildAllProgramsList(_ url: String){
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
                
                let doc = HTMLDocument(string: htmlAsString)
                let programHTMLTable = doc.nodes(matchingSelector: ".svtoa-anchor-list-link")
                var programList : [Program] = []
                
                for programHtml in programHTMLTable {
                    if let url = programHtml.attributes["href"] {
                        programList.append(Program(title: programHtml.textContent, detailsUrl: url))
                    }
                }
                
                self.updateProgramsList(programList)
        }
        
    }
    
    func letterSelected(_ filterLetter: Character?) {
        guard filterLetter != nil else {
            filteredProgramsList = programsList
            return
        }
        print(filterLetter ?? "")
        guard filterLetter != "#".first else {
            
            filteredProgramsList = programsList.filter({
                if let substr = $0.title.first {
                    return Int(String(substr)) != nil
                }
                return false
            })
                
            return
        }
        
        
        filteredProgramsList = programsList.filter({
            if let programLetter = $0.title.lowercased().first {
                return programLetter == filterLetter
            }
            return false
        })

    }
}
