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
    
    var isJobGiven = false
    
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
        let jobsCollection = db.collection("jobs")
        let givenJobsCollection = db.collection("givenJobs")
        let applicationsCollection = db.collection("applications")

        print("Fetching job...")

        // Jobs koleksiyonundan belirli bir dokümanı çek
        jobsCollection.document(jobID).getDocument { [weak self] (jobDocument, jobsError) in
            guard let self = self else { return }

            if let jobsError = jobsError {
                print("Error fetching job: \(jobsError.localizedDescription)")
            } else {
                if let jobData = jobDocument?.data(),
                   let jobStatus = jobData["status"] as? String {
                    print("Job Status: \(jobStatus)")

                    // Jobs koleksiyonundan alınan jobStatus'a göre işlem yap
                    if jobStatus == "pending" {
                        print("Fetching applications...")

                        // JobStatus "pending" ise, Applications koleksiyonundan tüm verileri al
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

                                    print("Fetched \(self.applicants.count) applicants")

                                    // TableView'ı ana thread üzerinde güncelle
                                    DispatchQueue.main.async {
                                        self.applicantsTableView.reloadData()
                                    }
                                }
                            }
                        }
                    } else if jobStatus == "taken" {
                        print("Fetching given jobs...")

                        // JobStatus "taken" ise, GivenJobs koleksiyonundan veriyi al
                        givenJobsCollection.whereField("jobUid", isEqualTo: jobID).getDocuments { [weak self] (givenJobsSnapshot, givenJobsError) in
                            guard let self = self else { return }

                            if let givenJobsError = givenJobsError {
                                print("Error fetching given job: \(givenJobsError.localizedDescription)")
                            } else {
                                // GivenJobs koleksiyonundan alınan veriye göre işlem yap
                                if let givenJobsDocuments = givenJobsSnapshot?.documents {
                                    self.applicants = givenJobsDocuments.compactMap { givenJobsDocument in
                                        let givenJobsData = givenJobsDocument.data()
                                        let applicantEmail = givenJobsData["applicantEmail"] as? String ?? ""
                                        return Applicant(applicantEmail: applicantEmail)
                                    }

                                    print("Fetched \(self.applicants.count) applicants")

                                    // TableView'ı ana thread üzerinde güncelle
                                    DispatchQueue.main.async {
                                        self.applicantsTableView.reloadData()
                                    }
                                }
                            }
                        }
                    }
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
        cell.jobUidLabel.text = jobUid
        
        // Diğer hücre özelliklerini de doldurabilirsiniz
        cell.jobGivenLabel.isHidden = true
        cell.jobUidLabel.isHidden = true
        
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 86.0 // Örnek olarak 80 birim mesafe belirlendi, siz istediğiniz değeri kullanabilirsiniz.
    }
}
