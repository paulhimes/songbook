//
//  SearchExactMatchCellModel.swift
//  songbook
//
//  Created by Paul Himes on 1/23/18.
//  Copyright © 2018 Paul Himes. All rights reserved.
//

import UIKit

class SearchExactMatchCellModel: NSObject, SearchCellModel {
    @objc let songID: NSManagedObjectID!
    @objc let range: NSRange = NSMakeRange(0, 0)
    @objc let number: UInt
    @objc let songTitle: String
    @objc let sectionTitle: String
    
    @objc init(songID: NSManagedObjectID, number: UInt, songTitle: String, sectionTitle: String) {
        self.songID = songID
        self.number = number
        self.songTitle = songTitle
        self.sectionTitle = sectionTitle
    }
}
