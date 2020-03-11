//
//  DBObject.swift
//  
//
//  Created by Alex Pelletier on 7/21/17.
//  Copyright © 2017 Alex Pelletier. All rights reserved.
//

import UIKit

class DBObject: NSObject{
    
    var id = 0
    var createdAt = Date()
    var updatedAt = Date()
    var deletedAt: Date?
    
    var pivot: DBPivot?
    
    override var description: String{
        get{ return "`\(type(of: self))`  id: \(id)"  }
    }
    
    override var hash: Int{
        return id
    }
    
    private static var allDBObjects = [String:[Int: DBObject]]()
    
    override init() { }
    
    init(dict: [String: AnyObject]){
        super.init()
        
        update(dict: dict)
        
        let typeStr = String(describing: type(of:self))
        if DBObject.allDBObjects[typeStr] == nil{
            DBObject.allDBObjects[typeStr] = [id: self]
        }else{
            DBObject.allDBObjects[typeStr]?[id] = self
        }
        
    }
    
    internal func update(dict: [String: AnyObject]){
        if let i = dict["id"] as? Int{
            id = i
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let c = dict["created_at"] as? String{
            if let cAt = formatter.date(from: c){
                createdAt = cAt
            }
        }
        
        if let u = dict["updated_at"] as? String{
            if let uAt = formatter.date(from: u){
                updatedAt = uAt
            }
        }
        
        if let d = dict["deleted_at"] as? String{
            if let dAt = formatter.date(from: d){
                deletedAt = dAt
            }
        }
    }
    
    class func all() -> [AnyObject]{
        let typeStr = String(describing: self)
        if let objs = DBObject.allDBObjects[typeStr]{
            return objs.map({ $0.value })
        }
        return [DBObject]()
    }
    
    class func getBy(id: Int) -> AnyObject?{
        let typeStr = String(describing: self)
        if let objs = DBObject.allDBObjects[typeStr]{
            return objs[id]
        }
        return nil
    }
    
    class func emptyLocalStore(){
        let typeStr = String(describing: self)
        if typeStr == "DBObject"{
            DBObject.allDBObjects = [String:[Int: DBObject]]()
        }else{
            DBObject.allDBObjects.removeValue(forKey: typeStr)
        }
    }
    
    static func ==(lhs: DBObject, rhs: DBObject) -> Bool {
        return lhs.id != 0 && lhs.id == rhs.id
    }
}

class DBPivot {
    var itemAId: Int!
    var itemBId: Int!
    var createdAt: Date?
}
