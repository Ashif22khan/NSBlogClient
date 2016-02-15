//
//  Item.swift
//  NSBlogClient
//
//  Created by Ashif Khan on 13/02/16.

import Foundation
import CoreData
class Items:NSManagedObjectContext{
    var title:String?
    var channelID:Int16=0
    var itemID:Int16=0
    var descriptions:String?
    var author:String?
    var pubDate:NSDate?
    var link:String?
}