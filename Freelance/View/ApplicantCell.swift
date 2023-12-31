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
        
        rejectButton.isHidden = false
        jobGivenLabel.isHidden = false
        acceptButton.isHidden = true
        
        
        print("accept button pressed")
    }
    
    
    @IBAction func rejectButton(_ sender: UIButton) {
        guard let applicantEmail = applicantLabel.text,
              let jobUid = jobUidLabel.text else {
            print("Applicant email or job UID is not available")
            return
        }

        // "givenJobs" koleksiyonundan ilgili dokümanı silme işlemi burada gerçekleştirilecek
        removeFromGivenJobs(applicantEmail: applicantEmail, jobUid: jobUid)

        // Jobs koleksiyonundaki ilgili job'u güncelle
        updateJobStatus(jobUid: jobUid, newStatus: "pending")

        rejectButton.isHidden = true
        jobGivenLabel.isHidden = true
        acceptButton.isHidden = false
     
        
        print("reject button pressed")
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
    

    func removeFromGivenJobs(applicantEmail: String, jobUid: String) {
        let db = Firestore.firestore()
        let givenJobsCollection = db.collection("givenJobs")

        // "givenJobs" koleksiyonundan ilgili dokümanı silebilmek için sorgu oluştur
        let query = givenJobsCollection
            .whereField("applicantEmail", isEqualTo: applicantEmail)
            .whereField("jobUid", isEqualTo: jobUid)

        query.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching document to delete: \(error.localizedDescription)")
            } else {
                // Dokümanları kontrol et ve her birini sil
                for document in snapshot?.documents ?? [] {
                    givenJobsCollection.document(document.documentID).delete { error in
                        if let error = error {
                            print("Error deleting document: \(error.localizedDescription)")
                        } else {
                            print("Document deleted successfully")
                        }
                    }
                }
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

    
}
