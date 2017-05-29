//
//  HomeTableViewController.swift
//  IosCompras
//
//  Created by Matheus Aguiar on 17/05/17.
//  Copyright © 2017 Matheus Aguiar. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

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

class HomeTableViewController: UITableViewController {
    
    var ref: FIRDatabaseReference!
    
    var UID:String? = nil
    
    var nameUser:String?
    
    var listaDeCompras = [Lista]()
    
    @IBAction func addLista(_ sender: Any) {
        
        let alert = UIAlertController(title: "Nova Lista", message: "Título da lista:", preferredStyle: .alert)
        alert.addTextField { (textField) in
            
        }
        
        let closeAction = UIAlertAction(title: "Fechar", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Criar", style: .default, handler:{
            (action) -> Void in
            
            let titulo = alert.textFields![0].text!
            print(titulo)

            // Adicionar lista
            let objLista = Lista(title: titulo, owner: self.UID,creator: self.nameUser ,itens: nil, ref: nil)
            let listas = self.ref.child("Listas")
            let novaLista = listas.childByAutoId()
            let codLista = novaLista.key
            // Adicionar as MinhasListas para o usuário ter permissão
            self.ref.child("Usuarios").child(self.UID!).child("MinhasListas").child(codLista).setValue(true)
            // Inserir a lista
            novaLista.setValue(objLista.toAnyObject())
            
            // Vincular lista ao usuário atual
            
        })
        
        alert.addAction(closeAction)
        alert.addAction(saveAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    

  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref = FIRDatabase.database().reference()
        self.UID = FIRAuth.auth()?.currentUser!.uid
        self.nameUser = FIRAuth.auth()?.currentUser!.displayName
        
//        self.ref.child("Usuarios/" + self.UID! + "/MinhasListas" ).observeSingleEvent(of:.value, with: { (snapshot) in
//            self.listaDeCompras.removeAll()
//            for childSnapshot in snapshot.children {
//                let child = childSnapshot as! FIRDataSnapshot
//                let idLista = child.key as String
//                
//                // Pegar dados da lista:
//                self.ref.child("Listas/" + idLista + "" ).observeSingleEvent(of: .value, with: { (snapshot) in
//                    let value = snapshot.value as! [String: Any]
//                    let newLista = Lista(title: value["title"] as? String, owner: value["owner"] as? String, itens: nil, ref:child.ref)
//                    self.listaDeCompras.append(newLista)
//                    self.tableView.reloadData()
//                })
//            }
//        })
        
        // Alterar pasta para Usuarios/UID/MinhasListas
        self.ref.child("Usuarios/" + self.UID! + "/MinhasListas" ).observe(.childAdded, with: { (snapshot) in
            let idLista = snapshot.key as String
            
            print("Adicionada: " + idLista)
            
            // TODO: Para cada ID de lista adicionado buscar os dados da lista em Listas/ID e criar o objeto
            // Pegar dados da lista:
            self.ref.child("Listas/" + idLista + "" ).observeSingleEvent(of: .value, with: { (snapshot) in
                if (snapshot.value is NSNull) {
                } else {
                    let value = snapshot.value as! [String: Any]
                    let newLista = Lista(title: value["title"] as? String, owner: value["owner"] as? String, creator: value["creator"] as? String ,itens: nil, ref:snapshot.ref)
                    self.listaDeCompras.append(newLista)
                    self.tableView.reloadData()
                }
            })
            
            // let indexPath = IndexPath(row: self.listaDeCompras.count - 1, section: 0)
            //self.tableView.insertRows(at: [indexPath], with: .fade)
        })
        
        
        // Alterar pasta para Usuarios/UID/MinhasListas
        
        self.ref.child("Usuarios/" + self.UID! + "/MinhasListas" ).observe(.childRemoved, with: { (snapshot) in
            let idLista = snapshot.key
            
            for (index, item) in self.listaDeCompras.enumerated() {
                if item.ref!.key == idLista {
                    self.listaDeCompras.remove(at: index)
                    let indexPath = IndexPath(row: index, section: 0)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                    break;
                }
            }
            
            
        })
        
        // COMO FAZER? Usar um observer para cada lista do usuário?
        // Se monitorar somente as MinhasListas lá só tem o ID
        // Ou não permite alteração de nome?
        
        self.ref.child( "Usuarios/" + self.UID! + "/MinhasListas" ).observe(.childChanged, with: { (snapshot) in
            let idLista = snapshot.key
            let updatedValue = snapshot.value as! [String:Any]
            
            for (index, item) in self.listaDeCompras.enumerated() {
                if item.ref!.key == idLista {
                    self.listaDeCompras[index].title = updatedValue["title"] as? String
                    self.listaDeCompras[index].owner = updatedValue["owner"] as? String
                    self.listaDeCompras[index].creator = updatedValue["creator"] as? String
                    break;
                }
            }
            
            self.tableView.reloadData()
        })
        
        /*
         COLOCAR NA CLASSE DA LISTA DE ITENS
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listaDeCompras.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LISTA_CELL", for: indexPath) as! HomeTableViewCell
        
        let item = listaDeCompras[indexPath.row]
        cell.nameList.text = item.title
        cell.creatorList.text = item.creator

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
            
            let item = self.listaDeCompras[indexPath.row]
            let idLista = item.ref?.key
            // testar se outra pessoa tem o idLista em MinhasListas
                item.ref?.removeValue()
            self.ref.child( "Usuarios/" + self.UID! + "/MinhasListas/" + idLista! ).removeValue()
     
        }
    }
    
    /**
     Sent to the delegate when the button was used to login.
     - Parameter loginButton: the sender
     - Parameter result: The results of the login
     - Parameter error: The error (if any) from the login
     */

    @IBAction func Logout(_ sender: UIBarButtonItem) {
        logOut()
        navigationController?.popViewController(animated: true)
        print("logout")
    }
    
    // Logout do professor: (atribuir a um botão da barra)
    func logOut(){
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            FBSDKLoginManager().logOut()
            self.dismiss(animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Erro efetuando logout: %@", signOutError)
        }
    }
    

    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
    
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        // TODO: Criar o segue.destinationViewController com cast para a classe de itens
        // Atribuir o objeto lista ao objeto Lista dentro da classe para consultar itens do ID e título
        
        
        if (segue.identifier == "LISTA_ITENS_SEGUE") {
            if let dvc = segue.destination as? ItensTableViewController {
                let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell)
                dvc.lista = self.listaDeCompras[indexPath!.row]
            }
        }
        
    }
 

}
