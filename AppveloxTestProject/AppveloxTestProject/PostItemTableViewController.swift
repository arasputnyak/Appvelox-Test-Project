//
//  PostItemTableViewController.swift
//  AppveloxTestProject
//
//  Created by Анастасия Распутняк on 02.11.2019.
//  Copyright © 2019 Anastasiya Rasputnyak. All rights reserved.
//

import UIKit

class PostItemTableViewController: UITableViewController {
    
    @IBOutlet weak var postEnclosureImageView: UIImageView! {
        didSet {
            postEnclosureImageView.load(url: URL(string: (currentPost?.enclosure)!)!, indicator: loadingImageIndicatorView)
        }
    }
    @IBOutlet weak var loadingImageIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var postTitleLabel: UILabel! {
        didSet {
            postTitleLabel.text = currentPost?.title
        }
    }
    @IBOutlet weak var postTextLabel: UILabel! {
        didSet {
            postTextLabel.text = currentPost?.fullText
        }
    }
    
    var currentPost : Post?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingImageIndicatorView.startAnimating()
        navigationController?.navigationBar.tintColor = .white
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    

}


extension UIImageView {
    func load(url: URL, indicator: UIActivityIndicatorView) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                        indicator.stopAnimating()
                    }
                }
            }
        }
    }
}
