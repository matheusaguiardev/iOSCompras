//
//  LoginViewController.swift
//  IosCompras
//
//  Created by Matheus Aguiar on 17/05/17.
//  Copyright © 2017 Matheus Aguiar. All rights reserved.
//

import UIKit
import FirebaseAuth
import FacebookLogin
import FBSDKLoginKit


class LoginViewController: UIViewController {
    
    @IBOutlet weak var fbLogin: FBSDKLoginButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadFacebookKit()
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func loadFacebookKit() -> Void {
       
        //let loginButton = FBSDKLoginButton()
        //loginButton.delegate = self
    
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
