//
//  Utility.swift
//  RentoMovie
//
//  Created by Shailesh.Chandavar on 07/12/18.
//  Copyright © 2018 Shailesh.Chandavar. All rights reserved.
//

import Foundation
import UIKit

///SegueIdentifier enum contains all the identifiers used for Segue in app
enum SegueIdentifier: String {
    case movieListScreen
}

//Adding string localization
extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}

extension UIFont {
    func sizeOfString (strings: [String], constrainedToWidth width: Double) -> CGFloat {
        var stringHeight: CGFloat = 0.0
        for string in strings {
            stringHeight = stringHeight + NSString(string: string).boundingRect(with: CGSize(width: width, height: Double.greatestFiniteMagnitude),
                                                                                options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                                                attributes: [NSAttributedStringKey.font: self],
                                                                                context: nil).size.height
        }
        return stringHeight
    }
}

extension Data {
    
    static func documentDirectoryPath() -> URL? {
        return try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
    
    func storeDataInFile(fileName: String) {
        DispatchQueue.main.async {
            if let documentDirectoryPath = Data.documentDirectoryPath()  {
                let fileURL = documentDirectoryPath.appendingPathComponent(fileName).appendingPathExtension("txt")
                try? self.write(to: fileURL, options: Data.WritingOptions.atomic)
            }
        }
    }
    
    static func loadDataFromFile(fileName: String) -> Data? {
        var data: Data?
        
        if let documentDirectoryPath = self.documentDirectoryPath()  {
            let fileURL = documentDirectoryPath.appendingPathComponent(fileName).appendingPathExtension("txt")
            
            data = try? Data(contentsOf: fileURL)
        }
        return data
        
    }
}


