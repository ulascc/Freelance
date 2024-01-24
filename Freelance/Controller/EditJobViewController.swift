//
//  EditJobViewController.swift
//  Freelance
//
//  Created by ulascancicek on 24.01.2024.
//

import UIKit
import Firebase

class EditJobViewController: UIViewController {
    
    var jobTitle: String?
    var explanation: String?
    var category: String?
    var city: String?
    var price: String?
    var jobID: String?
    
    
    @IBOutlet weak var jobTitleTextField: UITextField!
    @IBOutlet weak var explanationTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var jobIDLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("This is an edit job screen")
        
        jobTitleTextField.text = jobTitle
        explanationTextField.text = explanation
        categoryTextField.text = category
        cityTextField.text = city
        priceTextField.text = price
        jobIDLabel.text = jobID
        
        jobIDLabel.isHidden = true
    }
    
    @IBAction func EditJobButtonPressed(_ sender: UIButton) {
        guard let jobID = jobIDLabel.text,
              let title = jobTitleTextField.text,
              let explanation = explanationTextField.text,
              let category = categoryTextField.text,
              let city = cityTextField.text,
              let price = priceTextField.text else {
            // Gerekli değerler boşsa işlem yapma
            return
        }
        
        let db = Firestore.firestore()
        let jobsCollection = db.collection("jobs")
        
        // Jobs koleksiyonunda belirli bir işi güncelle
        jobsCollection.document(jobID).updateData([
            "title": title,
            "explanation": explanation,
            "category": category,
            "city": city,
            "price": price
        ]) { (error) in
            if let error = error {
                // Hata durumunda UIAlertController kullanarak alert göster
                let alertController = UIAlertController(title: "Error", message: "Failed to update job. \(error.localizedDescription)", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                // Başarılı güncelleme durumunda UIAlertController kullanarak alert göster
                let alertController = UIAlertController(title: "Success", message: "Job updated successfully.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                    // OK'e basıldığında bir önceki ekrana dön
                    self.navigationController?.popViewController(animated: true)
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func DeleteJobButtonPressed(_ sender: UIButton) {
        // UIAlertController oluştur
        let alertController = UIAlertController(title: "Confirm Deletion", message: "Are you sure you want to delete this job?", preferredStyle: .alert)
        
        // Evet butonu ekle
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            // Silme işlemi
            if let jobID = self.jobIDLabel.text {
                let db = Firestore.firestore()
                let jobsCollection = db.collection("jobs")
                
                jobsCollection.document(jobID).delete { (error) in
                    if let error = error {
                        // Hata durumunda UIAlertController kullanarak alert göster
                        let errorAlert = UIAlertController(title: "Error", message: "Failed to delete job. \(error.localizedDescription)", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        errorAlert.addAction(okAction)
                        self.present(errorAlert, animated: true, completion: nil)
                    } else {
                        // Başarılı silme durumunda UIAlertController kullanarak alert göster
                        let successAlert = UIAlertController(title: "Success", message: "Job deleted successfully.", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                            // OK'e basıldığında bir önceki ekrana dön
                            self.navigationController?.popViewController(animated: true)
                        }
                        successAlert.addAction(okAction)
                        self.present(successAlert, animated: true, completion: nil)
                    }
                }
            }
        }
        
        // Hayır butonu ekle
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        
        // Butonları UIAlertController'a ekle
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        // UIAlertController'ı göster
        present(alertController, animated: true, completion: nil)
    }
}
