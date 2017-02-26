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
    var baseUrl : String  = "https://www.oppetarkiv.se"
    var episodeList : [Episode] = [] {
        didSet {
            self.collectionView?.reloadData()
        }
    }
    var imageList : [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
       
        if let cell = sender as? UICollectionViewCell {
            if let index = self.collectionView?.indexPath(for: cell) {
                    let episode = episodeList[(index as NSIndexPath).row]
                    if let newController = segue.destination as? EpisodeDetailsViewController {
                        newController.videoId = episode.videoId
                        newController.detailsUrl = episode.detailsUrl
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
        
        // Configure the cell
        cell.textLabel.text = episodeList[(indexPath as NSIndexPath).row].title
        print(episodeList[(indexPath as NSIndexPath).row])
        let url = URL(string: self.episodeList[(indexPath as NSIndexPath).row].imageUrl)
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            if let data = try? Data(contentsOf: url!) { //make sure your image in this url does exist, otherwise unwrap in a if let check
            DispatchQueue.main.async(execute: {
                cell.imageView?.image = UIImage(data: data)
                cell.imageView.layer.cornerRadius = 10
                cell.imageView?.clipsToBounds = true
                cell.imageView.sizeToFit()
                cell.layoutSubviews()

                });
            }
        }
        return cell
    }

    func updateProgramsList(_ newList : [Episode]) {
        self.episodeList.append(contentsOf: newList)
        self.collectionView?.reloadData()
        
    }
    
    func buildOneProgramsList(){
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
                        let episode = Episode(title: oneEpisode.textContent, detailsUrl: detailsUrl, imageUrl: imageUrl, videoId: videoId)
                        
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
