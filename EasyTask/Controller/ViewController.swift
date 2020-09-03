//
//  ViewController.swift
//  EasyTask
//
//  Created by Denny Alfath on 02/09/20.
//  Copyright © 2020 Denny Alfath. All rights reserved.
//

import UIKit
import CoreData

struct TaskModel{
    let title: String
    let done: Bool
}

class ViewController: UIViewController {
    
    @IBOutlet weak var taskListTableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var tasks = [Task]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskListTableView.delegate = self
        taskListTableView.dataSource = self
        
        loadTaskList()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        LoginManager.checkUserAuth { (authState) in
            switch authState {
            case .undefined:
                let controller = LoginViewController()
                controller.modalPresentationStyle = .fullScreen
                controller.delegate = self
                self.present(controller, animated: true, completion: nil)
            case .signedOut:
                let controller = LoginViewController()
                controller.modalPresentationStyle = .fullScreen
                controller.delegate = self
                self.present(controller, animated: true, completion: nil)
            case .signedIn:
                print("Signed in")
            }
        }
    }
    
    func loadTaskList() {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        do {
            tasks = try context.fetch(request)
        } catch {
            print("Error retrieving data\(error)")
        }
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Task", message: "", preferredStyle: .alert)

        alert.addTextField(configurationHandler: {tf in
            tf.placeholder = "Task Title"
        })
        
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { action in
            
            // check if the textfield is empty
            if alert.textFields![0].text!.isEmpty {
                let warning = UIAlertController(title: "Warning", message: "Fill the textfields", preferredStyle: .alert)
                warning.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self.present(warning, animated: true)
            }else{
                // call create method that i've created before
                self.create(alert.textFields![0].text!, false)
                
                let success = UIAlertController(title: "Success", message: "Data user added", preferredStyle: .alert)
                success.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self.present(success, animated: true)
                
                // refresh data on tableUser
                self.taskListTableView.reloadData()
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    func create(_ title: String, _ done: Bool) {
        
        // referensi ke AppDelegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        // managed context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // referensi entity yang telah dibuat sebelumnya
        let taskEntity = NSEntityDescription.entity(forEntityName: "Task", in: managedContext)
        
        // entity body
        let insert = NSManagedObject(entity: taskEntity!, insertInto: managedContext)
        insert.setValue(title, forKey: "title")
        insert.setValue(done, forKey: "done")
        
        do {
            // save data ke entity user core data
            try managedContext.save()
        } catch let err{
            print(err)
        }
    }
    
    // fungsi refrieve semua data
    func retrieve() -> [TaskModel]{
        
        var tasks = [TaskModel]()
        
        // referensi ke AppDelegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // managed context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // fetch data
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        
        do {
            let result = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            
            result.forEach { user in
                tasks.append (
                    TaskModel(
                        title: user.value(forKey: "fname") as! String,
                        done: user.value(forKey: "lname") as! Bool
                    )
                )
            }
        } catch let err{
            print(err)
        }
        
        return tasks
        
    }
}

extension ViewController: LoginViewControllerDelegate {
    func didFinishAuth() {
        let alertController = UIAlertController(title: "Welcome to EasyTask", message: "Hello!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel) { (_) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListCell", for: indexPath)
        cell.textLabel?.text = tasks[indexPath.row].title
        return cell
    }
}

