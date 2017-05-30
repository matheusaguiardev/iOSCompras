//
//  LoginViewController.swift
//  IosCompras
//
//  Created by Matheus Aguiar on 17/05/17.
//  Copyright © 2017 Matheus Aguiar. All rights reserved.
//

import UIKit
import Firebase
import FacebookLogin
import FBSDKLoginKit


//  https://firebase.google.com/docs/database/ios/save-data
class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
   
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    var ref: FIRDatabaseReference!
    var userFacebook:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFacebookKit()
        
        FIRDatabase.database().persistenceEnabled = false
       
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(LoginViewController.displayLaunchDetails),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)
    }
    
    func displayLaunchDetails() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if appDelegate.scheme != nil {
            //print(appDelegate.scheme)
            let alert = UIAlertController(title: "URL Link", message: appDelegate.scheme, preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
        }
        if appDelegate.path != nil {
            print(appDelegate.path)
        }
        if appDelegate.query != nil {
            print(appDelegate.query)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)
    }
        
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func loadFacebookKit() -> Void {
        if let _ = FIRAuth.auth()!.currentUser {
            self.performSegue(withIdentifier: "LOGIN_SEGUE", sender: nil)
            return
        }
        self.fbLoginButton.delegate = self
        self.fbLoginButton.readPermissions = ["public_profile","email"]
    }

    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        // FBSDKAccessToken.current()
        
        if let token = FBSDKAccessToken.current() {
           let credential = FIRFacebookAuthProvider.credential(withAccessToken: token.tokenString)
            
            FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                self.ref = FIRDatabase.database().reference()
                
                // Adicionando o usuário ao database
                let UID = FIRAuth.auth()?.currentUser!.uid
                self.ref.child("Usuarios").child(UID!).child("nome").setValue("")
                            self.performSegue(withIdentifier: "LOGIN_SEGUE", sender: nil)
                self.instanceUser(fbSDK: result, userID: UID!)
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("logout")
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "LOGIN_SEGUE"){
            let destinationViewController = segue.destination as! HomeTableViewController
            
            destinationViewController.nameUser = self.userFacebook
        }
    }
    
    func instanceUser(fbSDK: FBSDKLoginManagerLoginResult, userID:String) -> Void {
        
        if fbSDK.grantedPermissions.contains("public_profile"){
            
            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath:  "me", parameters: ["fields":"first_name,last_name,email, picture.type(large)"])
            graphRequest.start(completionHandler: { (connection, result, error) -> Void in
                
                if let erro = error {
                    print("Error: \(erro)")
                } else {
                    if let data = result as? [String:Any] {
                        let nomeUsuario = (data["first_name"]! as! String) + " " + (data["last_name"]! as! String)
                        if let profilePictureObj = data["picture"] as? [String:Any] {
                            let dataPPO = profilePictureObj["data"] as! [String:Any]
                            let pictureUrlString  = dataPPO["url"] as! String
                            self.ref.child("Usuarios").child(userID).child("foto").setValue(pictureUrlString)
                        }
                        self.ref.child("Usuarios").child(userID).child("nome").setValue(nomeUsuario)
                        self.userFacebook = nomeUsuario
                    }
                    
                }
            }
            )}
    }
    

}
