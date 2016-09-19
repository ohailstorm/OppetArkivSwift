//
//  EpisodeDetailsViewController.swift
//  OppetArkivSwift
//
//  Created by Oscar Hallström on 2016-09-19.
//  Copyright © 2016 Oscar Hallström. All rights reserved.
//

import UIKit
import Alamofire
import HTMLReader

class EpisodeDetailsViewController: UIViewController {
    var detailsUrl = ""
    var videoId = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getVideoDetails()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func getVideoDetails(){
        
        //       "http://www.oppetarkiv.se/program"
        
        Alamofire.request(.GET, detailsUrl)
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
//                print(responseString)
//                                print(htmlAsString)
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
                let video = doc.nodesMatchingSelector("[data-video-id]")
                if let id = video.first?.attributes["data-video-id"] {
                    self.videoId = id
                    self.getVideoStream()
                }
                
        }
        
    }
    
    func getVideoStream(){
        var requestUrl = "http://www.svt.se/videoplayer-api/video/" + videoId
        
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
                print(responseString)
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
               
                
        }
        
    }

}
