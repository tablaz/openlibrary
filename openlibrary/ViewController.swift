//
//  ViewController.swift
//  openlibrary
//
//  Created by Ricardo on 12/02/2016.
//  Copyright © 2016 Tablaz. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UITextFieldDelegate {

    @IBOutlet var isbnCodeText: UITextField!
    @IBOutlet var infoData: UITextView!
    
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
        let urls = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=\(isbd)"
        print(urls)
        let url = NSURL(string: urls)
        let datos:NSData? = NSData(contentsOfURL: url!)
        let texto = NSString(data:datos!, encoding: NSUTF8StringEncoding)
        if texto == "{}" || texto == ""{
            let alerta = UIAlertController(title: "Search Result", message: "No Data Found, check the ISBD Code", preferredStyle: UIAlertControllerStyle.Alert)
            alerta.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alerta, animated: true, completion: nil)

            self.infoData.text = "";
        } else {
            self.infoData.text = texto! as String;
        }

    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == isbnCodeText {
            self.view.endEditing(true)
            getBookData(isbnCodeText.text! as String)
            return false
        }
        return true
    }

}

