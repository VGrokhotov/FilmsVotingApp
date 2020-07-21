//
//  OptionCell.swift
//  FilmsVoting
//
//  Created by Владислав on 13.07.2020.
//  Copyright © 2020 Vladislav. All rights reserved.
//

import UIKit

class OptionCell: UITableViewCell {
    
    var option: Option?
    @IBOutlet weak var contentLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension OptionCell: ConfigurableView {
    
    typealias ConfigurationModel = Option
    
    func configure(with model: Option) {
        option = model
        contentLabel.text = model.content
    }
    
}
