//
//  GifHelper.swift
//  SportsYap
//
//  Created by Solomon W on 9/3/19.
//  Copyright © 2019 Alex Pelletier. All rights reserved.
//

import UIKit
import Alamofire
import Gifu
import Nuke

let kAnonymousIdKey = "AnonymousId"
typealias Parameters = [String:String]

extension Gifu.GIFImageView {
    
    public override func nuke_display(image: Image?) {
        prepareForReuse()
        if let data = image?.animatedImageData {
            animate(withGIFData: data)
        } else {
            self.image = image
        }
    }
}

struct Configuration {
    static let url          = "https://api.tenor.com"
    static let key          = "2TJFCW9S05AX"
    static var pageLimit    = 1
    
    static func checkConfiguration() {
        
        if url.isEmpty || key.isEmpty {
            fatalError("""
                Invalid configuration found
            """)
        }
    }
}

struct GifCategory {
    var sport: String
    var first: GIF?
    
    init(sport: String, first: GIF? = nil) {
        self.sport = sport
        self.first = first
    }
    
    mutating func updateFirst(gif: GIF) {
        self.first = gif
    }
}

class AnonIdViewModel {
    
    // MARK: - Data
    
    private var dataRequest: DataRequest?
    
    // MARK: - Public Methods
    
    public func getAnonymousId(_ completion: @escaping ((Bool) -> Void)) {
        
        guard UserDefaults.standard.string(forKey: kAnonymousIdKey) == nil else { return completion(true) }
        
        guard let url = URLManager.getURL(for: .anonymousId) else { return }
        
        dataRequest?.cancel()
        
        dataRequest = Alamofire.request(url).responseJSON { response in
            
            switch response.result {
            case .success:
                
                guard let json = response.value as? [String: String],
                    let anonId = json["anon_id"] else {
                        return completion(false)
                }
                
                UserDefaults.standard.set(anonId, forKey: kAnonymousIdKey)
                
                completion(true)
                
            case .failure( _):
                completion(false)
            }
        }
    }
}

class SearchViewModel {
    
    // MARK: - Alias
    
    typealias SearchResult = ((_ data: [GIF]?, _ error: Error?) -> Void)
    typealias SearchResultMany = ((_ data: Response<[GIF]>?, _ error: Error?) -> Void)
    
    // MARK: - Data
    
    private var dataRequest: DataRequest?
    
    // MARK: - Public Methods
    public func searchMany(_ query: String, next: String?, completion: @escaping SearchResultMany) {
        let nextStr = (next != "0") ? "&pos=\(next!)" : ""
        let searchUrl = URLManager.getURL(for: .search, appending: ["q": query], withLimit: false)?.absoluteString
        
        if let url = URL(string: "\(searchUrl ?? "")\(nextStr)") {
            
            dataRequest?.cancel()
            dataRequest = Alamofire.request(url).responseData { response in
                
                switch response.result {
                case .success:
                    guard let data = response.data else {
                        let error = NSError(domain: "No data received.", code: -1, userInfo: nil)
                        completion(nil, error)
                        return
                    }
                    
                    do {
                        let decoder = JSONDecoder()
                        let response = try decoder.decode(Response<[GIF]>.self, from: data)
                        completion(response, nil)
                    } catch {
                        completion(nil, error)
                    }
                    
                case .failure(let error):
                    completion(nil, error)
                }
            }
        }
        
    }
    
    public func search(using query: String, completion: @escaping SearchResult) {
        
        guard let url = URLManager.getURL(for: .search, appending: ["q": query], withLimit: true) else { return }
        
        dataRequest?.cancel()
        
        dataRequest = Alamofire.request(url).responseData { response in
            
            switch response.result {
            case .success:
                guard let data = response.data else {
                    let error = NSError(domain: "No data received.", code: -1, userInfo: nil)
                    completion(nil, error)
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(Response<[GIF]>.self, from: data)
                    completion(response.results ?? [], nil)
                } catch {
                    completion(nil, error)
                }
                
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}


struct Response<T>: Decodable where T: Decodable {
    let webURL: URL?
    let results: T?
    let next: String?
    
    enum CodingKeys: String, CodingKey {
        case webURL = "weburl"
        case results
        case next
    }
}

struct GIF: Decodable {
    let tags: [String]?
    let url: URL?
    let media: [MediaCollection]?
    let created: Double?
    let shares: Int?
    let itemURL: URL?
    let hasAudio: Bool?
    let title: String?
    let id: String?
    
    enum CodingKeys: String, CodingKey {
        case tags, url, media, created, shares
        case itemURL = "itemurl"
        case hasAudio = "hasaudio"
        case title, id
    }
}


struct MediaCollection: Decodable {
    let nanoMP4: Media?
    let nanoWebM: Media?
    let tinyGIF: Media?
    let tinyMP4: Media?
    let tinyWebM: Media?
    let webM: Media?
    let gif: Media?
    let mp4: Media?
    let loopedMP4: Media?
    let mediumGIF: Media?
    let nanoGIF: Media?
    
    enum CodingKeys: String, CodingKey {
        case nanoMP4 = "nanomp4"
        case nanoWebM = "nanowebm"
        case tinyGIF = "tinygif"
        case tinyMP4 = "tinymp4"
        case tinyWebM = "tinywebm"
        case webM = "webm"
        case gif
        case mp4
        case loopedMP4 = "loopedmp4"
        case mediumGIF = "mediumgif"
        case nanoGIF = "nanogif"
    }
}

struct Media: Decodable {
    let url: URL?
    let dimension: [Int]?
    let duration: Double?
    let preview: URL?
    let size: Int64?
    
    enum CodingKeys: String, CodingKey {
        case url
        case dimension = "dims"
        case duration
        case preview
        case size
    }
}

enum EndPoint: String {
    case anonymousId    =   "/v1/anonid"
    case search         =   "/v1/search"
}

struct URLManager {
    
    // MARK: - Private Closures
    
    static private let convertItems: ((Parameters) -> [URLQueryItem]) = { parameters in
        return parameters.map { return URLQueryItem(name: $0, value: $1) }
    }
    
    // MARK: - Public Methods
    
    static public func getURL(for resource: EndPoint,
                              appending parameters: Parameters? = nil,
                              withLimit: Bool = false) -> URL? {
        
        let endPoint = resource.rawValue
        
        var urlComponents = URLComponents(string: Configuration.url + endPoint)
        
        //Query
        var queryItems: [URLQueryItem] = convertItems(parameters ?? [:])
        
        //Auth
        let authParameters = getAuthenticationParameters()
        queryItems.append(contentsOf: convertItems(authParameters))
        
        //Limit
        if withLimit {
            let limitParameters = getLimitingParameters()
            queryItems.append(contentsOf: convertItems(limitParameters))
        }
        
        //Anonymous
        if let anonParameters = getAnonymousIdParameters() {
            queryItems.append(contentsOf: convertItems(anonParameters))
        }
        
        urlComponents?.queryItems = queryItems
        
        return urlComponents?.url
    }
    
    // MARK: - Private Methods
    
    static private func getAuthenticationParameters() -> Parameters {
        return ["key"   : Configuration.key]
    }
    
    static private func getAnonymousIdParameters() -> Parameters? {
        guard let anonymoudId = UserDefaults.standard.string(forKey: kAnonymousIdKey) else { return nil }
        return ["anon_id"   : anonymoudId]
    }
    
    static private func getLimitingParameters() -> Parameters {
        return ["limit" : "\(Configuration.pageLimit)"]
    }
}
