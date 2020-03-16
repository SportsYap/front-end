//
//  GifsViewController.swift
//  SportsYap
//
//  Created by Solomon W on 9/2/19.
//  Copyright © 2019 Alex Pelletier. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import AlamofireImage
import Gifu
import Nuke

class GifsViewController: UIViewController {
    
    internal lazy var resultsArray: [GIF] = []
    
    internal let cellHeight: CGFloat = 250
    internal let cellIdentifier = "GifCell"
    
    private let searchViewModel = SearchViewModel()
    private let anonIdViewModel = AnonIdViewModel()

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var doneButton: UIButton!
    
    var categories = [GifCategory]()
    var selectedCategory: GifCategory!
    var isSearching = false
    
    var searchText = ""
    var nextText: String? = nil
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categories.append(GifCategory(sport: "Baseball", first: nil))
        categories.append(GifCategory(sport: "Basketball", first: nil))
        categories.append(GifCategory(sport: "Football", first: nil))
        categories.append(GifCategory(sport: "Hockey", first: nil))
        categories.append(GifCategory(sport: "Soccer", first: nil))
  
        collectionView.register(AnimatedImageCell.self, forCellWithReuseIdentifier: cellIdentifier)
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 0
        
        fetchAnonymousId()
    }
    
    @IBAction func donePressed(_ sender: Any) {
        if doneButton.title(for: .normal) == "Done" {
            dismiss(animated: true, completion: nil)
        } else {
            view.endEditing(true)
            
            isSearching = false
            collectionView.reloadData()
            doneButton.setTitle("Done", for: .normal)
        }
    }
    
    private func fetchAnonymousId() {
        anonIdViewModel.getAnonymousId { [weak self] success in
            
            if success {
                self?.fetchResult()
            } else {
                print("an error")
            }
        }
    }
    
    private func fetchResult(for keyword: String = "") {
        Configuration.pageLimit = 1
        
        DispatchQueue.global(qos: .default).async {
            
            self.searchViewModel.search(using: self.categories[0].sport) { [weak self] (data, error) in
                
                DispatchQueue.main.async {
                    if let error = error {
                        // Do not show error alert if, request was cancelled.
                        guard (error as NSError).code != -999 else { return }
                        print(error.localizedDescription)
                    }
                    else if let data = data {
                        print(data.count)
                        print(data)
                        self?.categories[0].first = data.first
                        self?.collectionView.reloadData()
                    }
                }
            }
        }
        
        DispatchQueue.global(qos: .default).async {
            
            self.searchViewModel.search(using: self.categories[1].sport) { [weak self] (data, error) in
                
                DispatchQueue.main.async {
                    if let error = error {
                        // Do not show error alert if, request was cancelled.
                        guard (error as NSError).code != -999 else { return }
                        print(error.localizedDescription)
                    }
                    else if let data = data {
                        self?.categories[1].first = data.first
                        self?.collectionView.reloadData()
                    }
                }
            }
        }
        
        DispatchQueue.global(qos: .default).async {
            
            self.searchViewModel.search(using: self.categories[2].sport) { [weak self] (data, error) in
                
                DispatchQueue.main.async {
                    if let error = error {
                        // Do not show error alert if, request was cancelled.
                        guard (error as NSError).code != -999 else { return }
                        print(error.localizedDescription)
                    }
                    else if let data = data {
                        self?.categories[2].first = data.first
                        self?.collectionView.reloadData()
                    }
                }
            }
        }
        
        DispatchQueue.global(qos: .default).async {
            
            self.searchViewModel.search(using: self.categories[3].sport) { [weak self] (data, error) in
                
                DispatchQueue.main.async {
                    if let error = error {
                        // Do not show error alert if, request was cancelled.
                        guard (error as NSError).code != -999 else { return }
                        print(error.localizedDescription)
                    }
                    else if let data = data {
                        self?.categories[3].first = data.first
                        self?.collectionView.reloadData()
                    }
                }
            }
        }
        
        DispatchQueue.global(qos: .default).async {
            
            self.searchViewModel.search(using: self.categories[4].sport) { [weak self] (data, error) in
                
                DispatchQueue.main.async {
                    if let error = error {
                        // Do not show error alert if, request was cancelled.
                        guard (error as NSError).code != -999 else { return }
                        print(error.localizedDescription)
                    }
                    else if let data = data {
                        self?.categories[4].first = data.first
                        self?.collectionView.reloadData()
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? MoreGifsViewController {
            vc.category = selectedCategory
        }
    }
    
    private func shouldLoadNextPage(_ currentItemIndex:Int) -> Bool {
        if(!isLoading && currentItemIndex > (resultsArray.count-10)) {
            return true
        }else{
            return false
        }
    }
    
    func search(completion:@escaping ((Error?)->Void)) {
        isLoading = true
        nextText = nil
        
        searchViewModel.searchMany(searchText, next: "0") { (response, error) in
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
        searchViewModel.searchMany(searchText, next: nextText) { (response, error) in
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

extension GifsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isSearching ? resultsArray.count : categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! AnimatedImageCell
        
        let gifUrl: URL?
        
        if isSearching {
            gifUrl = resultsArray[indexPath.row].media?.first?.tinyGIF?.url
            cell.textView.text = ""
        } else {
            gifUrl = categories[indexPath.row].first?.media?.first?.gif?.url
            cell.textView.text = categories[indexPath.row].sport
        }
        
        if let url = gifUrl {
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

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isSearching {
            let alert = UIAlertController(title: "Post", message: "Are you sure you want to post this gif?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default) { (_) in
                let text = self.resultsArray[indexPath.row].media?.first?.tinyGIF?.url?.absoluteString ?? ""
                
                ApiManager.shared.postComment(for: User.me.currentPost, text: text, onSuccess: {
                    self.dismiss(animated: true, completion: nil)
                }, onError: voidErr)
            }
            
            let noAction = UIAlertAction(title: "No", style: .default, handler: nil)
            
            alert.addAction(yesAction)
            alert.addAction(noAction)
            
            present(alert, animated: true, completion: nil)
            
        } else {
            selectedCategory = categories[indexPath.row]
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "MoreGifsViewController") as! MoreGifsViewController
            vc.category = selectedCategory
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard isSearching else { return }
        
        if (shouldLoadNextPage(indexPath.item)) {
            loadNextPage { error in
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
}

extension GifsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let width = (view.bounds.size.width - layout.sectionInset.left - layout.sectionInset.right) / 2.05
        return CGSize(width: width, height: width * 1.2)
    }
}

extension GifsViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        doneButton.setTitle("Cancel", for: .normal)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        isSearching = true
        searchText = searchBar.text!
        
        if searchBar.text!.trimmingCharacters(in: .whitespacesAndNewlines).length > 0 {
            search { (error) in
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.view.endEditing(true)
                }
            }
        }
    }
    
}


