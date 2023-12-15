//
//  JobCell.swift
//  Freelance
//
//  Created by umutcancicek on 12.12.2023.
//

import UIKit

class JobCell: UITableViewCell {
    
    @IBOutlet weak var jobTitle: UILabel!
    @IBOutlet weak var jobExplanation: UILabel!
    @IBOutlet weak var jobPrice: UILabel!
    @IBOutlet weak var jobCity: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Hücre içeriğinin sağa ve sola mesafesini eşit olarak belirle
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
