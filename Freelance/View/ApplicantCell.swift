//
//  ApplicationCell.swift
//  Freelance
//
//  Created by umutcancicek on 23.12.2023.
//

import UIKit
import Firebase

class ApplicantCell: UITableViewCell {
    
    
    @IBOutlet weak var applicantLabel: UILabel!
    @IBOutlet weak var jobGivenLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var jobUidLabel: UILabel!
    
    var isJobGiven = false
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    @IBAction func acceptButton(_ sender: UIButton) {
        
        guard let applicantEmail = applicantLabel.text,
              let jobUid = jobUidLabel.text else {
            print("Applicant email or job UID is not available")
            return
        }
        
        // "givenJobs" koleksiyonuna ekleme işlemi burada gerçekleştirilecek
        addToGivenJobs(applicantEmail: applicantEmail, jobUid: jobUid)
        
        // Jobs koleksiyonundaki ilgili job'u güncelle
        updateJobStatus(jobUid: jobUid, newStatus: "taken")
        
        jobGivenLabel.isHidden = false
        acceptButton.isHidden = true
        print("accept button pressed")
    }
    
    func addToGivenJobs(applicantEmail: String, jobUid: String) {
        // Burada "givenJobs" koleksiyonuna ekleme işlemini gerçekleştirin
        // Örneğin, Firestore kullanıyorsanız:
        let db = Firestore.firestore()
        let givenJobsCollection = db.collection("givenJobs")
        
        givenJobsCollection.addDocument(data: [
            "applicantEmail": applicantEmail,
            "jobUid": jobUid
        ]) { error in
            if let error = error {
                print("Error adding to givenJobs: \(error.localizedDescription)")
            } else {
                print("Added to givenJobs successfully")
            }
        }
    }
    
    func updateJobStatus(jobUid: String, newStatus: String) {
        let db = Firestore.firestore()
        let jobsCollection = db.collection("jobs")
        
        // Belgeyi güncellemek için referans oluştur
        let jobRef = jobsCollection.document(jobUid)
        
        // Belgeyi güncelle
        jobRef.updateData(["status": newStatus]) { error in
            if let error = error {
                print("Error updating job status: \(error.localizedDescription)")
            } else {
                print("Job status updated successfully")
            }
        }
    }
    
    
    @IBAction func rejectButton(_ sender: UIButton) {
        print("reject button pressed")
    }
    
}
