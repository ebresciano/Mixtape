//
//  SearchableRecord.swift
//  Mixtape
//
//  Created by Eva Marie Bresciano on 7/13/16.
//  Copyright © 2016 Eva Bresciano. All rights reserved.
//

import Foundation

@objc protocol SearchableRecord: class {
    func matchesSearchTerm(searchTerm: String) -> Bool
}

