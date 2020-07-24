//
//  ResultCell.swift
//  FilmsVoting
//
//  Created by Владислав on 24.07.2020.
//  Copyright © 2020 Vladislav. All rights reserved.
//

import UIKit

class ResultCell: UITableViewCell {
    
    var option: Option?
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var votesLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension ResultCell: ConfigurableView {
    
    typealias ConfigurationModel = Option
    
    func configure(with model: Option) {
        option = model
        contentLabel.text = model.content
        votesLabel.text = String(model.vote)
    }
    
}
