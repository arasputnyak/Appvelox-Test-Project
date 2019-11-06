//
//  PostListViewController.swift
//  AppveloxTestProject
//
//  Created by Анастасия Распутняк on 01.11.2019.
//  Copyright © 2019 Anastasiya Rasputnyak. All rights reserved.
//

import UIKit

class PostListViewController: UIViewController {
    
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var postsTableView: UITableView! {
        didSet {
            postsTableView.dataSource = self
            postsTableView.delegate = self
        }
    }
    @IBOutlet weak var categoryPicker: UIPickerView! {
        didSet {
            categoryPicker.dataSource = self
            categoryPicker.delegate = self
        }
    }
    
    @IBOutlet weak var categoryPickerBottomConstraint: NSLayoutConstraint!
    
    
    private let url = "https://www.vesti.ru/vesti.rss"
    private var newsReader = NewsReader()
    private let refreshControl = UIRefreshControl()
    
    
    @IBAction func actionPickCategory(_ sender: Any) {
        categoryPicker.isHidden ? showPicker() : hidePicker()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 10.0, *) {
            postsTableView.refreshControl = refreshControl
        } else {
            postsTableView.addSubview(refreshControl)
        }
        
        refreshControl.attributedTitle = NSAttributedString(string: "Обновление..", attributes: [:])
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        
        getPosts()
    }
    
    @objc private func refresh(_ sender : UIRefreshControl) {
        sender.beginRefreshing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.getPosts()
        })
    }
    
    private func getPosts() {
        let parserManager = XMLParserManager()
        parserManager.parsePostFeed(url: url) { rssPosts in
            self.newsReader.posts = rssPosts
            
            DispatchQueue.main.async {
                self.postsTableView.reloadData()
                self.categoryPicker.reloadAllComponents()
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }

}

// MARK: - UITableViewDataSource, UITableViewDelegate -

extension PostListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsReader.sortedPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let postCell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostTableViewCell
        
        let currentPost = newsReader.sortedPosts[indexPath.row]
        postCell.postTitleLabel.text = currentPost.title
        postCell.pubDateLabel.text = currentPost.pubDate
            
        return postCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let currentPost = newsReader.sortedPosts[indexPath.row]
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "PostItemTableViewController")
        if let postItemTVC = vc as? PostItemTableViewController {
            postItemTVC.navigationItem.title = navigationItem.title
            postItemTVC.currentPost = currentPost
            navigationController?.pushViewController(postItemTVC, animated: true)
        }
    }
    
}

// MARK: - UIPickerViewDataSource, UIPickerViewDelegate -

extension PostListViewController : UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return newsReader.categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        let pickerLabel = UILabel()
        pickerLabel.text = newsReader.categories[row]
        pickerLabel.font = UIFont.boldSystemFont(ofSize: 22)
        pickerLabel.textColor = (navigationController?.navigationBar.barTintColor!) ?? .black
        pickerLabel.textAlignment = .center
        
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            newsReader.chosenCategory = nil
        } else {
            newsReader.chosenCategory = newsReader.categories[row]
        }
        
        categoryButton.setTitle(newsReader.categories[row], for: .normal)
        postsTableView.scroll(to: .top, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.postsTableView.reloadData()
        })
        
        hidePicker()
    }
    
    func showPicker() {
        categoryPickerBottomConstraint.constant = categoryPicker.frame.height
        
        categoryPicker.isHidden = false
        categoryPicker.superview?.layoutIfNeeded()
        
        categoryPickerBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.categoryPicker.superview?.layoutIfNeeded()
        }
    }
    
    func hidePicker() {
        categoryPickerBottomConstraint.constant = categoryPicker.frame.height
        UIView.animate(withDuration: 0.3, animations: {
            self.categoryPicker.superview?.layoutIfNeeded()
        }) { finished in
            self.categoryPicker.isHidden = true
        }
    }

}


extension UITableView {
    
    func scroll(to: scrollsTo, animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            let numberOfSections = self.numberOfSections
            let numberOfRows = self.numberOfRows(inSection: numberOfSections-1)
            switch to{
            case .top:
                if numberOfRows > 0 {
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.scrollToRow(at: indexPath, at: .top, animated: animated)
                }
                break
            case .bottom:
                if numberOfRows > 0 {
                    let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                    self.scrollToRow(at: indexPath, at: .bottom, animated: animated)
                }
                break
            }
        }
    }
    
    enum scrollsTo {
        case top,bottom
    }
}

