//
//  ViewController.swift
//  Todoey
//
//  Created by Lê Duy on 6/25/19.
//  Copyright © 2019 Lê Duy. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Layout design
        self.navigationItem.title = "List"
        
        // Load data from database
        
        loadItems()
        
    }
    
    //MARK: TableView Datasource Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        cell.accessoryType = (item.done == true ? .checkmark : .none)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    //MARK: TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        context.delete(itemArray[indexPath.row])
        
        itemArray.remove(at: indexPath.row)
        
//        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItem()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: Add new item
    @IBAction func addNewItem(_ sender: Any) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new todoey item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            //what will happen when user clicks Add item button
            let newItem = Item(context: self.context)
            
            newItem.title = textField.text!
            newItem.done  = false
            newItem.parentCategory = self.selectedCategory
            
            self.itemArray.append(newItem)
            self.saveItem()
        }

        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true,completion: nil)

    }
    
    //MARK: Control data model methods.
    private func saveItem() {
        do {
            try context.save()
        } catch {
            print("Error saving context")
        }
        self.tableView.reloadData()
    }
    
    private func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(),and predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,addtionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("error fetching data from context: \(error)")
        }
        self.tableView.reloadData()
    }


}

//MARK: Search bar methods
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        //defind how to query database
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        //sorting value
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, and: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            loadItems();
            //not editing anymore, keyboard and cursor should go away, disappear
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
}
