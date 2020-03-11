//
//  FileManager.swift
//  GoFire
//
//  Created by Alex Pelletier on 6/5/17.
//  Copyright © 2017 Alex Pelletier. All rights reserved.
//

import UIKit

class ImageFileManager: NSObject {

    static var shared = ImageFileManager()
    
    var BASE_PATH = ""
    
    override init(){
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        BASE_PATH = documentsPath + "/images/"
        
        var isDir: ObjCBool = true
        if !FileManager.default.fileExists(atPath: BASE_PATH, isDirectory: &isDir){
            let url = URL.init(fileURLWithPath: BASE_PATH)
            try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
        }
    }
    
    func clearAll(){
        do {
            try FileManager.default.removeItem(atPath: BASE_PATH)
        } catch {}
        ImageFileManager.shared = ImageFileManager()
    }
    
    func saveImage(image: UIImage, key: String){
        DispatchQueue.global(qos: .background).async {
            if let data = image.pngData(){
                let path = self.BASE_PATH + key
                let url = URL(fileURLWithPath: path)
                do{
                    try data.write(to: url)
                }catch{ }
            }
        }
    }
    
    func getImage(key: String) -> UIImage?{
        let path = BASE_PATH + key
        let url = URL(fileURLWithPath: path)
        do{
            let data = try Data(contentsOf: url)
            let image = UIImage(data: data)
            return image
        }catch{}
        return nil
    }
}
