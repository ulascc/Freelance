//
//  ApplicationDetailViewController.swift
//  Freelance
//
//  Created by umutcancicek on 24.12.2023.
//

import UIKit
import Firebase

class ApplicationDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    var jobTitle: String?
    var jobExplanation: String?
    var jobPuplisher: String?
    var jobPrice: String?
    var jobCategory: String?
    var jobCity: String?
    var jobUid: String?
    
    var applicants: [Applicant] = []
    
    @IBOutlet weak var applicantsTableView: UITableView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var explanationLabel: UILabel!
    @IBOutlet weak var puplisherLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var uidLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = jobTitle
        explanationLabel.text = jobExplanation
        priceLabel.text = jobPrice
        categoryLabel.text = jobCategory
        cityLabel.text = jobCity
        
        puplisherLabel.text = jobPuplisher
        puplisherLabel.isHidden = true
        uidLabel.text = jobUid
        uidLabel.isHidden = true
        
        applicantsTableView.dataSource = self
        applicantsTableView.delegate = self
        // applicantsTableView'ye ApplicationCell'ı kaydettik
        applicantsTableView.register(UINib(nibName: "ApplicantCell", bundle: nil), forCellReuseIdentifier: "ApplicantCell")
        
        fetchApplicants()
        
    }
    

    func fetchApplicants() {
            guard let jobID = jobUid else {
                print("Job ID not available")
                return
            }

            let db = Firestore.firestore()
            let applicationsCollection = db.collection("applications")

            // JobID'ye sahip başvuruları getir
            let query = applicationsCollection.whereField("jobID", isEqualTo: jobID)

            query.getDocuments { [weak self] (snapshot, error) in
                guard let self = self else { return }

                if let error = error {
                    print("Error fetching applications: \(error.localizedDescription)")
                } else {
                    if let documents = snapshot?.documents {
                        self.applicants = documents.compactMap { document in
                            let data = document.data()
                            let applicantEmail = data["applicantEmail"] as? String ?? ""
                            return Applicant(applicantEmail: applicantEmail)
                        }

                        // TableView'ı güncelle
                        self.applicantsTableView.reloadData()
                    }
                }
            }
        }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return applicants.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ApplicantCell", for: indexPath) as! ApplicantCell

            let applicant = applicants[indexPath.row]
            cell.applicantLabel.text = applicant.applicantEmail

            // Diğer hücre özelliklerini de doldurabilirsiniz
            cell.jobGivenLabel.isHidden = true

            return cell
        }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 86.0 // Örnek olarak 80 birim mesafe belirlendi, siz istediğiniz değeri kullanabilirsiniz.
    }
}
