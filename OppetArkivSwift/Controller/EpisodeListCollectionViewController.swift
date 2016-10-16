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
    var episodeList : [Episode] = [] {
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        print("preparing")
        if let cell = sender as? UICollectionViewCell {
            if let index = self.collectionView?.indexPath(for: cell) {
                    let episode = episodeList[(index as NSIndexPath).row]
                    if let newController = segue.destination as? EpisodeDetailsViewController {
                        newController.videoId = episode.videoId
                        newController.detailsUrl = episode.detailsUrl
                        print(newController.detailsUrl)
                    }

            }
            
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return episodeList.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! EpisodeCollectionViewCell
       
        cell.textLabel.text = episodeList[(indexPath as NSIndexPath).row].title
        // Configure the cell
        
//        cell.textLabel?.text = episodeList[indexPath.row].textContent
        print(self.episodeList[(indexPath as NSIndexPath).row].imageUrl)
        
        let url = URL(string: self.episodeList[(indexPath as NSIndexPath).row].imageUrl)
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
            DispatchQueue.main.async(execute: { [unowned self] in
                cell.imageView?.image = UIImage(data: data!)
                cell.imageView.layer.cornerRadius = 10
                
                cell.imageView?.clipsToBounds = true
                cell.imageView.sizeToFit()
                cell.layoutSubviews()

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
    
    func updateProgramsList(_ newList : [Episode]) {
        self.episodeList.append(contentsOf: newList)
        self.collectionView?.reloadData()
        
    }
    
    func buildOneProgramsList(){
        print("building")
        
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
                
            
                let doc = HTMLDocument(string: htmlAsString)
                
                // find the table of episodes in the HTML
                let episodeHTMLTable = doc.nodes(matchingSelector: ".svtJsLoadHref")
                let imagesHTMLTable = doc.nodes(matchingSelector: ".svtHide-No-Js")
                
                var episodesList: [Episode] = []
                var imagesList: [String] = []
                
                
                for image in imagesHTMLTable {
                    if let src = image.attributes["srcset"]?.components(separatedBy: " ").first {
                        imagesList.append(src)
                    }
                }
                
                for (index, oneEpisode) in episodeHTMLTable.enumerated() {
                    if let detailsUrl = oneEpisode.attributes["href"], let imageUrl = imagesList[index].components(separatedBy: " ").first {
                        let videoId = detailsUrl.components(separatedBy: "/")[2]
                        let episode = Episode(title: oneEpisode.textContent, detailsUrl: detailsUrl, imageUrl: "http:" + imageUrl, videoId: videoId)
                        
                        episodesList.append(episode)
                      
                    }
                }
                
                
                self.updateProgramsList(episodesList)
                
                //check if there is more content to load
                if let moreTitlesAvailable = doc.nodes(matchingSelector: ".svtoa-js-search-step-button").filter({ $0.attributes["data-page-dir"] != "-1"}).first {
                    print(moreTitlesAvailable.attributes)
                    if let suffix = moreTitlesAvailable.attributes["href"]{
                        self.requestUrl =  self.baseUrl + suffix
                        self.buildOneProgramsList()
                    }
                    
                }
                
                
        }
        
    }

}
