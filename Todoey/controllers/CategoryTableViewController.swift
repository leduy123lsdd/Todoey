//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Lê Duy on 7/1/19.
//  Copyright © 2019 Lê Duy. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryTableViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var categories: Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set bar title
        self.navigationItem.title = "Category Items"
        //self.navigationController?.navigationBar.barTintColor = UIColor(hexString: randomColor())
        
        loadCategory()
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .singleLine
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        // get color of category
//        if let currentCategory = categories?[indexPath.row] {
//            let color : UIColor = UIColor(hexString: currentCategory.color) ?? UIColor(hexString: "1D9BF6")!
//            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
//        }
        
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No categories added yet"
        cell.backgroundColor = UIColor(hexString: categories?[indexPath.row].color ?? "1D9BF6")
        
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
//            newCategory.color = RandomFlatColor().hexValue()
            newCategory.color = self.randomColor()
            self.save(category: newCategory)
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true,completion: nil)
    }
    
    //Random color
    func randomColor() -> String {
        
        let colors = [UIColor.flatRed.hexValue(),
                      UIColor.flatOrange.hexValue(),
                      UIColor.flatYellow.hexValue(),
                      UIColor.flatGreen.hexValue(),
                      UIColor.flatPink.hexValue(),
                      UIColor.flatLime.hexValue(),
                      UIColor.flatWatermelon.hexValue()]
        
        let pickColor = colors[Int.random(in: 0..<colors.count)]
        return pickColor
    }
    
}

