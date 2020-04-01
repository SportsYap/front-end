//
//  EnterFieldViewController.swift
//  SportsYap
//
//  Created by Master on 2020/3/23.
//  Copyright © 2020 Alex Pelletier. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class EnterFieldViewController: UIViewController {
    
    @IBOutlet weak var viewFieldView: UIView!
    @IBOutlet weak var filterStackView: UIStackView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewLayout: UICollectionViewFlowLayout!
    
    var game: Game? {
        didSet {
            if let game = game {
                placesClient.autocompleteQuery(game.venue.name + ", " + game.venue.city + ", " + game.venue.state, bounds: nil, boundsMode: .bias, filter: nil) { (list, error) in
                    if let place = list?.first {
                        self.placesClient.fetchPlace(fromPlaceID: place.placeID, placeFields: .coordinate, sessionToken: nil) { (place, error) in
                            if let place = place {
                                self.coordinate = place.coordinate
                                self.radius = 10
                                self.panoView.moveNearCoordinate(self.coordinate, radius: self.radius)
                            }
                        }
                    }
                }
            }
        }
    }
    var posts: [Post] = []
    
    private var placesClient: GMSPlacesClient = GMSPlacesClient()
    private var panoView: GMSPanoramaView!
    
    private var radius: UInt = 0
    private var coordinate: CLLocationCoordinate2D = .init()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        panoView = GMSPanoramaView(frame: viewFieldView.bounds)
        panoView.delegate = self
        viewFieldView.addSubview(panoView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let game = game,
            posts.count == 0 {
            ApiManager.shared.story(for: game, page: 1, onSuccess: { (posts) in
                self.posts = posts
                self.collectionView.reloadData()
            }) { (err) in }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let width = CGFloat(Int((view.bounds.width - 2) / 3))
        collectionViewLayout.itemSize = CGSize(width: width, height: width)
        collectionViewLayout.prepare()
        collectionViewLayout.invalidateLayout()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let vc = segue.destination as? ShotViewController, let post = sender as? Post {
            vc.posts = [post]
            vc.game = game
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func onAddPost(_ sender: Any) {
        TagGameViewController.preselectedGame = game
        ParentScrollingViewController.shared.scrollToCamera()
    }
    
    @IBAction func onFilter(_ sender: UIButton) {
        
    }
}

extension EnterFieldViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item < posts.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FieldPostCollectionViewCell", for: indexPath) as! FieldPostCollectionViewCell
            cell.post = posts[indexPath.item]
            return cell
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: "AddShotCollectionViewCell", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = CGFloat(Int((view.bounds.width - 2) / 3))
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item < posts.count {
            let post = posts[indexPath.item]
            performSegue(withIdentifier: "showPost", sender: post)
            return
        }
        
        onAddPost(collectionView)
    }
}

extension EnterFieldViewController: GMSPanoramaViewDelegate {
    func panoramaView(_ view: GMSPanoramaView, error: Error, onMoveNearCoordinate coordinate: CLLocationCoordinate2D) {
        radius += 10
        panoView.moveNearCoordinate(coordinate, radius: radius)
    }
}
