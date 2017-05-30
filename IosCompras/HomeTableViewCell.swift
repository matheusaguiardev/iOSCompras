//
//  HomeTableViewCell.swift
//  IosCompras
//
//  Created by Matheus Aguiar on 29/05/17.
//  Copyright © 2017 Matheus Aguiar. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {
    @IBOutlet weak var nameList: UILabel!
    @IBOutlet weak var creatorList: UILabel!
// celula customizada
    override func awakeFromNib() {
        super.awakeFromNib()
        nameList.adjustsFontSizeToFitWidth = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
