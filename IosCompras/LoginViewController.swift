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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFacebookKit()
       
        if (FBSDKAccessToken.current()) != nil {
            self.performSegue(withIdentifier: "LOGIN_SEGUE", sender: nil)
        }
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
                self.ref = FIRDatabase.database().reference()
                
                // Adicionando o usuário ao database
                let emailUsuario = FIRAuth.auth()?.currentUser!.email
                let UID = FIRAuth.auth()?.currentUser!.uid
                print("ID do Usuário: \(UID!)")
                self.ref.child("Usuarios").child(UID!).child("email").setValue(emailUsuario)
                
                /*
                let key = self.ref.child("Compras").childByAutoId().key
                let post = ["nome_produto": "Biscoito",
                            "Marca": "Oreo",
                            "Detalher": "1 pacote de 50g",
                            "comprado": "true"]
                let childUpdates = ["Itens_de_compras_1 \(key)": post,"Itens_de_compras_2": post]
                
                self.ref.updateChildValues(childUpdates)
                */
                
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
