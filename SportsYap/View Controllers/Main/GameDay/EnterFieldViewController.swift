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
import SideMenu

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
    private var filteredPosts: [Post] = []
    
    private var placesClient: GMSPlacesClient = GMSPlacesClient()
    private var panoView: GMSPanoramaView!
    
    private var radius: UInt = 0
    private var coordinate: CLLocationCoordinate2D = .init()
    
    private enum FilterOptionTeam {
        case All
        case HomeOnly
        case AwayOnly
    }
    private var filterTeam: FilterOptionTeam = .All
    private var filterOfficials: Bool = false
    private var filterTime: Bool = false
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        panoView = GMSPanoramaView(frame: viewFieldView.bounds)
        panoView.delegate = self
        viewFieldView.addSubview(panoView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didPost), name: NSNotification.Name(rawValue: Post.newPostNotification), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if posts.count == 0 {
            reloadData()
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
}

extension EnterFieldViewController {
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func onAddPost(_ sender: Any) {
        TagGameViewController.preselectedGame = game
        present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
    }
    
    @IBAction func onFilter(_ sender: UIButton) {
        if let game = game {
            if let index = filterStackView.arrangedSubviews.index(of: sender) {
                switch index {
                case 0: // Team
                    let actionSheet = UIAlertController(title: NSLocalizedString("Filter By", comment: ""), message: NSLocalizedString("Select a team", comment: ""), preferredStyle: .actionSheet)
                    actionSheet.addAction(UIAlertAction(title: NSLocalizedString("All Teams", comment: ""), style: .default, handler: { (_) in
                        sender.setTitle(NSLocalizedString("Team", comment: ""), for: .normal)
                        sender.layoutIfNeeded()
                        sender.imageEdgeInsets = .init(top: 0, left: sender.bounds.size.width - 27, bottom: 0, right: 0)
                        self.filterTeam = .All
                        self.filterData()
                    }))
                    actionSheet.addAction(UIAlertAction(title: game.homeTeam.name, style: .default, handler: { (_) in
                        sender.setTitle(game.homeTeam.name, for: .normal)
                        sender.layoutIfNeeded()
                        sender.imageEdgeInsets = .init(top: 0, left: sender.bounds.size.width - 27, bottom: 0, right: 0)
                        self.filterTeam = .HomeOnly
                        self.filterData()
                    }))
                    actionSheet.addAction(UIAlertAction(title: game.awayTeam.name, style: .default, handler: { (_) in
                        sender.setTitle(game.awayTeam.name, for: .normal)
                        sender.layoutIfNeeded()
                        sender.imageEdgeInsets = .init(top: 0, left: sender.bounds.size.width - 27, bottom: 0, right: 0)
                        self.filterTeam = .AwayOnly
                        self.filterData()
                    }))
                    present(actionSheet, animated: true, completion: nil)
                case 1: // Officials
                    filterOfficials = !filterOfficials
                    sender.setImage(UIImage(named: filterOfficials ? "ic_triangle_up" : "ic_triangle"), for: .normal)
                    filterData()
                case 2: // Time
                    filterTime = !filterTime
                    sender.setImage(UIImage(named: filterTime ? "ic_triangle_up" : "ic_triangle"), for: .normal)
                    filterData()
                default:
                    break
                }
            }
        }
    }
}

extension EnterFieldViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredPosts.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item < filteredPosts.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FieldPostCollectionViewCell", for: indexPath) as! FieldPostCollectionViewCell
            cell.post = filteredPosts[indexPath.item]
            return cell
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: "AddShotCollectionViewCell", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = CGFloat(Int((view.bounds.width - 2) / 3))
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item < filteredPosts.count {
            let post = filteredPosts[indexPath.item]
            performSegue(withIdentifier: "showPost", sender: post)
            return
        }
        
        onAddPost(collectionView)
    }
}

extension EnterFieldViewController {
    private func reloadData() {
        if let game = game {
            ApiManager.shared.story(for: game, page: 1, onSuccess: { (posts) in
                self.posts = posts
                self.filterData()
            }) { (err) in }
        }
    }
    
    private func filterData() {
        filteredPosts.removeAll()
        
        for post in posts {
            if filterTeam == .AwayOnly && post.teamId != game?.awayTeam.id {
                continue
            }
            if filterTeam == .HomeOnly && post.teamId != game?.homeTeam.id {
                continue
            }
            if filterOfficials && !game!.fans.verified.contains(post.user) {
                continue
            }

            filteredPosts.append(post)
        }
        
        filteredPosts.sort { (post1, post2) -> Bool in
            if self.filterTime {
                return post1.createdAt.compare(post2.createdAt) == .orderedAscending
            } else {
                return post1.createdAt.compare(post2.createdAt) == .orderedDescending
            }
        }

        collectionView.reloadData()
    }
    
    @objc func didPost(_ notification: Notification) {
        if let post = notification.object as? Post,
            let game = game,
            post.gameId == game.id {
            reloadData()
        }
    }
}

extension EnterFieldViewController: GMSPanoramaViewDelegate {
    func panoramaView(_ view: GMSPanoramaView, error: Error, onMoveNearCoordinate coordinate: CLLocationCoordinate2D) {
        radius += 10
        panoView.moveNearCoordinate(coordinate, radius: radius)
    }
}
