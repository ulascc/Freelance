//
//  ApplicationCell.swift
//  Freelance
//
//  Created by umutcancicek on 23.12.2023.
//

import UIKit

class ApplicantCell: UITableViewCell {
    
    
    @IBOutlet weak var applicantLabel: UILabel!
    @IBOutlet weak var jobGivenLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func acceptButton(_ sender: UIButton) {
        jobGivenLabel.isHidden = false
        acceptButton.isHidden = true
        rejectButton.isHidden = true
        print("accept button pressed")
    }
    
    
    @IBAction func rejectButton(_ sender: UIButton) {
        print("reject button pressed")
    }
    
}
