//
//  ViewController.swift
//  ARKit_App
//
//  Created by 저스트비버 on 2021/05/28.
//

import UIKit
import SafariServices

class ViewController1: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func onClick_AR(_ sender: Any) {
        let vcName = self.storyboard?.instantiateViewController(withIdentifier: "ViewController2")
        vcName?.modalTransitionStyle = .coverVertical
        self.present(vcName!, animated: true, completion: nil)
    }
    
    @IBAction func onClick_3D(_ sender: Any) {
        guard let googleURL = URL(string: "http://www.hanssem.store") else { return }
        //http://www.hanssem.store
        //https://google.com
            
        let safariVC = SFSafariViewController(url: googleURL)
        present(safariVC, animated: true, completion: nil)
    }
}

