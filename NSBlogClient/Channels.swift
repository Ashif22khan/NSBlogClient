//
//  Channels.swift
//  NSBlogClient
//
//  Created by Ashif Khan on 13/02/16.

import Foundation
import CoreData
class Channels:NSManagedObjectContext{
    var title:String?
    var channelID:Int16=0
    var descriptions:String?
    var docs:String?
    var generator:String?
    var lastBuildDate:NSDate?
    var link:String?
}