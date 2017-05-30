//
//  ItensTableViewController.swift
//  IosCompras
//
//  Created by André Lima on 24/05/17.
//  Copyright © 2017 Matheus Aguiar. All rights reserved.
//

import UIKit
import Firebase


class ItensTableViewController: UITableViewController, AddViewControllerDelagate {
    
    var ref: FIRDatabaseReference!
    
    var idLista:String?
    var lista:Lista? = nil
    var itensLista = [ItemLista]()
    
    @IBAction func addItemList(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Novo Item", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            
        }
        
        let closeAction = UIAlertAction(title: "Fechar", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Inserir", style: .default, handler:{
            (action) -> Void in
            
            print("oi")
            print("ID da lista: \(self.idLista!)")
            
            let nome = alert.textFields![0].text!
            print(nome)
            
            // Adicionar lista
            let objItem = ItemLista(nome: nome, ref: nil)
            let itens = self.ref.child("Listas/" + self.idLista! + "/Itens")
            let novoItem = itens.childByAutoId()
            //let codItem = novoItem.key
            
            // Inserir o item
            novoItem.setValue(objItem.toAnyObject())
            
        })
        
        alert.addAction(closeAction)
        alert.addAction(saveAction)
        
        self.present(alert, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref = FIRDatabase.database().reference()

        if let lista = self.lista {
            self.title = lista.title!
            self.idLista = lista.ref?.key
            
            if let idLista = lista.ref?.key {
                print("ID: \(idLista)")
                self.ref.child("Listas/" + idLista + "/Itens").observe(.childAdded, with: { (snapshot) in
                    let value = snapshot.value as! [String: Any]
                
                    let newItem = ItemLista(nome: value["nome"] as? String, ref:snapshot.ref)
                
                    self.itensLista.append(newItem)
                    let indexPath = IndexPath(row: self.itensLista.count - 1, section: 0)
                    self.tableView.insertRows(at: [indexPath], with: .fade)
                })
            }
            

                      
            self.ref.child("Listas/" + idLista! + "/Itens").observe(.childRemoved, with: { (snapshot) in
                let key = snapshot.key
                
                for (index, item) in self.itensLista.enumerated() {
                    if item.ref!.key == key {
                        self.itensLista.remove(at: index)
                        let indexPath = IndexPath(row: index, section: 0)
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                        break;
                    }
                }
                
                
            })
            
            self.ref.child("Listas/" + idLista! + "/Itens").observe(.childChanged, with: { (snapshot) in
                let key = snapshot.key
                let updatedValue = snapshot.value as! [String:Any]
                
                for (index, item) in self.itensLista.enumerated() {
                    if item.ref!.key == key {
                        self.itensLista[index].nome = updatedValue["title"] as? String
                        break;
                    }
                }
                
                self.tableView.reloadData()
            })
            
            
            
        }
    
    
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
        return self.itensLista.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ITEM_CELL", for: indexPath)

        let item = itensLista[indexPath.row]
        cell.textLabel?.text = item.nome

        return cell
    }


    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let item = self.itensLista[indexPath.row]
            item.ref?.removeValue()
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    
    func editItem(item:ItemLista) -> Void{
        print("\(item.nome)")
        item.ref?.setValue(item.toAnyObject())
        
//        self.tableView.reloadData()
    }
    
    
    func addItem(item:ItemLista) -> Void{
      createOrUpdateItemFirebase(item: item)
    }
    
    func createOrUpdateItemFirebase(item:ItemLista) -> Void {
        let objItem = item
        let itens = self.ref.child("Listas/" + self.idLista! + "/Itens")
        let novoItem = itens.childByAutoId()
        novoItem.setValue(objItem.toAnyObject())
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "EDIT_ITEM_SEGUE") {
            if let dvc = segue.destination as? AddViewController {
                dvc.delegate = self

            }
        } else if (segue.identifier == "CELL_CLICK_SEGUE"){
            if let dvc = segue.destination as? AddViewController {
                dvc.delegate = self
                if let indexPath = self.tableView.indexPathForSelectedRow{
                    dvc.item = self.itensLista[indexPath.row]
                }
            }
        }
        
        
    }


//

}
