//
//  ViewController.swift
//  travelBook
//
//  Created by Seçkin Denli on 16.02.2020.
//  Copyright © 2020 Seçkin Denli. All rights reserved.
//

import UIKit
import CoreData
class ViewController: UIViewController ,UITableViewDelegate ,UITableViewDataSource {
   
   var nameArray = [String]()
    var idArray = [UUID]()
    var chosenTitle = ""
    var chosenID = UUID ()
    
    
    
    
    
 

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(segue))
        
        
        getData()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newData"), object: nil)
    }
    
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return nameArray.count
      }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC"{
            let destination = segue.destination as! DetailsVC
            destination.selectedTitle = chosenTitle
            destination.selectedID = chosenID
            
            
            
            
        }
    }
    
    
      func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenTitle = nameArray[indexPath.row]
        chosenID = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
       
      }
    @objc func segue () { performSegue(withIdentifier: "toDetailsVC", sender: nil)
        chosenTitle = ""
    }
    // FetchRequests for delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            
            let idString = idArray[indexPath.row].uuidString
            
            request.predicate = NSPredicate(format: "id = %@", idString)
            
            request.returnsObjectsAsFaults = false
            
            
            
            do {
            let results = try context.fetch(request)
                if results.count > 0{
                    for result in results as! [NSManagedObject]{
                        
                        if let id = result.value(forKey: "id") as? UUID{
                            
                            if id == idArray[indexPath.row]{
                                
                                
                                context.delete(result)
                                nameArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                tableView.reloadData()
                               
                                do {
                                    try context.save()
                                } catch  {
                                    print("error")
                                }
                                
                                
                    
                            }
                            
                        }
                      
            }
            }
            } catch  {
                print("error")
            }
        }
    }
    
    

    //appDelegate & fetchProcess

    @objc func getData () {
        
        
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        
        fetchRequest.returnsObjectsAsFaults = false
        
        
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 0 { self.nameArray.removeAll(keepingCapacity: false)
            
                nameArray.removeAll(keepingCapacity: false)
                idArray.removeAll(keepingCapacity: false)
                
                for result in results as! [NSManagedObject]{
                if let name = result.value(forKey: "title") as? String {
                 nameArray.append(name)
                
                }
                if let id = result.value(forKey: "id") as? UUID {
                    idArray.append(id)
                }
                
                
                }
                self.tableView.reloadData()
            }
        } catch  {
            print("error")
        }
       
    }


}

