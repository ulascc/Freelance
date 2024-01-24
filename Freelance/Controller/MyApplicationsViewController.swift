import UIKit
import Firebase

class MyApplicationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {

    @IBOutlet weak var myApplicationsTableView: UITableView!
    @IBOutlet weak var appliedJobIsEmptyLabel: UILabel!
    
    var jobs: [Job] = []
    var refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        myApplicationsTableView.dataSource = self
        myApplicationsTableView.delegate = self
        myApplicationsTableView.register(UINib(nibName: "JobCell", bundle: nil), forCellReuseIdentifier: "JobCell")

        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        myApplicationsTableView.addSubview(refreshControl)
        
        fetchMyApplicants()
    }
    
    @objc func refreshData() {
        // Firestore'dan verileri çekin
        fetchMyApplicants()
    }

    func fetchMyApplicants() {
        if let currentUser = Auth.auth().currentUser {
            let userEmail = currentUser.email ?? ""

            // Firestore referansını al
            let db = Firestore.firestore()

            // "applications" koleksiyonunu referans al
            let applicationsRef = db.collection("applications")

            // Kullanıcının e-posta adresine göre sorgu yap
            applicationsRef.whereField("applicantEmail", isEqualTo: userEmail).getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error.localizedDescription)")
                } else {
                    // Sorgu sonuçları
                    for document in querySnapshot!.documents {
                        let data = document.data()

                        // İlgili verileri kullanarak işlemleri gerçekleştir (örneğin, yazdır)
                        print("Document ID: \(document.documentID), Data: \(data)")

                        // JobID'yi al
                        if let jobID = data["jobID"] as? String {
                            // Jobs koleksiyonundan ilgili jobID'ye sahip dokümanı al
                            let jobRef = db.collection("jobs").document(jobID)
                            jobRef.getDocument { (jobDocument, jobError) in
                                if let jobError = jobError {
                                    print("Error getting job document: \(jobError.localizedDescription)")
                                } else if let jobData = jobDocument?.data() {
                                    // İlgili işin detaylarına ulaş
                                    print("Job Details for Job ID \(jobID): \(jobData)")

                                    // Job modelini oluştur ve jobs dizisine ekle
                                    let job = Job(
                                        publisher: jobData["publisher"] as? String ?? "",
                                        title: jobData["title"] as? String ?? "",
                                        explanation: jobData["explanation"] as? String ?? "",
                                        price: jobData["price"] as? String ?? "",
                                        category: jobData["category"] as? String ?? "",
                                        city: jobData["city"] as? String ?? "",
                                        uid: jobDocument?.documentID ?? "",
                                        status: jobData["status"] as? String ?? "",
                                        imageURL: jobData["imageURLField"] as? String ?? ""
                                    )

                                    self.jobs.append(job)

                                    // TableView'ı güncelle
                                    DispatchQueue.main.async {
                                        self.myApplicationsTableView.reloadData()
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
        if jobs.isEmpty {
            appliedJobIsEmptyLabel.isHidden = false
        } else {
            appliedJobIsEmptyLabel.isHidden = true
        }
        return jobs.count
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobCell", for: indexPath) as! JobCell

        
        let job = jobs[indexPath.row]
        cell.jobTitle.text = job.title
        cell.jobExplanation.text = job.explanation
        cell.jobPrice.text = job.price
        cell.jobCity.text = job.city
        cell.jobUid.text = job.uid
        
        cell.jobUid.isHidden = true

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Seçili hücrenin seçimini kaldır
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Storyboard üzerinde tanımladığınız segue'yi çalıştırın
        performSegue(withIdentifier: "myApplicationsDetailSegue", sender: indexPath.row)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130.0 
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Yatay kaydırmayı kontrol et
        if scrollView.contentOffset.x != 0 {
            scrollView.contentOffset.x = 0
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "myApplicationsDetailSegue" {
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
    
}
