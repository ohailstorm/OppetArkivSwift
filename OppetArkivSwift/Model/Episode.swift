//
//  Episode.swift
//  OppetArkivSwift
//
//  Created by Oscar Hallström on 2016-10-16.
//  Copyright © 2016 Oscar Hallström. All rights reserved.
//

import Foundation

struct Episode {
    
    let title: String
    let detailsUrl: String
    let imageUrl: String
    let videoId : String
    
    init(title: String, detailsUrl: String, imageUrl: String, videoId: String) {
        self.title = title
        self.detailsUrl = "https://www.oppetarkiv.se" + detailsUrl
        self.imageUrl = imageUrl
        self.videoId = videoId
    }
    
}
