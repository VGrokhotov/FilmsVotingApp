//
//  RoomCell.swift
//  FilmsVoting
//
//  Created by Владислав on 22.05.2020.
//  Copyright © 2020 Vladislav. All rights reserved.
//

import UIKit

protocol ConfigurableView {
    
    associatedtype ConfigurationModel
    
    func configure(with model: ConfigurationModel)
}

class RoomCell: UITableViewCell {
    
    var room: Room?
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension RoomCell: ConfigurableView {
    
    typealias ConfigurationModel = Room
    
    func configure(with model: Room) {
        room = model
        nameLabel.text = model.name
    }
    
}
