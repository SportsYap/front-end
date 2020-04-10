//
//  MoreGifsViewController.swift
//  SportsYap
//
//  Created by Solomon W on 9/3/19.
//  Copyright © 2019 Alex Pelletier. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import Gifu
import Nuke

class MoreGifsViewController: UIViewController {
    
    internal lazy var resultsArray: [GIF] = []
    internal lazy var sportsyapGifs: [String] = []
    
    internal let cellHeight: CGFloat = 250
    internal let cellIdentifier = "GifCell"
    
    private let searchViewModel = SearchViewModel()
    private let anonIdViewModel = AnonIdViewModel()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var category: GifCategory!
    var numberOfItemsInRow = CGFloat(2)
    
    var nextText: String? = nil
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        collectionView.register(AnimatedImageCell.self, forCellWithReuseIdentifier: cellIdentifier)
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 0
        
        titleLabel.text = category.sport
        
        sportsyapGifs.append(Bundle.main.path(forResource: "ko", ofType: "gif")!)
        
        if category.sport == "Basketball" {
            sportsyapGifs.append(Bundle.main.path(forResource: "And1", ofType: "gif")!)
            sportsyapGifs.append(Bundle.main.path(forResource: "choke", ofType: "gif")!)
            sportsyapGifs.append(Bundle.main.path(forResource: "fistShake", ofType: "gif")!)
            sportsyapGifs.append(Bundle.main.path(forResource: "IssaThree", ofType: "gif")!)
            sportsyapGifs.append(Bundle.main.path(forResource: "LIT", ofType: "gif")!)
            sportsyapGifs.append(Bundle.main.path(forResource: "Shh", ofType: "gif")!)

        } else if category.sport == "Baseball" {
            sportsyapGifs.append(Bundle.main.path(forResource: "batFlip_1", ofType: "gif")!)
            sportsyapGifs.append(Bundle.main.path(forResource: "Homer", ofType: "gif")!)
            sportsyapGifs.append(Bundle.main.path(forResource: "RallyMonkey", ofType: "gif")!)
            sportsyapGifs.append(Bundle.main.path(forResource: "robbed", ofType: "gif")!)
            sportsyapGifs.append(Bundle.main.path(forResource: "youreOut", ofType: "gif")!)
            
        } else if category.sport == "Football" {
            sportsyapGifs.append(Bundle.main.path(forResource: "BigCatch", ofType: "gif")!)
            sportsyapGifs.append(Bundle.main.path(forResource: "Flag", ofType: "gif")!)
            sportsyapGifs.append(Bundle.main.path(forResource: "IssaTD_1", ofType: "gif")!)
            sportsyapGifs.append(Bundle.main.path(forResource: "ItsGood", ofType: "gif")!)
            sportsyapGifs.append(Bundle.main.path(forResource: "MakeNoise", ofType: "gif")!)
            
        } else if category.sport == "Soccer" {
            sportsyapGifs.append(Bundle.main.path(forResource: "goal", ofType: "gif")!)
            
        } else if category.sport == "Hockey" {
            sportsyapGifs.append(Bundle.main.path(forResource: "hockey_goal", ofType: "gif")!)
        }
        
        refresh()
        
        //fetchAnonymousId()
    }
    
    @IBAction func backPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func refresh() {
        search(category.sport) { error in
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    private func fetchAnonymousId() {
        anonIdViewModel.getAnonymousId { [weak self] success in
            if success {
                self?.search(self?.category.sport ?? "") { error in
                    DispatchQueue.main.async {
                        self?.collectionView.reloadData()
                    }
                }
                
            } else {
                print("an error")
            }
        }
    }
    
    private func shouldLoadNextPage(_ currentItemIndex:Int) -> Bool {
        if(!isLoading && currentItemIndex > ((resultsArray.count + sportsyapGifs.count) - 10)) {
            return true
        }else{
            return false
        }
    }
    
    func search(_ searchText:String, completion:@escaping ((Error?)->Void)) {
        isLoading = true
        nextText = nil
        
        searchViewModel.searchMany(category.sport, next: "0") { (response, error) in
            self.isLoading = false
            guard let response = response else{
                completion(error)
                return
            }
            self.nextText = response.next
            self.resultsArray = response.results ?? []
            completion(nil)
        }
    }
    
    func loadPage(_ next:String?, completion:@escaping ((Error?)->Void)) {
        isLoading = true
        searchViewModel.searchMany(category.sport, next: nextText) { (response, error) in
            self.isLoading = false
            guard let response = response else{
                completion(error)
                return
            }
            self.nextText = response.next
            self.resultsArray.append(contentsOf: response.results ?? [])
            completion(nil)
        }
    }
    
    func loadNextPage(completion:@escaping ((Error?)->Void)) {
        if let nextVal = nextText, nextVal != "0" {
            loadPage(nextVal, completion: completion)
        }
    }
    
}

extension MoreGifsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return resultsArray.count + sportsyapGifs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! AnimatedImageCell
        
        if indexPath.row < sportsyapGifs.count {
            let gif = sportsyapGifs[indexPath.row]
            
            let url = URL(fileURLWithPath: gif)
            
            let imageOptions = ImageLoadingOptions(placeholder: nil, transition: .fadeIn(duration: 0.33), failureImage: nil, failureImageTransition: nil, contentModes: nil)
            
            cell.activityIndicator.startAnimating()
            
            ImagePipeline.Configuration.isAnimatedImageDataEnabled = true
            
            Nuke.loadImage(
                with: url,
                options: imageOptions,
                into: cell.imageView,
                completion: { [weak cell] _ in
                    cell?.activityIndicator.stopAnimating()
                }
            )
        
            
        } else {
            
            let gif = resultsArray[indexPath.row - sportsyapGifs.count]
            
            if let url = gif.media?.first?.tinyGIF?.url {
                print("item url: \(url)")
                
                let imageOptions = ImageLoadingOptions(placeholder: nil, transition: .fadeIn(duration: 0.33), failureImage: nil, failureImageTransition: nil, contentModes: nil)
                
                cell.activityIndicator.startAnimating()
                
                ImagePipeline.Configuration.isAnimatedImageDataEnabled = true
                
                Nuke.loadImage(
                    with: url,
                    options: imageOptions,
                    into: cell.imageView,
                    completion: { [weak cell] _ in
                        cell?.activityIndicator.stopAnimating()
                    }
                )
            }
        }
        

        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (shouldLoadNextPage(indexPath.item)) {
            loadNextPage { error in
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Post", message: "Are you sure you want to post this gif?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            var text: String
            
            if indexPath.row < self.sportsyapGifs.count {
                text = self.sportsyapGifs[indexPath.row]
            } else {
                text = self.resultsArray[indexPath.row - self.sportsyapGifs.count].media?.first?.tinyGIF?.url?.absoluteString ?? ""
            }
            
            ApiManager.shared.postComment(for: User.me.currentPost, text: text, onSuccess: {
                User.me.currentPost.commentsCount += 1
                self.presentingViewController?.dismiss(animated: true, completion: nil)
                //self.dismiss(animated: true, completion: nil)
            }, onError: voidErr)
        }
        
        let noAction = UIAlertAction(title: "No", style: .default, handler: nil)
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        present(alert, animated: true, completion: nil)
    }
    
}

extension MoreGifsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let width = (view.bounds.size.width - layout.sectionInset.left - layout.sectionInset.right) / 2.05
        return CGSize(width: width, height: width * 1.2)
    }
    
}
