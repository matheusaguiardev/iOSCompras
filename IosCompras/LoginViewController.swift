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
import FirebaseDatabase


class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
   
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFacebookKit()
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func loadFacebookKit() -> Void {
        self.fbLoginButton.delegate = self
        self.fbLoginButton.readPermissions = ["email"]
    }

    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        FBSDKAccessToken.current()
        if let token = FBSDKAccessToken.current() {
           let credential = FIRFacebookAuthProvider.credential(withAccessToken: token.tokenString)
            
            FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                //let a =  user
                //print("\(String(describing: a!.displayName))")
                self.ref = FIRDatabase.database().reference()
                self.ref.child("Compras").child("Itens_de_compra").setValue(["Item_Lista": [String]()])
                
                self.performSegue(withIdentifier: "LOGIN_SEGUE", sender: nil)
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("logout")
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
    }
    

}
