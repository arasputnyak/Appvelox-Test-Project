//
//  XMLParserManager.swift
//  AppveloxTestProject
//
//  Created by Анастасия Распутняк on 02.11.2019.
//  Copyright © 2019 Anastasiya Rasputnyak. All rights reserved.
//

import UIKit

class XMLParserManager: NSObject, XMLParserDelegate {
    private var rssPosts : [Post] = []
    
    private var currentElement = ""
    private var currentCategory = "" {
        didSet {
            currentCategory = currentCategory.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentTitle = "" {
        didSet {
            currentTitle = currentTitle.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentPubDate = "" {
        didSet {
            currentPubDate = currentPubDate.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentEnclosure = ""
    private var currentFullText = "" {
        didSet {
            currentFullText = currentFullText.replacingOccurrences(of: "\n\n\n\n ", with: "")
        }
    }
    
    private var parserCompletionHandler : (([Post]) -> Void)?
    
    
    func parsePostFeed(url : String, completionHandler : (([Post]) -> Void)?) {
        self.parserCompletionHandler = completionHandler
        
        let parser = XMLParser(contentsOf: URL(string: url)!)
        parser?.delegate = self
        parser?.parse()
    }
    
    //MARK: - XMLParserDelegate -
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if currentElement == "item" {
            currentCategory = ""
            currentTitle = ""
            currentPubDate = ""
            currentEnclosure = ""
            currentFullText = ""
        } else if currentElement == "enclosure" {
            for string in attributeDict {
                if string.key == "url" {
                    currentEnclosure += string.value
                }
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement {
        case "category":
            currentCategory += string
        case "title":
            currentTitle += string
        case "pubDate":
            currentPubDate += string
        case "yandex:full-text":
            currentFullText += string
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            var pubDateElemets = currentPubDate.components(separatedBy: " ")
            pubDateElemets = Array(pubDateElemets[1...4])
            let pubDateAfterFormating = formateDateArray(array: pubDateElemets)
            
            let rssPost = Post(category: currentCategory, title: currentTitle, pubDate: pubDateAfterFormating, enclosure: currentEnclosure, fullText: currentFullText)
            rssPosts.append(rssPost)
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        parserCompletionHandler?(rssPosts)
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("failure error: ", parseError.localizedDescription)
    }
    
    func formateDateArray(array : [String]) -> String {
        let day = String(Int(array[0])!)
        
        let monthDict = [
            "Jan" : "января",
            "Feb" : "февраля",
            "Mar" : "марта",
            "Apr" : "апреля",
            "May" : "мая",
           "June" : "июня",
           "July" : "июля",
            "Aug" : "августа",
           "Sept" : "сентября",
            "Oct" : "октября",
            "Nov" : "ноября",
            "Dec" : "декабря"
        ]
        
        let month = monthDict[array[1]]
        
        var time = array[3]
        time = String(time.dropLast(3))
        
        return "\(day) \(month ?? "") \(array[2])   \(time)"
    }
}



