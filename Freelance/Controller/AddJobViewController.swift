//
//  AddJobViewController.swift
//  Freelance
//
//  Created by ulascancicek on 8.11.2023.
//

import UIKit
import Firebase
import FirebaseStorage

class AddJobViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var explanationTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    
    @IBOutlet weak var jobImage: UIImageView!
    let imageURLField = "imageURL"
    
    var categoryPickerView = UIPickerView()
    var cityPickerView = UIPickerView()
    
    let categories = Categories.categories
    let cities = Cities.cities
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.autocorrectionType = .no
        explanationTextField.autocorrectionType = .no
        priceTextField.autocorrectionType = .no
        categoryTextField.autocorrectionType = .no
        cityTextField.autocorrectionType = .no
        
        print("it is job adding page")
        
        categoryTextField.inputView = categoryPickerView
        cityTextField.inputView = cityPickerView
        
        categoryPickerView.delegate = self
        categoryPickerView.dataSource = self
        categoryPickerView.tag = 1
        
        cityPickerView.delegate = self
        cityPickerView.dataSource = self
        cityPickerView.tag = 2
        
        // UITapGestureRecognizer ekleyerek imageView'a tıklama olayını dinle
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        jobImage.addGestureRecognizer(tapGesture)
        jobImage.isUserInteractionEnabled = true
    }
    
    
    @IBAction func publisJopPressed(_ sender: UIButton) {
        guard let title = titleTextField.text, !title.isEmpty,
              let explanation = explanationTextField.text, !explanation.isEmpty,
              let price = priceTextField.text, !price.isEmpty,
              let category = categoryTextField.text, !category.isEmpty,
              let city = cityTextField.text, !city.isEmpty,
              let publisher = Auth.auth().currentUser?.email,
              let jobImage = jobImage.image else {
            // Eğer herhangi bir değer boşsa hata mesajı göster
            showAlert(message: "Lütfen tüm alanları doldurun.")
            return
        }
        
        // Resmi Firebase Storage'a yükle
        uploadImageToFirebaseStorage(image: jobImage) { (imageURL) in
            // Resmin yüklendiği Storage URL'ini aldıktan sonra Firestore'a kaydet
            self.saveJobDataToFirestore(
                publisher: publisher,
                title: title,
                explanation: explanation,
                price: price,
                category: category,
                city: city,
                imageURL: imageURL
            )
            
            // jobImage'i boş yap
            self.jobImage.image = UIImage(named: "photo")
            
            // Kayıt başarılı alert'i göster
            self.showAlert(message: "İş ilanı başarıyla yayınlandı.")
        }
    }
    
    
    func uploadImageToFirebaseStorage(image: UIImage, completion: @escaping (String) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        
        let imageID = UUID().uuidString
        let storageRef = Storage.storage().reference().child("job_images/\(imageID).jpg")
        
        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Error uploading image to Firebase Storage: \(error)")
            } else {
                // Resmin yüklendiği Storage URL'ini al
                storageRef.downloadURL { (url, error) in
                    if let downloadURL = url {
                        // URL'yi completion handler ile döndür
                        completion(downloadURL.absoluteString)
                    } else if let error = error {
                        print("Error getting download URL: \(error)")
                    }
                }
            }
        }
    }
    
    func saveJobDataToFirestore(publisher: String, title: String, explanation: String, price: String, category: String, city: String, imageURL: String) {
        // Firestore'a verileri kaydet
        db.collection("jobs").addDocument(data: [
            K.FStore.publisherField: publisher,
            K.FStore.titleField: title,
            K.FStore.explanationField: explanation,
            K.FStore.priceField: price,
            K.FStore.categoryField: category,
            K.FStore.cityField: city,
            K.FStore.imageURLField: imageURL,
            K.FStore.status: "pending"
        ]) { (error) in
            if let e = error {
                print("There was an issue saving data to Firestore: \(e)")
            } else {
                print("Successfully saved data to Firestore")
                DispatchQueue.main.async {
                    self.titleTextField.text = ""
                    self.explanationTextField.text = ""
                    self.priceTextField.text = ""
                    self.categoryTextField.text = ""
                    self.cityTextField.text = ""
                    self.jobImage.image = UIImage(systemName: "photo")
                }
            }
        }
    }
    
    // ImageView'a tıklanınca galeriyi açan fonksiyon
    @objc func imageViewTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    // Kullanıcı bir fotoğraf seçtikten sonra çağrılan delegate fonksiyon
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            jobImage.contentMode = .scaleAspectFit
            jobImage.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Uyarı", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}


extension AddJobViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag{
        case 1:
            return categories.count
        case 2:
            return cities.count
        default:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag{
        case 1:
            return categories[row]
        case 2:
            return cities[row]
        default:
            return "data not found"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag{
        case 1:
            categoryTextField.text = categories[row]
            categoryTextField.resignFirstResponder()
        case 2:
            cityTextField.text = cities[row]
            cityTextField.resignFirstResponder()
        default:
            return
        }
    }
}
