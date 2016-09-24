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
import AVKit
import SwiftyJSON


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
        
        Alamofire.request(detailsUrl)
            .responseString { responseString in
                guard responseString.result.error == nil else {
                    // completionHandler(responseString.result.error!)
                    return
                    
                }
                guard let htmlAsString = responseString.result.value else {
                   
                    // completionHandler(error)
                    
                    return
                }
//                print(responseString)
//                                print(htmlAsString)
                let doc = HTMLDocument(string: htmlAsString)
                
                //                // find the table of charts in the HTML
                let tables = doc.nodes(matchingSelector: ".svtoa-anchor-list-link")
                
                var chartsTable:HTMLElement?
                for table in tables {
                    //                    if let tableElement = table as? HTMLElement {
                    //                        if self.isChartsTable(tableElement) {
                    //                            chartsTable = tableElement
                    //                            break
                    //                        }
                    //print(table.textContent)
                }
                let video = doc.nodes(matchingSelector: "[data-video-id]")
                if let id = video.first?.attributes["data-video-id"] {
                    self.videoId = id
                    self.getVideoStream()
                }
                
        }
        
    }
    
    func getVideoStream(){
        var requestUrl = "http://www.svt.se/videoplayer-api/video/" + videoId
        
        //       "http://www.oppetarkiv.se/program"
        
        
        Alamofire.request(requestUrl)
            .responseString { responseString in
                guard responseString.result.error == nil else {
                    // completionHandler(responseString.result.error!)
                    return
                    
                }
                guard let htmlAsString = responseString.result.value else {
                 
                    // completionHandler(error)
                    
                    return
                }
//                print(responseString)
                if let dataFromString = htmlAsString.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                    let json = JSON(data: dataFromString)
//                    print(json["videoReferences"])
                    for item in json["videoReferences"].arrayValue {
                        if item["format"].stringValue == "hls" {
                            print(item["url"].stringValue)
                            self.playVideo(item["url"].stringValue)
                            break
                        }
                       
                    }
                }
        }
        
    }
    
    func playVideo(_ url: String) {
        let videoURL: URL = URL(string: url)!
        
         let playerViewController = AVPlayerViewController()
        
//        playerViewController.player = AVPlayer.init(URL: videoURL)
        playerViewController.player = AVPlayer(url: videoURL)
        
        //        moviePlayerController.movieSourceType = MPMovieSourceType.File
        
        playerViewController.isModalInPopover = true
        
        
        self.addChildViewController(playerViewController)
        playerViewController.view.frame = self.view.frame
        self.view.addSubview(playerViewController.view)
        
        playerViewController.player?.play()
//        playerViewController.loadView()
        playerViewController.showsPlaybackControls = true
        playerViewController.didMove(toParentViewController: self)
        
       
        
        
    }

}
