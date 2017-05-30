//
//  ItensTableViewController.swift
//  IosCompras
//
//  Created by André Lima on 24/05/17.
//  Copyright © 2017 Matheus Aguiar. All rights reserved.
//

import UIKit

class ItensTableViewController: UITableViewController {
    
    @IBAction func addItemList(_ sender: UIBarButtonItem) {
    }
    var lista:Lista? = nil
    var itensLista = [ItemLista]()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let lista = self.lista {
            self.title = lista.title!
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
        cell.textLabel?.text = item.name

        return cell
    }


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


}
