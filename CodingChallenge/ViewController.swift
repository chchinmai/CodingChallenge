//
//  ViewController.swift
//  CodingChallenge
//
//  Created by chinmai swaraj on 26/4/2023.
//

import UIKit
import Alamofire

struct Person {
    let title: String
    let callTime : String
    let lastUpdated : String
    let id : String
    let latitude : Double
    let longitude : Double
    let description : String?
    let location : String
    let status : String
    let type : String
    let typeIcon : String
}

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var people = [Person]()
    let cellReuseIdentifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        title = "Incidents"
        
        //Register the table view cell class and its reuse id
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        self.tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
        
        let uploadButton = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(uploadHandler))
        self.navigationItem.setRightBarButton(uploadButton, animated: false)
        
        
        let url = "https://run.mocky.io/v3/5e90b420-388e-4913-b240-b5326823212c"

        AF.request(url).responseJSON { response in
                    switch response.result {
                    case .success(let data):
                        if let jsonArray = data as? [[String: Any]] {
                            self.people = jsonArray.map { json in
                                return Person(
                                    title: json["title"] as! String,
                                    callTime: json["callTime"] as! String,
                                    lastUpdated: json["lastUpdated"] as! String,
                                    id: json["id"] as! String,
                                    latitude: json["latitude"] as! Double,
                                    longitude: json["longitude"] as! Double,
                                    description: json["description"] as? String,
                                    location: json["location"] as! String,
                                    status: json["status"] as! String,
                                    type: json["type"] as! String,
                                    typeIcon: json["typeIcon"] as! String
                                )
                            }
                            print("People",self.people)
                        }
                        self.tableView.reloadData()
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
        
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        

    }
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        // Fetch new data or reload existing data here
        // Once the data has been loaded or reloaded, end the refreshing by calling:
        // refreshControl.endRefreshing()
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    //Filter Function
    @objc func uploadHandler(){
        showAlertAction(title: "Call Time", message: "Filter")
    }
    //Alert to select from options and filter
    func showAlertAction(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Asscending", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
            print("Action")
            self.people.sort(by: { $0.callTime < $1.callTime })
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Descending", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
            print("Action")
            self.people.sort(by: { $0.callTime > $1.callTime })
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? SecondViewController,
           let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.myStruct = people[indexPath.row]
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:TableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! TableViewCell
        
        cell.titleValue?.text = people[indexPath.row].title
        cell.titleValue?.font = UIFont.boldSystemFont(ofSize: 17)
        let status_color = people[indexPath.row].status
        switch status_color {
        case "Under control" :
            cell.statusValue.backgroundColor = UIColor.green
        case "On Scene" :
            cell.statusValue.backgroundColor = UIColor.blue
        case "Out of control" :
            cell.statusValue.backgroundColor = UIColor.red
        case "Pending" :
            cell.statusValue.backgroundColor = UIColor.orange
        default:
            cell.statusValue.backgroundColor = UIColor.white
        }
        cell.statusValue.textColor = UIColor.white
        cell.statusValue?.text = status_color
        
        let pngUrlString = people[indexPath.row].typeIcon

        // Create a URL object from the URL string
        if let url = URL(string: pngUrlString) {
            // Create a data task to fetch the image data from the URL
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                // Check for errors and non-nil data
                guard let data = data, error == nil else {
                    print("Error fetching image data: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                // Create a UIImage object from the data
                let image = UIImage(data: data)

                // Update the UIImageView on the main thread
                DispatchQueue.main.async {
                    // Assign the UIImage to the UIImageView to display the image
                    cell.typeIconValue.image = image
                }
            }

            // Start the data task
            task.resume()
        }
        
        // Create a DateFormatter to parse the date string
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

        // Parse the date string into a Date object
        if let date = inputFormatter.date(from: people[indexPath.row].callTime) {
            // Create another DateFormatter to format the Date object into the desired string format
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "MMM d, yyyy h:mm a"
            outputFormatter.timeZone = TimeZone.current

            // Format the Date object into a string
            let dateString = outputFormatter.string(from: date)

            // Set the formatted string as the text of a label
            cell.callTimeValue?.text = dateString
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        performSegue(withIdentifier: "showDetails", sender: self)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0;//Choose your custom row height
    }


}

