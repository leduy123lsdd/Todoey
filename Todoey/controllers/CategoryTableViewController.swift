//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Lê Duy on 7/1/19.
//  Copyright © 2019 Lê Duy. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryTableViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var categories: Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set bar title
        self.navigationItem.title = "Category Items"
        
        loadCategory()
        tableView.rowHeight = 80.0
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No categories added yet"

        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories?.count ?? 1
    }
    
    //MARK: - Table view delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItem", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    //MARK: - Data Manipulation methods
    func loadCategory() {
        categories = realm.objects(Category.self)
        
        self.tableView.reloadData()
    }
    
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        }
        catch {
            print("Error saving context")
        }
        
        self.tableView.reloadData()
    }
    
    override func swipeDelete(index: IndexPath) {
        super.swipeDelete(index: index)
        if let currentCategory = categories?[index.row] {
            do {
                try realm.write {
                    realm.delete(currentCategory)
                }
            }
            catch {
                print("Error swipe delete category: \(error)")
            }
            tableView.reloadData()
        }
    }
    
    
    //MARK: - add button pressed
    @IBAction func barButtonPressed(_ sender: Any) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new category item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add category", style: .default) { (action) in
            //what will happen when user clicks Add item button
            let newCategory = Category()
            
            newCategory.name = textField.text!
            self.save(category: newCategory)
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true,completion: nil)
    }
    
}

