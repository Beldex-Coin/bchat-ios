//
//  Section.swift
//  DropDown tableViewCell
//
//  Created by Mehul  Singhal  on 04/07/17.
//  Copyright © 2017 Mehul  Singhal . All rights reserved.
//

import Foundation

struct Section
{
    var genre: String!
    var movies: [String]!
    var expandable:Bool!
    
    
    init(genre: String, movies: [String], expandable: Bool) {
        
        self.genre = genre
        self.movies = movies
        self.expandable = expandable
        
    }
}
