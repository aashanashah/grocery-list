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
    var listNames = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        addList.layer.cornerRadius = 10
        addList.layer.borderWidth = 1
        addList.layer.borderColor = UIColor.black.cgColor
    
        retrievedata()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                        let value: Any? = item.value(forKey: key)
                        listNames.append("\(value!)")
                    }
                }
            }
           self.listName.reloadData()
        }catch{
            print("Unable to retrieve data")
        }
    }

}

