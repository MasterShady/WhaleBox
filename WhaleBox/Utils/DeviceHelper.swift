//
//  JailBreakCheck.swift
//  PKGModule
//
//  Created by 刘思源 on 2023/5/29.
//

import Foundation
import CoreTelephony


@objcMembers public class DeviceHelper: NSObject {
    static func isJailBreakCydia() -> Bool {
        if let url = URL(string: "cydia://"), UIApplication.shared.canOpenURL(url) {
            return true
        }
        return false
    }


    static func isJailBreakFiles() -> Bool {
        let pathArr = ["/Applications/Cydia.app", "/usr/sbin/sshd" , "/usr/sbin/sshd" , "/etc/apt"]
        for path in pathArr {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        return false
    }


    static func isJailBreakApps() -> Bool {
        let appPath = "/Applications/"
        if FileManager.default.fileExists(atPath: appPath) {
            do {
                let appList = try FileManager.default.contentsOfDirectory(atPath: appPath)
                if appList.count > 0 {
                    return true
                }
            } catch let error {
                 print(error)
            }
        }
        return false
    }
    
    public static var isJailBreak : Bool = {
        return isJailBreakCydia() || isJailBreakFiles() || isJailBreakApps()
    }()
    
    public static var hasSIMCard:Bool = {
        let networkInfo = CTTelephonyNetworkInfo()
        if let carriers = networkInfo.serviceSubscriberCellularProviders?.values{
            for carrier in carriers {
                if carrier.mobileCountryCode != nil {
                    return true
                }
            }
        }
        return false
    }()
}





