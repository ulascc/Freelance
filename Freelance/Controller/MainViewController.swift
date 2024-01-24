//"
//  applicationsViewController.swift
//  Freelance
//
//  Created by umutcancicek on 23.12.2023. ?
//


import UIKit
import FirebaseFirestore
import Firebase

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var jobsTableView: UITableView!
    @IBOutlet weak var filterImageView: UIImageView!
    @IBOutlet weak var citySwitch: UISwitch!
    
    
    var jobs: [Job] = []
    var refreshControl = UIRefreshControl()
    
    var selectedCategory: String? // Seçilen kategoriyi saklamak için değişken
    
    // Picker View için veri kaynağı
    let categoriesPickerView = UIPickerView()
    let categories = Categories.categories
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        jobsTableView.dataSource = self
        jobsTableView.delegate = self
        
        // Tableview'ın kenar boşluklarını ayarla
        jobsTableView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        jobsTableView.register(UINib(nibName: "JobCell", bundle: nil), forCellReuseIdentifier: "JobCell")
        
        // UIRefreshControl ekleyin
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        jobsTableView.addSubview(refreshControl)
        
        // Firestore'dan verileri çekin
        fetchFirestoreData()
        
        // Picker View ayarları
        categoriesPickerView.delegate = self
        categoriesPickerView.dataSource = self
        
        // Kategori seçimi için TextField'a tıklanılabilirlik özelliği ekle
        filterImageView.isUserInteractionEnabled = true
        filterImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showCategoriesPicker)))
        
        citySwitch.isOn = false
    }
    
    @objc func refreshData() {
        // Firestore'dan verileri çekin
        fetchFirestoreData()
    }
    
    func fetchFirestoreData() {
        let db = Firestore.firestore()
        
        db.collection("jobs").getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Veri çekme hatası: \(error.localizedDescription)")
                // Kullanıcıya hata mesajı gösterme veya başka bir işlem yapma
            } else {
                // Verileri çekme başarılı.
                if let documents = snapshot?.documents {
                    self.jobs = documents.compactMap { document in
                        let documentID = document.documentID
                        let data = document.data()
                        let title = data["title"] as? String ?? ""
                        let category = data["category"] as? String ?? ""
                        let city = data["city"] as? String ?? ""
                        let explanation = data["explanation"] as? String ?? ""
                        let price = data["price"] as? String ?? ""
                        let publisher = data["publisher"] as? String ?? ""
                        let status = data["status"] as? String ?? ""
                        let imageURLField = data["imageURLField"] as? String ?? "" // Yeni eklenen fotoğraf URL'si alanı
                        return Job(publisher: publisher, title: title, explanation: explanation, price: price, category: category, city: city, uid: documentID, status: status, imageURL: imageURLField)
                    }
                    // Verileri kontrol et
                    print("Jobs Dizisi: \(self.jobs)")
                    
                    // TableView'ı güncelle
                    self.jobsTableView.reloadData()
                }
            }
            
            // Yenileme işlemi tamamlandığında refreshControl'ü durdur
            self.refreshControl.endRefreshing()
        }
    }
    
    
    @IBAction func citySwitchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            // Eğer switch aktifse, kullanıcının emailini al
            if let userEmail = Auth.auth().currentUser?.email {
                // Firestore sorgusu: Kullanıcıları emailine göre filtrele
                let db = Firestore.firestore()
                db.collection("users").whereField("email", isEqualTo: userEmail).getDocuments { [weak self] (snapshot, error) in
                    guard let self = self else { return }
                    
                    if let error = error {
                        print("Veri çekme hatası: \(error.localizedDescription)")
                        // Hata durumunda kullanıcıya bilgi verme veya başka bir işlem yapma
                    } else {
                        // Verileri çekme başarılı
                        if let document = snapshot?.documents.first {
                            // Email eşleşen kullanıcının city bilgisini al
                            let userCity = document["city"] as? String ?? ""
                            
                            // Firestore'dan city bilgisi alındı, şimdi jobs tablosunu bu bilgiye göre filtreleyerek verileri çek
                            if !userCity.isEmpty {
                                self.fetchFirestoreDataWithCity(withCity: userCity)
                            }
                        }
                    }
                }
            }
        } else {
            // Eğer switch kapalıysa, tüm verileri çek
            fetchFirestoreData()
        }
    }
    
    
    func fetchFirestoreDataWithCity(withCity city: String) {
        let db = Firestore.firestore()
        
        db.collection("jobs").whereField("city", isEqualTo: city).getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Veri çekme hatası: \(error.localizedDescription)")
                // Hata durumunda kullanıcıya bilgi verme veya başka bir işlem yapma
            } else {
                // Verileri çekme başarılı.
                if let documents = snapshot?.documents {
                    self.jobs = documents.compactMap { document in
                        let documentID = document.documentID
                        let data = document.data()
                        let title = data["title"] as? String ?? ""
                        let category = data["category"] as? String ?? ""
                        let city = data["city"] as? String ?? ""
                        let explanation = data["explanation"] as? String ?? ""
                        let price = data["price"] as? String ?? ""
                        let publisher = data["publisher"] as? String ?? ""
                        let status = data["status"] as? String ?? ""
                        let imageURLField = data["imageURLField"] as? String ?? "" // Yeni eklenen fotoğraf URL'si alanı
                        return Job(publisher: publisher, title: title, explanation: explanation, price: price, category: category, city: city, uid: documentID, status: status, imageURL: imageURLField)
                    }
                    self.jobsTableView.reloadData()
                }
            }
        }
    }

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jobs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // "JobCell" olarak tanımlanan hücreyi kullan
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobCell", for: indexPath) as! JobCell
        
        let job = jobs[indexPath.row]
        
        // JobCell içindeki IBOutlet'leri kullanarak verileri ayarla
        cell.jobTitle.text = job.title
        cell.jobExplanation.text = job.explanation
        cell.jobPrice.text = "\(job.price) TL"
        cell.jobCity.text = job.city
        cell.jobUid.text = job.uid
        
        cell.jobUid.isHidden = true
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130.0 // Örnek olarak 80 birim mesafe belirlendi, siz istediğiniz değeri kullanabilirsiniz.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Seçili hücrenin seçimini kaldır
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Storyboard üzerinde tanımladığınız segue'yi çalıştırın
        performSegue(withIdentifier: "JobDetailSegue", sender: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: [])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: [])
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "JobDetailSegue" {
            // Hedef view controller'ı alın
            if let destinationVC = segue.destination as? JobDetailViewController {
                // IndexPath'ten seçilen işi alın
                if let selectedRow = sender as? Int {
                    // Seçilen işi JobDetailViewController'a iletmek için gerekli bilgileri alın
                    let selectedJob = jobs[selectedRow]
                    print("Selected Job: \(selectedJob)")
                    
                    // JobDetailViewController'ın IBOutlet'lerine değerleri atayın
                    destinationVC.jobTitle = selectedJob.title
                    destinationVC.jobExplanation = selectedJob.explanation
                    destinationVC.jobPuplisher = selectedJob.publisher
                    destinationVC.jobPrice = "\(selectedJob.price) TL"
                    destinationVC.jobCategory = selectedJob.category
                    destinationVC.jobCity = selectedJob.city
                    destinationVC.jobUid = selectedJob.uid
                }
            }
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Yatay kaydırmayı kontrol et
        if scrollView.contentOffset.x != 0 {
            scrollView.contentOffset.x = 0
        }
    }
    
    @objc func showCategoriesPicker() {
        // Kategori seçimi için Picker View'i göster
        let alert = UIAlertController(title: "\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
        categoriesPickerView.frame = CGRect(x: 0, y: 0, width: alert.view.frame.width - 20, height: 160)
        categoriesPickerView.center = CGPoint(x: alert.view.frame.width / 2, y: categoriesPickerView.center.y)
        
        alert.view.addSubview(categoriesPickerView)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    func fetchFirestoreData(withCategory category: String) {
        let db = Firestore.firestore()
        
        db.collection("jobs").whereField("category", isEqualTo: category).getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Veri çekme hatası: \(error.localizedDescription)")
            } else {
                // Verileri çekme başarılı.
                if let documents = snapshot?.documents {
                    self.jobs = documents.compactMap { document in
                        let documentID = document.documentID
                        let data = document.data()
                        let title = data["title"] as? String ?? ""
                        let category = data["category"] as? String ?? ""
                        let city = data["city"] as? String ?? ""
                        let explanation = data["explanation"] as? String ?? ""
                        let price = data["price"] as? String ?? ""
                        let publisher = data["publisher"] as? String ?? ""
                        let status = data["status"] as? String ?? ""
                        let imageURLField = data["imageURLField"] as? String ?? "" // Yeni eklenen fotoğraf URL'si alanı
                        return Job(publisher: publisher, title: title, explanation: explanation, price: price, category: category, city: city, uid: documentID, status: status, imageURL: imageURLField)
                    }
                    self.jobsTableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - UIPickerViewDelegate & UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Seçilen kategoriyi güncelle
        selectedCategory = categories[row]
        
        // Firestore'dan verileri seçilen kategoriye göre çekin
        if let selectedCategory = selectedCategory {
            fetchFirestoreData(withCategory: selectedCategory)
        }
        
        // Picker View'i kapat
        dismiss(animated: true, completion: nil)
    }
    
    
}
