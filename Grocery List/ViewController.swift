//
//  ViewController.swift
//  Grocery List
//
//  Created by Aashana on 11/6/17.
//  Copyright © 2017 Aashana. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var addList : UIButton!
    
    @IBOutlet var listName : UITableView!
    
    let cellReuseIdentifier = "ListNameTableViewCell"
    var listNames : [String]!

    override func viewDidLoad() {
        super.viewDidLoad()
        addList.layer.cornerRadius = 10
        addList.layer.borderWidth = 1
        addList.layer.borderColor = UIColor.black.cgColor
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        listNames = [String]()
        
        retrievedata()
    }
   
    @IBAction func addList(sender : UIButton!)
    {
        let listItemsViewController = self.storyboard?.instantiateViewController(withIdentifier: "ListItemsViewController") as! ListItemsViewController
       
        self.navigationController?.pushViewController(listItemsViewController, animated: true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listNames.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:ListNameTableViewCell = self.listName.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! ListNameTableViewCell
        cell.name.setTitle(listNames[indexPath.row], for: .normal)
        
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if (editingStyle == UITableViewCellEditingStyle.delete)
        {
            // handle delete (by removing the data from your array and updating the tableview)
            listNames.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            deleteData(id : indexPath.row+1)
        }
    }
    func retrievedata()
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let request:NSFetchRequest<List>
        request = NSFetchRequest<List>(entityName: "List")
        do
        {
            let entities = try appDelegate.managedObjectContext?.fetch(request)
            for item in entities!
            {
                for key in item.entity.attributesByName.keys
                {
                    if key == "name"
                    {
                        var value: Any? = item.value(forKey: key)
                        listNames.append("\(value!)")
                        print(item.value(forKey: "id"))
                    }
                }
            }
           self.listName.reloadData()
        }catch{
            print("Unable to retrieve data")
        }
    }
    @IBAction func onClickItem(sender : UIButton)
    {
        let listItemsViewController = self.storyboard?.instantiateViewController(withIdentifier: "ListItemsViewController") as! ListItemsViewController
        listItemsViewController.name = sender.currentTitle!
        self.navigationController?.pushViewController(listItemsViewController, animated: true)
    }
    func deleteData(id : Int)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let requestList:NSFetchRequest<List>
        requestList = NSFetchRequest<List>(entityName: "List")
        let requestItems:NSFetchRequest<Items>
        requestItems = NSFetchRequest<Items>(entityName: "Items")
        do
        {
            let entities = try appDelegate.managedObjectContext?.fetch(requestList)
            let context = appDelegate.managedObjectContext
            for item in entities!
            {
                for key in item.entity.attributesByName.keys
                {
                    if key == "id"  && item.value(forKey: key) as? Int! == id
                    {
                        context?.delete(item)
                    }
                }
            }
            do {
                try context?.save()
                print("saved!")
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
        }catch{
            print("Unable to retrieve data")
        }
        do
        {
            let entities = try appDelegate.managedObjectContext?.fetch(requestItems)
            let context = appDelegate.managedObjectContext
            for item in entities!
            {
                for key in item.entity.attributesByName.keys
                {
                    if key == "id" && item.value(forKey: key) as? Int! == id
                    {
                        context?.delete(item)
                    }
                }
            }
            do {
                try context?.save()
                print("saved!")
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
            self.listName.reloadData()
        }catch{
            print("Unable to retrieve data")
        }
        updateID()
    }
    func updateID()
    {
        var newID = 1
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let requestList:NSFetchRequest<List>
        requestList = NSFetchRequest<List>(entityName: "List")
        let requestItems:NSFetchRequest<Items>
        requestItems = NSFetchRequest<Items>(entityName: "Items")
        do
        {
            let entities = try appDelegate.managedObjectContext?.fetch(requestItems)
            let context = appDelegate.managedObjectContext
            for item in entities!
            {
                for key in item.entity.attributesByName.keys
                {
                    if key == "id"
                    {
                        item.id = Int16(newID)
                        newID += 1
                    }
                }
            }
            do {
                try context?.save()
                print("saved!")
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
        }catch{
            print("Unable to retrieve data")
        }
        newID = 1
        do
        {
            let entities = try appDelegate.managedObjectContext?.fetch(requestList)
            let context = appDelegate.managedObjectContext
            for item in entities!
            {
                for key in item.entity.attributesByName.keys
                {
                    if key == "id"
                    {
                        item.id = Int16(newID)
                        newID += 1
                    }
                }
            }
            do {
                try context?.save()
                print("saved!")
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
        }catch{
            print("Unable to retrieve data")
        }
    }
}
  


