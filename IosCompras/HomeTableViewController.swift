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
    @IBAction func addLista(_ sender: Any) {
        
        let alert = UIAlertController(title: "Nova Lista", message: "Título da lista:", preferredStyle: .alert)
        alert.addTextField { (textField) in
            
        }
        
        let closeAction = UIAlertAction(title: "Fechar", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Criar", style: .default, handler:{
            (action) -> Void in
            
            let titulo = alert.textFields![0].text!
            print(titulo)
            
            let UID = FIRAuth.auth()?.currentUser!.uid
            
            // Adicionar lista
            let objLista = Lista(title: titulo, owner: UID, itens: nil, ref: nil)
            let lista = self.ref.child("Listas").childByAutoId()
            let codLista = lista.key
            lista.setValue(objLista.toAnyObject())
            
            // Vincular lista ao usuário atual
            self.ref.child("Usuarios").child(UID!).child("MinhasListas").child(codLista).setValue(true)
            
        })
        
        alert.addAction(closeAction)
        alert.addAction(saveAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    

    var listaDeCompras = [Lista]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.logoutFacebook.delegate = self
        
        self.ref = FIRDatabase.database().reference()
        
        // TODO: Alterar para monitorar a pasta MinhasListas dentro da pasta do usuário Usuarios/UID/MinhasListas
        self.ref.child("Listas").observeSingleEvent(of:.value, with: { (snapshot) in
            self.listaDeCompras.removeAll()
            for childSnapshot in snapshot.children {
                let child = childSnapshot as! FIRDataSnapshot
                let value = child.value as! [String: Any]
                
                let newLista = Lista(title: value["title"] as? String, owner: value["owner"] as? String, itens: nil, ref:child.ref)
                
                self.listaDeCompras.append(newLista)
                self.tableView.reloadData()
            }
        })
        
        self.ref.child("Listas").observe(.childAdded, with: { (snapshot) in
            let value = snapshot.value as! [String: Any]
            
            let newItem = Lista(title: value["title"] as? String, owner: value["owner"] as? String, itens: nil, ref:snapshot.ref)
            
            self.listaDeCompras.append(newItem)
            let indexPath = IndexPath(row: self.listaDeCompras.count - 1, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .fade)
        })
        
        self.ref.child("Listas").observe(.childRemoved, with: { (snapshot) in
            let key = snapshot.key
            
            for (index, item) in self.listaDeCompras.enumerated() {
                if item.ref!.key == key {
                    self.listaDeCompras.remove(at: index)
                    let indexPath = IndexPath(row: index, section: 0)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                    break;
                }
            }
            
            
        })
        
        self.ref.child("Listas").observe(.childChanged, with: { (snapshot) in
            let key = snapshot.key
            let updatedValue = snapshot.value as! [String:Any]
            
            for (index, item) in self.listaDeCompras.enumerated() {
                if item.ref!.key == key {
                    self.listaDeCompras[index].title = updatedValue["title"] as? String
                    self.listaDeCompras[index].owner = updatedValue["addedBy"] as? String
                    break;
                }
            }
            
            self.tableView.reloadData()
        })
        
        /*
        // Adicionar item
        var objItem = ItemLista(name: "Novo Item", ref: nil)
        self.ref.child("Listas").child(codLista).child("itens").childByAutoId().setValue(objItem.toAnyObject())
        objItem = ItemLista(name: "Mais um Item", ref: nil)
        self.ref.child("Listas").child(codLista).child("itens").childByAutoId().setValue(objItem.toAnyObject())
         */
        
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
        return self.listaDeCompras.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LISTA_CELL", for: indexPath)

        let lista = listaDeCompras[indexPath.row]
        cell.textLabel?.text = lista.title

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // Para deletar é preciso verificar se a lista tem outros participantes e deletar a referencia do participante
            // Só deletar a lista se for o ultimo participante
            
            let item = self.listaDeCompras[indexPath.row]
            item.ref?.removeValue()
     
        }
    }

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
    
    // Logout do professor: (atribuir a um botão da barra)
    func logOut(){
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            self.dismiss(animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Erro efetuando logout: %@", signOutError)
        }
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
