//
//  NewsReader.swift
//  AppveloxTestProject
//
//  Created by Анастасия Распутняк on 05.11.2019.
//  Copyright © 2019 Anastasiya Rasputnyak. All rights reserved.
//

import Foundation

struct Post {
    let category : String
    let title : String
    let pubDate : String
    let enclosure : String
    let fullText : String
}

struct NewsReader {
    var categories : [String] {
        var categories = ["Все новости"]
        for post in posts {
            if !categories.contains(post.category) {
                categories.append(post.category)
            }
        }
        
        return categories
    }
    var posts : [Post] = []
    var chosenCategory : String?
    var sortedPosts : [Post] {
        if chosenCategory == nil {
            return posts
        } else {
            return sortPosts(by: chosenCategory!)
        }
    }
    
    
    private func sortPosts(by category : String) -> [Post] {
        var sortedPosts = [Post]()
        for post in posts {
            if post.category == category {
                sortedPosts.append(post)
            }
        }
        
        return sortedPosts
    }
    
}
