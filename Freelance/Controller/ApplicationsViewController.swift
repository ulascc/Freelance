//
//  applicationsViewController.swift
//  Freelance
//
//  Created by umutcancicek on 23.12.2023.
//

import UIKit
import Firebase

class ApplicationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {

    @IBOutlet weak var applicationsTableView: UITableView!

    var jobs: [Job] = []
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("this is application screen")
        
        applicationsTableView.delegate = self
        applicationsTableView.dataSource = self
        applicationsTableView.register(UINib(nibName: "JobCell", bundle: nil), forCellReuseIdentifier: "JobCell")

        
        // UIRefreshControl ekleyin
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        applicationsTableView.addSubview(refreshControl)
        
        // Firestore'dan verileri çekme işlemi
        fetchJobsFromFirebase()
    }
    
    @objc func refreshData() {
        // Firestore'dan verileri çekin
        fetchJobsFromFirebase()
    }
    
    func fetchJobsFromFirebase() {
        // Oturum açmış kullanıcının bilgilerini al
        if let currentUser = Auth.auth().currentUser {
            let userEmail = currentUser.email ?? ""
            
            let db = Firestore.firestore()

            db.collection("jobs").whereField("publisher", isEqualTo: userEmail).getDocuments { [weak self] (snapshot, error) in
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
                            return Job(publisher: publisher, title: title, explanation: explanation, price: price, category: category, city: city, uid: documentID, status: status)
                        }

                        // Verileri kontrol et
                        print("Jobs Dizisi: \(self.jobs)")

                        // TableView'ı güncelle
                        self.applicationsTableView.reloadData()
                    }
                }
                // Yenileme işlemi tamamlandığında refreshControl'ü durdur
                self.refreshControl.endRefreshing()
            }
        }
    }

    
    

    // MARK: - TableView DataSource Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jobs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobCell", for: indexPath) as! JobCell
        
        let job = jobs[indexPath.row]
        
        // JobCell içindeki IBOutlet'leri güncelleme
        cell.jobTitle.text = job.title
        cell.jobExplanation.text = job.explanation
        cell.jobPrice.text = "\(job.price) TL"
        cell.jobCity.text = job.city
        cell.jobUid.text = job.uid
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130.0 // Örnek olarak 80 birim mesafe belirlendi, siz istediğiniz değeri kullanabilirsiniz.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Seçili hücrenin seçimini kaldır
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Storyboard üzerinde tanımladığınız segue'yi çalıştırın
        performSegue(withIdentifier: "ApplicationDetailSegue", sender: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: [])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: [])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "ApplicationDetailSegue" {
                // Hedef view controller'ı alın
                if let destinationVC = segue.destination as? ApplicationDetailViewController {
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
    
}
