//
//  AddJobViewController.swift
//  Freelance
//
//  Created by umutcancicek on 8.11.2023.
//

import UIKit
import Firebase

class AddJobViewController: UIViewController {

    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var explanationTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    
    
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
    }
    
    
    @IBAction func publisJopPressed(_ sender: UIButton) {
        if let title = titleTextField.text, let explanation = explanationTextField.text,
           let price = priceTextField.text, let category = categoryTextField.text,
           let city = cityTextField.text,
           let publisher = Auth.auth().currentUser?.email{
            db.collection("jobs").addDocument(
                data: [K.FStore.publisherField : publisher,
                       K.FStore.titleField : title,
                       K.FStore.explanationField : explanation,
                       K.FStore.priceField : price,
                       K.FStore.categoryField : category,
                       K.FStore.cityField : city,
                       K.FStore.status : "pending"
                      ]){
                          (error) in
                          if let e = error{
                              print("There was an issue saving data to firestore. \(e)")
                          }else{
                              print("succesfully saved data")
                              DispatchQueue.main.async {
                                  self.titleTextField.text = ""
                                  self.explanationTextField.text = ""
                                  self.priceTextField.text = ""
                                  self.categoryTextField.text = ""
                                  self.cityTextField.text = ""
                              }
                          }
                      }
        }
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
