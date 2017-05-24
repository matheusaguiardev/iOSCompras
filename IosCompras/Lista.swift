//
//  Lista.swift
//  IosCompras
//
//  Created by André Lima on 23/05/17.
//  Copyright © 2017 Matheus Aguiar. All rights reserved.
//

import Foundation
import Firebase

struct Lista {
    var title:String?
    var addedBy:String?
    var itens:[ItemLista]?
    var ref: FIRDatabaseReference?
    func toAnyObject() -> Any {
        return ["title":title!, "addedBy":addedBy!]
    }
}