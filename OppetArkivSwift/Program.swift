//
//  Program.swift
//  OppetArkivSwift
//
//  Created by Oscar Hallström on 2016-10-16.
//  Copyright © 2016 Oscar Hallström. All rights reserved.
//

import Foundation

struct Program {
    
    let title: String
    let detailsUrl: String
    
    init(title: String, detailsUrl: String) {
        self.title = title
        self.detailsUrl = "http://www.oppetarkiv.se" + detailsUrl
    }
    
}
