//
//  AddViewController.swift
//  IosCompras
//
//  Created by André Lima on 30/05/17.
//  Copyright © 2017 Matheus Aguiar. All rights reserved.
//

import UIKit

protocol AddViewControllerDelagate {
    func editItem(item:ItemLista) -> Void
    func addItem(item:ItemLista) -> Void
}

class AddViewController: UIViewController {

    var delegate:AddViewControllerDelagate?
    
    var item:ItemLista?
    
    @IBOutlet weak var nameItem: UITextField!
    
    
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        
        if let _ = self.item{
            self.item?.nome = nameItem.text
            delegate?.editItem(item: self.item!)
        } else {
         delegate?.addItem(item: ItemLista(nome: nameItem.text,ref: nil))
        }

        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let _ = self.item {
            nameItem.text = item?.nome
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
