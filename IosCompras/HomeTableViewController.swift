//
//  HomeTableViewController.swift
//  IosCompras
//
//  Created by Matheus Aguiar on 17/05/17.
//  Copyright © 2017 Matheus Aguiar. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase


// Link para o exemplo dado em aula:
// https://bitbucket.org/danielvmacedo/demos_aulas_ios/src/90e8de873e7c8c7322f4f034950b5e93035877ed/13%20-%20FireBaseToDo/MyBase/GroupToDoTableViewController.swift?at=master&fileviewer=file-view-default


/*
 Testar permissões no Firebase:
 
 {
   "rules": {
     "Usuarios": {
       "$idUsuario": {
         ".read": "$idUsuario == auth.uid",
         ".write": "$idUsuario == auth.uid"
       }
     },
     "Listas": {
       "$idLista": {
         ".read": "root.child('Usuarios/' + auth.uid + '/MinhasListas/' + $idLista).exists()",
         ".write": "root.child('Usuarios/' + auth.uid + '/MinhasListas/' + $idLista).exists()"
       }
     }
   }
 }
 
 */


class HomeTableViewController: UITableViewController, FBSDKLoginButtonDelegate {
    
    var ref: FIRDatabaseReference!
    
    @IBOutlet weak var logoutFacebook: FBSDKLoginButton!

    var listaDeCompras = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.logoutFacebook.delegate = self
        
        self.ref = FIRDatabase.database().reference()
        
        let UID = FIRAuth.auth()?.currentUser!.uid
        let emailUsuario = FIRAuth.auth()?.currentUser!.email!
        print(emailUsuario!)
        
        // Adicionar lista
        let objLista = Lista(title: "Teste 2", addedBy: emailUsuario, itens: nil, ref: nil)
        let lista = self.ref.child("Listas").childByAutoId()
        let codLista = lista.key
        lista.setValue(objLista.toAnyObject())
        
        // Vincular lista ao usuário
        self.ref.child("Usuarios").child(UID!).child("MinhasListas").child(codLista).setValue(true)
        
        
        // Adicionar item
        var objItem = ItemLista(name: "Novo Item", ref: nil)
        self.ref.child("Listas").child(codLista).child("itens").childByAutoId().setValue(objItem.toAnyObject())
        objItem = ItemLista(name: "Mais um Item", ref: nil)
        self.ref.child("Listas").child(codLista).child("itens").childByAutoId().setValue(objItem.toAnyObject())
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return listaDeCompras.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    /**
     Sent to the delegate when the button was used to login.
     - Parameter loginButton: the sender
     - Parameter result: The results of the login
     - Parameter error: The error (if any) from the login
     */
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
    }


    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        navigationController?.popViewController(animated: true)
        print("logout")
    }

    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
    
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
 

}
