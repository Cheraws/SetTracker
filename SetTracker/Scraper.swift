//
//  scraper.swift
//  SetTracker
//
//  Created by Robert Chang on 8/2/17.
//  Copyright © 2017 Robert. All rights reserved.
//

import Foundation
import Alamofire
import Kanna

class Scraper{
    
    public var values = ("","")
    func scrapeSite(name: String, completion: @escaping ([String: String]) -> Void) -> [String: String] {
        var information = [String: String]()
        self.values = (name, "")
        let title = "Dumbbell Bench Press"
        
        //let link = "https://www.bodybuilding.com/exercises/main/popup/name/barbell-bench-press-medium-grip"
        let newName = name.replacingOccurrences(of: " ", with: "-", options: .regularExpression, range: nil)
        let link = "https://www.bodybuilding.com/exercises/main/popup/name/" + newName
        Alamofire.request(link).responseString { response in
            print("\(response.result.isSuccess)")
            if let html = response.result.value{
                information = self.parseHTML(html: html, title: title)
                completion(information)

            }

        }
        return information
    }
    
    func parseHTML(html: String, title: String) -> [String: String] {
        
        var parsed = [String: String]()
        var guide = ""
        var description = ""
        if let doc = Kanna.HTML(html: html, encoding: String.Encoding.utf8) {

            var title = doc.title!
            title = title.replacingOccurrences(of: "Exercise Guide and Video", with: "", options: .regularExpression)
            title = title.trimmingCharacters(in: .whitespacesAndNewlines)
            var images = ""
            //html links.
            for link in doc.css("a, href"){
                if let linkClass = link.className {
                    if linkClass == "thickbox"{
                        images += link["href"]! + ","
                    }
                }
            }
            parsed["images"] = images
            
            for div in doc.css("div"){
                if let divClass = div.className {
                    if divClass == "guideContent"{
 
                        var test = String(div.text!.characters.filter { !"\n\t\r".characters.contains($0) })
                        test = test.replacingOccurrences(of: "\\.(?! )", with: ".\n", options: .regularExpression, range: nil)
                        let myStringArr = test.components(separatedBy: "\n")
                        var count = 1
                        for string in myStringArr {
                            //remove opening spaces.
                            let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
                            let line = trimmedString.replacingOccurrences(of: "^[ ]{2, }", with: " ", options: .regularExpression, range: nil)
                            if (line.characters.count == 0){
                                continue
                            }
                            guide += String(count) + ". " + line + "\n"
                            count += 1
                        }
                        
                    }
                }
                if let id = div["id"]{
                    
                    if id == "exerciseDetails"{
                        let test = String(div.text!.characters.filter { !"\n\t\r".characters.contains($0) })
                        description = test.replacingOccurrences(of: "[ ]{4,}", with: "\n", options: .regularExpression, range: nil)
                        description = description.replacingOccurrences(of: "(Exercise Data)|(\(title))", with: "", options: .regularExpression)
                        description = description.replacingOccurrences(of: "Equipment:\n", with: "Equipment: ", options: .regularExpression, range: nil)
                        
                
                        //let matches = regex.matches(in: description,range: NSMakeRange(0, description.utf16.count))
                        let typePattern = "(?:Equipment: )[A-Za-z]*"
                        if let typeRange = description.range(of: typePattern,
                                                        options: .regularExpression) {
                            
                            let myStringArr = description[typeRange].components(separatedBy: ": ")
                            parsed["equipment"] = myStringArr[1]
                            // First type: NSSet
                        }

                        description = description.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                }
            }
            
            parsed["guide"] = guide
            parsed["description"] = description
            parsed["title"] = title
        }
        return parsed
    }
        //Wait until scraping is done.
}

    
    
    


