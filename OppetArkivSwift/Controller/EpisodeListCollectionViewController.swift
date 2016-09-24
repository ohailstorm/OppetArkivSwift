//
//  EpisodeListCollectionViewController.swift
//  OppetArkivSwift
//
//  Created by Oscar Hallström on 2016-09-22.
//  Copyright © 2016 Oscar Hallström. All rights reserved.
//

import UIKit
import Alamofire
import HTMLReader

private let reuseIdentifier = "EpisodeCell"

class EpisodeListCollectionViewController: UICollectionViewController {
    var requestUrl : String = ""
    var baseUrl : String  = "http://www.oppetarkiv.se"
    var episodeList : [HTMLElement] = [] {
        didSet {
            self.collectionView?.reloadData()
        }
    }
    var imageList : [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
   

        // Do any additional setup after loading the view.
        self.collectionView?.dataSource = self
        
        self.buildOneProgramsList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        print("preparing")
        if let cell = sender as? UICollectionViewCell {
            if let index = self.collectionView?.indexPathForCell(cell) {
                //                print(episodeList[index.row].attributes)
                if let href = episodeList[index.row].attributes["href"] {
                    let videoId = href.componentsSeparatedByString("/")[2]
                    //                    print(videoId)
                    if let newController = segue.destinationViewController as? EpisodeDetailsViewController {
                        newController.videoId = videoId
                        newController.detailsUrl = baseUrl + href
                        print(newController.detailsUrl)
                    }
                }
            }
            
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return episodeList.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! EpisodeCollectionViewCell
        print(episodeList[indexPath.row].textContent)
        cell.textLabel.text = episodeList[indexPath.row].textContent
        // Configure the cell
        
//        cell.textLabel?.text = episodeList[indexPath.row].textContent
        //print(episodeList[indexPath.row].attributes)
        
        let url = NSURL(string: "http:" + self.imageList[indexPath.row])
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
            dispatch_async(dispatch_get_main_queue(), { [unowned self] in
                cell.imageView?.image = UIImage(data: data!)
                cell.imageView.layer.cornerRadius = 10
                
//                cell.imageView?.layer.masksToBounds = true

                cell.imageView?.clipsToBounds = true
                cell.imageView.sizeToFit()
                cell.layoutSubviews()
//                print(cell.canBecomeFocused())
                });
        }
    
        return cell
    }
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
    func updateProgramsList(newList : [HTMLElement]) {
        self.episodeList.appendContentsOf(newList)
        for element in newList {
            //            print(element)
        }
        self.collectionView?.reloadData()
        
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
