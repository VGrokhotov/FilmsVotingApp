//
//  VotingCell.swift
//  FilmsVoting
//
//  Created by Владислав on 23.07.2020.
//  Copyright © 2020 Vladislav. All rights reserved.
//

import UIKit

class VotingCell: UITableViewCell {
    
    let bgColor = #colorLiteral(red: 0, green: 0.5294117647, blue: 1, alpha: 0.6368792808)
    var option: OptionWithSelection!
    @IBOutlet weak var contentLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = bgColor
        self.selectedBackgroundView = backgroundView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            if option.selected {
                backgroundColor = UIColor.white
                option.selected = false
            } else {
                backgroundColor = bgColor
                option.selected = true
            }
        }
    }
    
    
}

extension VotingCell: ConfigurableView {
    
    typealias ConfigurationModel = OptionWithSelection
    
    func configure(with model: OptionWithSelection) {
        option = model
        contentLabel.text = model.content
        
    }
    
}
