import UIKit
import Firebase

class MyApplicationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var myApplicationsTableView: UITableView!

    var jobs: [Job] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        myApplicationsTableView.dataSource = self
        myApplicationsTableView.delegate = self
        myApplicationsTableView.register(UINib(nibName: "JobCell", bundle: nil), forCellReuseIdentifier: "JobCell")

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
                                        uid: jobData["uid"] as? String ?? "",
                                        status: jobData["status"] as? String ?? ""
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

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130.0 
    }
    
}
