//
//  ViewController.swift
//  NamesCoreData
//
//  Created by Zain Ahmed on 9/19/21.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    // The Table will run on this Array
    // NSManagedObject: Generic data type that stores properties with CoreData
   
    var people: [NSManagedObject] = []
    
  
     
    
    // Reference to the CoreData Persistent Container through the App Delegate File
    // (UIApplication.shared.delegate as! AppDelegate) <- is the object of AppDelegate file
    
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        title = "Students" // Changes the title of the Navigation Bar
        fetchContents()   // Fetches the contents of CoreData Container (see function below)
    }
    
    // Create alert, save the names into persistance container via CoreData
    @IBAction func addName(_ sender: Any) {
        
        // Labels in Alert
        let alert = UIAlertController(title: "New Name", message: "Add a new name", preferredStyle: .alert)
        
        // Save button on Alert
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] action in
            // ---- Run this closure when save button is pressed -----
            
            guard let textField = alert.textFields?.first else {return}
            guard let nameToSave = textField.text else {return}
            
            guard let textfields = alert.textFields?.last else {return}
            guard let ageToSave = textfields.text else {return}
           
            // Call save method to save the name into persistence container
            saveName(nameToSave: nameToSave,ageToSave: ageToSave)
           
           
            self.tableView.reloadData()
        }
        // Cancel button on Alert
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addTextField()
        alert.addTextField()

        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
        
    }
    
    // Method we made to save contents into Persistant Container
    func saveName(nameToSave: String, ageToSave:String){
        // Object of the entity we are using.
        // Entity is like a class in CoreData.
        // You will find it in the xcdatamodel file
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: managedContext)!
        // Object of the attribute inside entity.
        //Attribute is like a property in CoreData.
        let person = NSManagedObject(entity: entity, insertInto: managedContext)
        // Saves the name inside persistant container.
        person.setValue(nameToSave, forKey: "name")
        person.setValue(ageToSave, forKey: "age")
        
        people.append(person)
        // Appends the array we are using to update Table
        
        
        
        saveContext() // ALWAYS call save whenever you make changes in CoreData
    }
    
    // Will bring all the contents from Persistant Container
    func fetchContents() {
        
        // create a fetch request
        let fetchRrequest : NSFetchRequest<Person>
            fetchRrequest = Person.fetchRequest()
        
        do{
            
             people = try managedContext.fetch(fetchRrequest)
            
        }catch (let error as NSError){
            print("could not save.\(error)")
        }
        
        
        
//       //  Create a fetch request using entity name
//        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
//
//        do {
//           //  Try to fetch the data from the fetch request we created above
//            people = try managedContext.fetch(fetchRequest)
//        } catch (let error as NSError) {
//         //    If failed, handle error
//            print("Could not save. \(error)")
//         }
    }
    
    // Tries to save the data into Persistant Container
    // This should always be called whenever we make a change in persistant container
    func saveContext() {
        do {
            // Using refrence to the persistent container, call the save method.
            try managedContext.save()
        } catch let error as NSError {
            // If could not save, handle the error
            print("Could not save. \(error)")
        }
    }
        
}

// Table extension
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell") as! TableCell
       
        let currentName = people[indexPath.row]
      //  let currentAge = age[indexPath.row]
      
        // Downcast name from NSManagedObject to String and display it in label.
        
        cell.cellLabel.text = currentName.value(forKey: "name") as? String
        cell.showAge.text = currentName.value(forKey: "age") as? String
       
        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Go inside persistant container and delete this element
       
        managedContext.delete(people[indexPath.row])
        
        // Since we deleted something inside persistent container, call save context.
       
        saveContext()
        tableView.reloadData()
    }
}

