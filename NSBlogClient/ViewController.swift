//
//  ViewController.swift
//  NSBlogClient
//
//  Created by Ashif Khan on 13/02/16.

import UIKit
import CoreData
class ViewController: UIViewController , UITableViewDataSource, UITableViewDelegate, NSXMLParserDelegate{

    @IBOutlet weak var tableView: UITableView!
    var managedObjectContext:NSManagedObjectContext?
    var managedObjectModel:NSManagedObjectModel?
    var persistentStoreCoordinator:NSPersistentStoreCoordinator?
    var xmlParser:NSXMLParser!
    
    var channelTitle:String?
    var channelID:Int16=0
    var channelDescriptions:String?
    var channelDocs:String?
    var channelGenerator:String?
    var channelLastBuildDate:String?
    var channelLink:String?

    var itemsTitle:String?
    var itemsID:Int16=0
    var itemsDescriptions:String?
    var itemsAuthor:String?
    var itemsPubDate:String?
    var itemsLink:String?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let urlString = NSURL(string: "https://mikeash.com/pyblog/rss.py")
        let rssUrlRequest:NSURLRequest = NSURLRequest(URL:urlString!)
        //let queue:NSOperationQueue = NSOperationQueue()
        
        let session:NSURLSession = NSURLSession.sharedSession()
        
        session.dataTaskWithRequest(rssUrlRequest, completionHandler: {
            (data, response,  error) -> Void in
            //3
            self.xmlParser = NSXMLParser(data: data!)
            self.xmlParser.delegate = self
            self.xmlParser.parse()
        }).resume()
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //2
        let fetchRequest = NSFetchRequest(entityName: "Channels")
        
        //3
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            let data = results as! [NSManagedObject]
            print(data[0].valueForKey("descriptions"))
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
    }
    //MARK: NSXMLParserDelegate
    var currentParsedElement:String! = String()
    var items:Array<AnyObject> = Array<AnyObject>()
    
    var isChannel:Bool = true
    
    var channelDict:[String:AnyObject]!
    var itemsArr:[AnyObject]! = Array<AnyObject>()
    var itemsDict:[String:AnyObject]!
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName: String?, attributes attributeDict: [String : String]){
        if elementName == "channel" {
            channelDict = Dictionary()
        }
        if elementName == "item" {
            isChannel = false
            itemsDict = [String : AnyObject]()
        }
        if elementName == "title"{
            currentParsedElement = "title"
        }
        if elementName == "description"{
            currentParsedElement = "description"
        }
        if elementName == "link"{
            currentParsedElement = "link"
        }
        if elementName == "docs" {
            currentParsedElement = "docs"
        }
        if elementName == "generator" {
            currentParsedElement = "generator"
        }
        if elementName == "lastBuildDate"{
            currentParsedElement = "lastBuildDate"
        }
        if elementName == "author"{
            currentParsedElement = "author"
        }
        if elementName == "pubDate"{
            currentParsedElement = "pubDate"
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String){
        if currentParsedElement == "title"{
            if isChannel {
                channelTitle = string
            }else{
                itemsTitle = string
            }
        }
        if currentParsedElement == "description"{
            if isChannel {
                channelDescriptions = string
            }else{
                itemsDescriptions = string
            }
        }
        if currentParsedElement == "link"{
            if isChannel {
                channelLink = string
            }else{
                itemsLink = string
            }
        }
        if currentParsedElement == "docs"{
            channelDocs = string
        }
        if currentParsedElement == "generator"{
            channelGenerator = string
        }
        if currentParsedElement == "lastBuildDate"{
            channelLastBuildDate = string
        }
        if currentParsedElement == "pubDate"{
            itemsPubDate = string
        }
        if currentParsedElement == "author"{
            itemsAuthor = string
        }
        
    }
    
    func parser(parser: NSXMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?){
        if elementName == "title"{
            if isChannel {
                channelDict["title"] = channelTitle
            }else {
                itemsDict["title"] = itemsTitle
            }
        }
        if elementName == "link"{
            if isChannel {
                channelDict["link"] = channelLink
            }else {
                itemsDict["link"] = itemsLink
            }
        }
        if elementName == "description"{
            if isChannel {
                channelDict["description"] = channelDescriptions
            }else {
                itemsDict["description"] = itemsDescriptions
            }
        }
        if elementName == "docs"{
            if isChannel {
                channelDict["docs"] = channelDocs
            }
        }
        if elementName == "generator"{
            if isChannel {
                channelDict["generator"] = channelGenerator
            }
        }
        if elementName == "lastBuildDate"{
            if isChannel {
                channelDict["lastBuildDate"] = channelLastBuildDate
            }
        }
        if elementName == "pubDate"{
            if !isChannel {
                itemsDict["pubDate"] = itemsPubDate
            }
        }
        if elementName == "author"{
            if !isChannel {
                itemsDict["author"] = itemsAuthor
            }
        }
        if elementName == "channel" {
            channelDict["items"] = itemsArr
        }
        if elementName == "item" {
            if !isChannel {
                itemsArr.append(itemsDict)
            }
        }
    }
    @IBAction func save(sender: AnyObject) {
        
        //1
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //2
        let entity =  NSEntityDescription.entityForName("Channels",
            inManagedObjectContext:managedContext)
        
        let channels = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext: managedContext)
        
        //3
        channels.setValue(1, forKey: "channelID")
        channels.setValue(channelDict["title"], forKey: "title")
        channels.setValue(channelDict["link"], forKey: "link")
        channels.setValue(channelDict["description"], forKey: "descriptions")
        channels.setValue(channelDict["docs"], forKey: "docs")
        channels.setValue(channelDict["generator"], forKey: "generator")
        let dateString:String = channelDict["lastBuildDate"] as! String // change to your date format
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "day-month-year"
        
        let date = dateFormatter.dateFromString(dateString)
        channels.setValue( date, forKey: "lastBuildDate")
        
        //4
        do {
            try managedContext.save()
            //5
            //channels.append(person)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
    }
    func parserDidEndDocument(parser: NSXMLParser){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
            //print(self.channelDict!["items"])
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            if channelDict != nil { return (channelDict["items"] as! Array<AnyObject>).count}
            return 15;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        if channelDict != nil {
            var dict = itemsArr[indexPath.row] as! [String : AnyObject]
            cell!.textLabel!.text = dict["title"] as? String
        }else{
            cell!.textLabel!.text = "sample"
        }
        return cell!
    }

}

