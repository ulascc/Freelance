//
//  JobDetailViewController.swift
//  Freelance
//
//  Created by umutcancicek on 14.12.2023.
//

import UIKit
import Firebase
import FirebaseStorage

class JobDetailViewController: UIViewController {
    
    var jobTitle: String?
    var jobExplanation: String?
    var jobPuplisher: String?
    var jobPrice: String?
    var jobCategory: String?
    var jobCity: String?
    var jobUid: String?
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var explanationLabel: UILabel!
    @IBOutlet weak var puplisherLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var uidLabel: UILabel!
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var takeBackApplicationButton: UIButton!
    @IBOutlet weak var jobIsYoursLabel: UILabel!
    
    @IBOutlet weak var jobImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("job detail secreen")
        
        // Gelen jobUid ile Firestore'dan imageURL al ve işlevi çağır
        if let jobID = jobUid {
            loadImageFromFirestore(jobID: jobID)
        }
        
        titleLabel.text = jobTitle
        explanationLabel.text = jobExplanation
        puplisherLabel.text = jobPuplisher
        priceLabel.text = jobPrice
        categoryLabel.text = jobCategory
        cityLabel.text = jobCity
        uidLabel.text = jobUid
        uidLabel.isHidden = true
        
        takeBackApplicationButton.isHidden = true
        jobIsYoursLabel.isHidden = true
        checkIfJobIsYours()
        
        applicationCheck(jobID: jobUid ?? "") { alreadyApplied in
            if alreadyApplied {
                self.takeBackApplicationButton.isHidden = false
                self.applyButton.isHidden = true
                self.applyButton.isUserInteractionEnabled = false
                
            } else {
                self.takeBackApplicationButton.isHidden = true
            }
        }
        
