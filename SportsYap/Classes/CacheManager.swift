//
//  CacheManager.swift
//  GoFire
//
//  Created by Alex Pelletier on 3/26/17.
//  Copyright © 2017 Alex Pelletier. All rights reserved.
//

import UIKit

class CacheManager: NSObject {
    
    static var shared = CacheManager()
    
    var BASE_PATH = ""
    var BASE_COMPLEX_PATH = ""
    
    let avoid = ["/user"]
    
    override init(){
        super.init()
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        BASE_PATH = documentsPath + "/cache/"
        BASE_COMPLEX_PATH = "\(BASE_PATH)stats/"
        
        print("BASE PATH: \(BASE_PATH)")
        
        var isDir: ObjCBool = true
        if !FileManager.default.fileExists(atPath: BASE_PATH, isDirectory: &isDir){
            let url = URL.init(fileURLWithPath: BASE_PATH)
            try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
        }
        
        if !FileManager.default.fileExists(atPath: BASE_COMPLEX_PATH, isDirectory: &isDir){
            let url = URL.init(fileURLWithPath: BASE_COMPLEX_PATH)
            try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
        }
    }
    
    func uncacheDict(name: String, params: [String: String]?) -> [String: AnyObject]?{
        return nil
        if avoid.contains(name){
            return nil
        }
        
        let formattedName = name.replacingOccurrences(of: "/", with: "") + paramsToStr(params: params)
        
        let time = UserDefaults.standard.double(forKey: "Cache:\(formattedName)")
        if time < Date().timeIntervalSince1970-86400*2{
            return nil
        }
    
        let path = BASE_PATH + "\(formattedName).plist"
        if FileManager.default.fileExists(atPath: path){
            if let json = NSDictionary(contentsOfFile: path) as? [String: AnyObject]{
                return json
            }
        }
        return nil
    }
    func cacheDict(name: String, params: [String: String]?,json: [String: AnyObject]){
        let formattedName = name.replacingOccurrences(of: "/", with: "") + paramsToStr(params: params)
        let path = BASE_PATH + "\(formattedName).plist"
        let url = URL.init(fileURLWithPath: path)
        let cleaned = stripNull(dict: json)
        (cleaned as NSDictionary).write(to: url, atomically: true)
        
        UserDefaults.standard.set(NSDate().timeIntervalSince1970, forKey: "Cache:\(formattedName)")
    }
    
    func uncacheComplexDict(name: String, params: [String: [String: Any]]?) -> [String: AnyObject]?{
        return nil
        if avoid.contains(name){
            return nil
        }
        
        let formattedName = name.replacingOccurrences(of: "/", with: "") + paramsToStrComplex(params: params)
        
        let time = UserDefaults.standard.double(forKey: "Cache:\(formattedName)")
        if time < Date().timeIntervalSince1970-86400*2{
            return nil
        }
        
        let path = BASE_COMPLEX_PATH + "\(formattedName).plist"
        if FileManager.default.fileExists(atPath: path){
            if let json = NSDictionary(contentsOfFile: path) as? [String: AnyObject]{
                return json
            }
        }
        return nil
    }
    func cacheComplexDict(name: String, params: [String: [String: Any]]?,json: [String: AnyObject]){
        let formattedName = name.replacingOccurrences(of: "/", with: "") + paramsToStrComplex(params: params)
        let path = BASE_COMPLEX_PATH + "\(formattedName).plist"
        let url = URL.init(fileURLWithPath: path)
        let cleaned = stripNull(dict: json)
        (cleaned as NSDictionary).write(to: url, atomically: true)
        
        UserDefaults.standard.set(NSDate().timeIntervalSince1970, forKey: "Cache:\(formattedName)")
    }

    func clearAll(){
        do {
            try FileManager.default.removeItem(atPath: BASE_PATH)
        } catch {}
        CacheManager.shared = CacheManager()
    }
    
    func clearStats(){
        do {
            try FileManager.default.removeItem(atPath: BASE_COMPLEX_PATH)
        } catch {}
        CacheManager.shared = CacheManager()
    }
    
    //MARK: Util
    func paramsToStr(params: [String: String]?) -> String{
        if let params = params{
            var str = "?"
            for p in params{
                str += "\(p.key)=\(p.value)&"
            }
            return str
        }else{
            return ""
        }
    }

    func paramsToStrComplex(params: [String: [String: Any]]?) -> String{
        if let params = params{
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                let jsonStr = String.init(data: jsonData, encoding: .utf8)
                if var json = jsonStr{
                    let toReplace = ["\"": "", "\n": "", "   ": "", "}": "]", "{": "[", ":": "=", " ": "", "\\/": "-"]
                    for part in toReplace{
                        json = json.replacingOccurrences(of: part.key, with: part.value)
                    }
                    json = json.replacingOccurrences(of: " : ", with: "=")
                    return "?\(json)"
                }
            } catch {
                print(error.localizedDescription)
            }
            return ""
        }else{
            return ""
        }
    }
    func stripNull(dict: [String: AnyObject]) -> [String: AnyObject]{
        var stripped = dict
        for el in stripped{
            if let val = el.value as? [String: AnyObject]{
                stripped[el.key] = stripNull(dict: val) as AnyObject
            }
            if let vals = el.value as? [[String: AnyObject]]{
                var sVals = [[String: AnyObject]]()
                for val in vals{
                    sVals.append(stripNull(dict: val))
                }
                stripped[el.key] = sVals as AnyObject
            }
            if let v = el.value as? NSObject{
                if v == NSNull(){
                    stripped[el.key] = "" as AnyObject
                }
            }
        }
        return stripped
    }
    
}
