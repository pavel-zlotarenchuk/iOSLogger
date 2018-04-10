
//
//  iOSLogger.swift
//  iOSTestTasck
//
//  Created by Kravchenko Pavel on 3/30/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

import Zip

public class IOSLogger : NSObject{
    
    public static let instance = IOSLogger()
    
    var appName: String = ""
    var authorEmail: String = ""
    var sizeFile: Int = 0
    var countFiles: Int = 0
    var idFile: Int = 0
    var logFileURL: URL?
    let fileManager = FileManager.default
    var fileHandle: FileHandle?
    
    override init() {
        super.init()
    }
    
    public static func myInit(authorEmail : String){
        instance.authorEmail = authorEmail
        instance.sizeFile = 1024 * 1024 * 5
        instance.countFiles = 10
        
        if let url = instance.getUrlFile(index: instance.idFile) {
            instance.logFileURL = url
            print("iOSLogger: Logger is active")
        }
    }
    
    public static func myInit(authorEmail : String, sizeInMB : Int, countFiles : Int){
        instance.authorEmail = authorEmail
        instance.sizeFile = 1024 * 1024 * sizeInMB
        instance.countFiles = countFiles
        
        if let url = instance.getUrlFile(index: instance.idFile) {
            instance.logFileURL = url
            print("iOSLogger: Logger is active")
        }
    }
    
    public static func log (with tag : String, textLog : String){
        instance.saveToFile(stringLog: "\(tag): \(textLog)")
    }
    
    public static func v (textLog : String){
        instance.saveToFile(stringLog: "Verbose: \(textLog)")
    }
    
    public static func d (textLog : String){
        instance.saveToFile(stringLog: "Debug: \(textLog)")
    }
    
    public static func i (textLog : String){
        instance.saveToFile(stringLog: "Info: \(textLog)")
    }
    
    public static func w (textLog : String){
        instance.saveToFile(stringLog: "Warn: \(textLog)")
    }
    
    public static func e (textLog : String){
        instance.saveToFile(stringLog: "Error: \(textLog)")
    }
    
    func saveToFile(stringLog : String) {
        if let url = logFileURL {
            do {
                if fileManager.fileExists(atPath: url.path) == false {
                    let line = stringLog + "\n"
                    try line.write(to: url, atomically: true, encoding: .utf8)
                    
                    #if os(iOS) || os(watchOS)
                        if #available(iOS 10.0, watchOS 3.0, *) {
                            var attributes = try fileManager.attributesOfItem(atPath: url.path)
                            attributes[FileAttributeKey.protectionKey] = FileProtectionType.none
                            try fileManager.setAttributes(attributes, ofItemAtPath: url.path)
                        }
                    #endif
                } else {
               if (getSizeFile(path: url) >= sizeFile){
                        var i = countFiles
                        while i >= 1  {
                            if let urlPrevious = getUrlFile(index: i - 1) {
                                if fileManager.fileExists(atPath: urlPrevious.path){
                                    if let urlFollowing = getUrlFile(index: i){
                                        if fileManager.fileExists(atPath: urlFollowing.path){
                                            try fileManager.removeItem(at: urlFollowing)
                                        }
                                        try fileManager.moveItem(at: urlPrevious, to: urlFollowing)
                                    }
                                }
                            }
                            i -= 1
                        }
                        let line = stringLog + "\n"
                        try line.write(to: url, atomically: true, encoding: .utf8)
                        fileHandle = try FileHandle(forWritingTo: url as URL)
                    } else {
                        writeLog(path: url, log: stringLog)
                    }
                }
            } catch let error{
                print(error)
                print("File Destination could not write to file \(url).")
            }
        }
        print(stringLog)
    }
    
    public static func readLogs() {
        if let url = IOSLogger.instance.logFileURL {
            var inString = ""
            do {
                inString = try String(contentsOf: url)
            } catch {
                print("Failed reading from URL: \(url), Error: " + error.localizedDescription)
            }
            print(inString)
        }
    }
    
    public static func sendLogs(viewController : UIViewController){
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = IOSLogger.instance
            mail.setToRecipients([instance.authorEmail])
            
            let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String
            let nsObject = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject
            let version = nsObject as? String
            let build = Bundle.main.infoDictionary?["CFBundleVersion"]  as? String
            
            mail.setSubject("\(appName ?? "appName") \(version ?? "1.0")(\(build ?? "1.0"))")
            
            var attachmentData = Data()
            attachmentData.append(instance.getLogFileData())
            
            let logFileName = "\(instance.appName) \(version ?? "1.0")(\(build ?? "1.0")).zip"
            
            mail.addAttachmentData(attachmentData, mimeType: "text/plain", fileName: logFileName)
            
            viewController.present(mail, animated: true)
        } else {
            print("MailComposerError")
        }
    }
    
    func getUrlFile(index : Int) -> URL? {
        let fileName = "fileLogs_\(index)";
        let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        if let url = dir?.appendingPathComponent(fileName).appendingPathExtension("txt") {
            return url
        } else {
            print("iOSLogger: Error! url incorrectly")
            return nil
        }
    }
    
    func writeLog(path : URL, log : String) {
        do {
            if fileHandle == nil{
                fileHandle = try FileHandle(forWritingTo: path as URL)
            }
            if let fileHandle = fileHandle {
                _ = fileHandle.seekToEndOfFile()
                let line = log + "\n"
                if let data = line.data(using: String.Encoding.utf8) {
                    fileHandle.write(data)
                }
            }
        } catch {
            print("File Destination could not write to file \(path).")
        }
    }
    
    func getLogFileData() -> Data {
        IOSLogger.i(textLog: "Zipping file logs")
        let zipFilePath = try? Zip.quickZipFiles([logFileURL!], fileName: appName)
        let logFileData = try? Data(contentsOf: zipFilePath!, options: .dataReadingMapped)
        return logFileData!
    }
    
    func getSizeFile(path : URL) -> Int {
        var fileSize : Int = 0
        do {
            let resources = try path.resourceValues(forKeys:[.fileSizeKey])
            fileSize = resources.fileSize!
        } catch {
            print("Could not find file size \(path).")
        }
        return fileSize
    }
    
}

extension IOSLogger : MFMailComposeViewControllerDelegate{
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

