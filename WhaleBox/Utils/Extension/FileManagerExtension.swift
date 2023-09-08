//
//  FileManagerExtension.swift
//  StoryMaker
//
//  Created by Mayqiyue on 2020/2/10.
//  Copyright © 2020 mayqiyue. All rights reserved.
//

import Foundation

extension FileManager {
    
    class var userDocumentDirectory: String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    }
    
    class func removeFilePath (_ filePath : String?) {
        guard let filePath = filePath else {return}
        if FileManager.default.fileExists(atPath: filePath) {
            do {
                try FileManager.default.removeItem(atPath: filePath)
            } catch let error as NSError {
                print("removeFilePath : \(error.localizedDescription)")
            }
        }
    }
    
    class func createDirectory(_ directory: String) {
        if !FileManager.default.fileExists(atPath: directory) {
            do {
                try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                print("catch error is \(error)")
            }
        }
    }
}
