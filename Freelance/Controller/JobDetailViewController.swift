//
//  JobDetailViewController.swift
//  Freelance
//
//  Created by umutcancicek on 14.12.2023.
//

import UIKit

class JobDetailViewController: UIViewController {

    var jobTitle: String?
    var jobExplanation: String?
    var jobPuplisher: String?
    var jobPrice: String?
    var jobCategory: String?
    var jobCity: String?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var explanationLabel: UILabel!
    @IBOutlet weak var puplisherLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("job detail secreen")
        
        titleLabel.text = jobTitle
        explanationLabel.text = jobExplanation
        puplisherLabel.text = jobPuplisher
        priceLabel.text = jobPrice
        categoryLabel.text = jobCategory
        cityLabel.text = jobCity
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func applyButton(_ sender: UIButton) {
        print("Successfully applied for the job")
    }
    
}
