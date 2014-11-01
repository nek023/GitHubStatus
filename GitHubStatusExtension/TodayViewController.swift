//
//  TodayViewController.swift
//  GitHubStatusExtension
//
//  Created by Katsuma Tanaka on 2014/11/01.
//  Copyright (c) 2014年 Katsuma Tanaka. All rights reserved.
//

import Cocoa
import NotificationCenter

class TodayViewController: NSViewController, NCWidgetProviding {

    // MARK: - NSViewController
    
    override var nibName: String? {
        return "TodayViewController"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load last message
        if let lastMessage = NSUserDefaults.standardUserDefaults().stringForKey("lastMessage") {
            self.representedObject = lastMessage
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        // Update service status
        self.getServiceStatus { (message: String?, error: NSError?) -> Void in
            if let newMessage = message {
                NSUserDefaults.standardUserDefaults().setObject(message, forKey: "lastMessage")
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.representedObject = message
                })
            }
        }
    }
    
    
    // MARK: - Fetching Service Status
    
    func getServiceStatus(completion: ((message: String?, error: NSError?) -> Void)?) {
        let url = NSURL(string: "https://status.github.com/api/last-message.json")!
        let task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if let jsonObject = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? [String: String] {
                if let message = jsonObject["body"] {
                    completion?(message: message, error: nil)
                }
            } else {
                completion?(message: nil, error: error)
            }
        })
        
        task.resume()
    }
    
    
    // MARK: - NCWidgetProviding

    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        self.getServiceStatus { (message: String?, error: NSError?) -> Void in
            if let newMessage = message {
                NSUserDefaults.standardUserDefaults().setObject(message, forKey: "lastMessage")
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.representedObject = message
                })
                
                completionHandler(.NewData)
            } else {
                completionHandler(.Failed)
            }
        }
    }

}
