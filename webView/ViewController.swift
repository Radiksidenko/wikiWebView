//
//  ViewController.swift
//  webView
//
//  Created by Radomyr Sidenko on 23.02.2018.
//  Copyright © 2018 Radomyr Sidenko. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var searchVar: UITextField!
    @IBAction func buttonWiki(_ sender: Any) {
        let test = "https://en.wikipedia.org/w/api.php?action=query&titles=" + searchVar.text! + "&prop=revisions&rvprop=content&format=json&formatversion=2"
       
        let url = URL(string: test)
        let session = URLSession.shared
    
        let task = session.dataTask(with: url!) { (data,resp,error) in
            guard error == nil else {return}
            let dict = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any]
            let result = self.enumerateThroughDict(dict!)
            let myHTML = "<h1>" + String(describing: result["title"]) + "</h1>" + "<p>" + String(describing: result["content"]) + "</p>"
            
            self.webView.loadHTMLString(myHTML, baseURL: nil)
            dump(result)
        }
        task.resume()
        
        
    }
    
    func enumerateThroughDict(_ dict: Any) -> [String: Any] {
        var result: [String: Any] = [:]
        guard let transformedDict = dict as? [String: Any] else {return [:] }
        for key in transformedDict.keys {
            if let newDict = transformedDict[key] as? [String: Any] {
                let nestedDict = enumerateThroughDict(newDict)
                for nestedKey in nestedDict.keys{
                    result[nestedKey] = nestedDict[nestedKey]
                }
            }
            else if let newArr = transformedDict[key] as? Array<Any>, !newArr.isEmpty {
                for key in newArr {
                    let nestedDict = enumerateThroughDict(key)
                    for nestedKey in nestedDict.keys{
                        result[nestedKey] = nestedDict[nestedKey]
                    }
                }
            }
            else {
                result[key] = transformedDict[key]
            }
        }
        return result
    }
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchVar.text = "Capybara"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

