//
//  ViewController.swift
//  openlibrary
//
//  Created by Ricardo on 12/02/2016.
//  Copyright © 2016 Tablaz. All rights reserved.
//

import UIKit

import SystemConfiguration

public class Reachability {
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}

class ViewController: UIViewController , UITextFieldDelegate {

    @IBOutlet var isbnCodeText: UITextField!
    @IBOutlet var infoData: UITextView!
    @IBOutlet var autoresLibro: UITextView!
    @IBOutlet var imagenPortada: UIImageView!
    @IBOutlet var bookTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.isbnCodeText.delegate = self;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func getBookData(isbd: String){
        let urls = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:\(isbd)"
        print(urls)
        let url = NSURL(string: urls)
        let datos:NSData? = NSData(contentsOfURL: url!)
        let texto = NSString(data:datos!, encoding: NSUTF8StringEncoding)
        if texto == "{}" || texto == "" {
            let alerta = UIAlertController(title: "Search Result", message: "No Data Found, check the ISBD Code", preferredStyle: UIAlertControllerStyle.Alert)
            alerta.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alerta, animated: true, completion: nil)
            self.infoData.text = "";
        } else if texto == nil {
            let alerta = UIAlertController(title: "Search Result", message: "No Data Found, check Internet connection", preferredStyle: UIAlertControllerStyle.Alert)
            alerta.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alerta, animated: true, completion: nil)
            self.infoData.text = "";
        } else {
            self.parceEventsJson(datos!)
            
            self.infoData.text = texto! as String;
            
        }

    }
    
    func parceEventsJson(nsdata: NSData){
        do {
            let jsonFull = try NSJSONSerialization.JSONObjectWithData(nsdata, options: NSJSONReadingOptions.MutableContainers) as! [String: AnyObject]
            let bookArray = jsonFull as NSDictionary
            for (_, value) in bookArray {
                // Process Book Title
                let title  = value["title"] as! NSString
                self.bookTitle.text = title as String
                
                // Process Author List
                let authors = value["authors"]! != nil ? value["authors"] as! NSArray : [] 
                var authorsList: String = "Authors:\n"
                for author in authors {
                    let authorName = author["name"] as! String
                    authorsList = authorsList+"\(authorName)\n"
                }
                self.autoresLibro.text = authorsList as String
                
                // Process Book Cover
                let imageUrls = value["cover"]!!["large"] as! String
                let url = NSURL(string: imageUrls)
                let data = NSData(contentsOfURL: url!)
                self.imagenPortada.image = UIImage(data: data!)
            }

        } catch{
            print("error")
            print(error)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == isbnCodeText {
            self.view.endEditing(true)
            if Reachability.isConnectedToNetwork() == true {
                print("Internet connection OK")
                getBookData(isbnCodeText.text! as String)
            } else {
                print("Internet connection FAILED")
                let alerta = UIAlertController(title: "Connection Error", message: "Please check your Internet Connection", preferredStyle: UIAlertControllerStyle.Alert)
                alerta.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alerta, animated: true, completion: nil)
                self.infoData.text = "";
            }

            return false
        }
        return true
    }

}