        //checkApplicationStatus()
    }
    
    func loadImageFromFirestore(jobID: String) {
        let jobsCollection = Firestore.firestore().collection("jobs")
        jobsCollection.document(jobID).getDocument { (document, error) in
            if let error = error {
                print("Error fetching job details: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                // Fetch imageURL from Firestore
                if let imageURL = document["imageURLField"] as? String {
                    // Load image asynchronously using URLSession
                    if let url = URL(string: imageURL) {
                        URLSession.shared.dataTask(with: url) { (data, response, error) in
                            if let data = data {
                                DispatchQueue.main.async {
                                    // Set the image on the main thread
                                    self.jobImage.image = UIImage(data: data)
                                }
                            }
                        }.resume()
                    }
                }
            }
        }
    }
    
    @IBAction func applyButton(_ sender: UIButton) {
        
        // selfCheck() fonksiyonu true döndürüyorsa direkt çık
        guard !selfCheck() else {
            return
        }
        
        // Başvurunun kontrolünü yap
        applicationCheck(jobID: jobUid ?? "") { alreadyApplied in
            if alreadyApplied {
                // Kullanıcı zaten başvurmuşsa uyarı mesajını göster
                let alertController = UIAlertController(title: "Başvuru Zaten Yapıldı", message: "Bu işe zaten başvuruda bulundunuz.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            } else {
                // Başvuru yoksa Firestore koleksiyonuna başvuruyu ekle
                if let currentUser = Auth.auth().currentUser,
                   let currentUserEmail = currentUser.email,
                   let publisherEmail = self.jobPuplisher,
                   let jobID = self.jobUid {
                    
                    // Firestore koleksiyonunu oluştur
                    let applicationsCollection = Firestore.firestore().collection("applications")
                    
                    // Başvuru verisini oluştur
                    let applicationData = JobApplication(applicantEmail: currentUserEmail,
                                                         publisherEmail: publisherEmail,
                                                         jobID: jobID)
                    
                    // Firestore koleksiyonuna başvuruyu ekle
                    applicationsCollection.addDocument(data: [
                        "applicantEmail": applicationData.applicantEmail,
                        "publisherEmail": applicationData.publisherEmail,
                        "jobID": applicationData.jobID
                    ]) { error in
                        if let error = error {
                            // Başvuru sırasında hata oluştuğunda uyarı mesajını göster
                            let alertController = UIAlertController(title: "Başvuru Hatası", message: "İşe başvuru sırasında bir hata oluştu. Lütfen tekrar deneyin.", preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                            
                            print("Error applying for the job: \(error.localizedDescription)")
                        } else {
                            // Başvuru başarılıysa başarılı mesajını göster
                            let alertController = UIAlertController(title: "Başvuru Başarılı", message: "İşe başvurunuz başarıyla alındı.", preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "Tamam", style: .default, handler: { _ in
                                self.applyButton.backgroundColor = UIColor.systemGreen
                                self.applyButton.setTitle("başvuruldu", for: .normal)
                                self.applyButton.isUserInteractionEnabled = false
                                self.takeBackApplicationButton.isHidden = false
                                print("Successfully applied for the job")
                            }))
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    
    func applicationCheck(jobID: String, completionHandler: @escaping (Bool) -> Void) {
        // Firestore koleksiyonunu oluştur
        let applicationsCollection = Firestore.firestore().collection("applications")
        
        // Oturum açmış kullanıcının emailini al
        guard let currentUserEmail = Auth.auth().currentUser?.email else {
            // Kullanıcı oturum açmamışsa false döndür
            completionHandler(false)
            return
        }
        
        // Başvuruları kontrol et
        applicationsCollection
            .whereField("applicantEmail", isEqualTo: currentUserEmail)
            .whereField("jobID", isEqualTo: jobID)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error checking application: \(error.localizedDescription)")
                    // Hata durumunda false döndür
                    completionHandler(false)
                } else if let snapshot = snapshot, !snapshot.documents.isEmpty {
                    // Başvuru bulunduğunda true döndür
                    completionHandler(true)
                } else {
                    // Başvuru bulunamadığında false döndür
                    completionHandler(false)
                }
            }
    }
    
    
    @IBAction func takeBackApplicationButton(_ sender: UIButton) {
        // Oturum açmış kullanıcının bilgilerini al
        guard let currentUser = Auth.auth().currentUser,
              let currentUserEmail = currentUser.email,
              let jobID = jobUid,
              let publisherEmail = jobPuplisher else {
            print("User information is not available.")
            return
        }
        
        // Firestore koleksiyonunu oluştur
        let applicationsCollection = Firestore.firestore().collection("applications")
        
        // Başvuruyu geri almak için filtreleme yap
        let query = applicationsCollection
            .whereField("applicantEmail", isEqualTo: currentUserEmail)
            .whereField("jobID", isEqualTo: jobID)
            .whereField("publisherEmail", isEqualTo: publisherEmail)
        
        // Başvuruları getir
        query.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
            } else {
                // Başvuruları kontrol et
                if let documents = snapshot?.documents {
                    for document in documents {
                        // Dökümanı sil
                        applicationsCollection.document(document.documentID).delete { error in
                            if let error = error {
                                print("Error deleting document: \(error.localizedDescription)")
                            } else {
                                print("Application successfully taken back.")
                                
                                // Başvuru geri alındıktan sonra ekranda bir geri bildirim göster
                                self.showAlert(title: "Başvuru Geri Alındı", message: "Başvurunuz başarıyla geri alındı.")
                                
                                self.takeBackApplicationButton.isHidden = true
                                
                                self.applyButton.isUserInteractionEnabled = true
                                self.applyButton.isHidden = false
                                self.applyButton.setTitle("Apply", for: .normal)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func checkApplicationStatus() {
        // Oturum açmış kullanıcının bilgilerini al
        guard let currentUser = Auth.auth().currentUser,
              let currentUserEmail = currentUser.email,
              let jobID = jobUid,
              let publisherEmail = jobPuplisher else {
            print("User information is not available.")
            return
        }
        
        // Firestore koleksiyonunu oluştur
        let applicationsCollection = Firestore.firestore().collection("applications")
        
        // Başvuruyu geri almak için filtreleme yap
        let query = applicationsCollection
            .whereField("applicantEmail", isEqualTo: currentUserEmail)
            .whereField("jobID", isEqualTo: jobID)
            .whereField("publisherEmail", isEqualTo: publisherEmail)
        
        query.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error checking application status: \(error.localizedDescription)")
                return
            }
            
            // Başvuru varsa
            if let documents = snapshot?.documents, !documents.isEmpty {
                self.takeBackApplicationButton.isHidden = false
                print("User has applied for this job :)))).")
                
            } else {
                self.takeBackApplicationButton.isHidden = true
                print("User has not applied for this job :(((((")
            }
        }
    }
    
    
    func selfCheck() -> Bool {
        if let currentUser = Auth.auth().currentUser,
           let currentUserEmail = currentUser.email,
           let publisherEmail = self.jobPuplisher,
           currentUserEmail == publisherEmail {
            // Kullanıcı kendi ilanına başvuruyorsa uyarı mesajını göster
            let alertController = UIAlertController(title: "Hata", message: "Kendi ilanınıza başvuruda bulunamazsınız.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return true
        }
        return false
    }
    
    
    func checkIfJobIsYours() {
        if let currentUser = Auth.auth().currentUser,
           let currentUserEmail = currentUser.email,
           let jobId = self.jobUid {
            
            // Firestore koleksiyonunu referans al
            let givenJobsCollection = Firestore.firestore().collection("givenJobs")
            
            // Veritabanında eşleşen dökümanları kontrol et
            givenJobsCollection.whereField("applicantEmail", isEqualTo: currentUserEmail)
                .whereField("jobUid", isEqualTo: jobId) // uidLabel.text değeri ile kontrol edildi
                .getDocuments { (snapshot, error) in
                    if let error = error {
                        print("Error checking given jobs: \(error.localizedDescription)")
                    } else if let snapshot = snapshot, !snapshot.documents.isEmpty {
                        // Eğer eşleşen döküman varsa, iş kullanıcının
                        self.jobIsYoursLabel.isHidden = false
                    }
                }
        }
    }
}


extension UIViewController {
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?()
        }))
        present(alert, animated: true, completion: nil)
    }
}
