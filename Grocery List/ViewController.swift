//
//  ViewController.swift
//  Grocery List
//
//  Created by Aashana on 11/6/17.
//  Copyright © 2017 Aashana. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import UserNotificationsUI
import CoreLocation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    @IBOutlet var addList : UIButton!
    @IBOutlet var arrowNav : UIImageView!
    @IBOutlet var listName : UITableView!
    
    let cellReuseIdentifier = "ListNameTableViewCell"
    var listNames : [String]!
    var places : [String]!
    var ids : [String]!
    var locationManager : CLLocationManager = CLLocationManager()
    var delete = 0
    let btn1 = UIButton(type: .custom)
    

    override func viewDidLoad()
    {
        super.viewDidLoad()
        addList.layer.cornerRadius = 10
        addList.layer.borderWidth = 1
        addList.layer.borderColor = UIColor.black.cgColor
        self.title = "Lists"
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        listNames = [String]()
        places = [String]()
        ids = [String]()
        retrievedata()
        btn1.titleLabel?.font =  UIFont(name: "American Typewriter", size: 18)
        btn1.backgroundColor = .clear
        btn1.setTitle("Edit", for: .normal)
        btn1.tag = 1
        btn1.setTitleColor(UIColor.black, for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 50, height: 25)
        btn1.addTarget(self, action: #selector(edit(sender:)), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        self.navigationItem.rightBarButtonItem = item1
        if listNames.isEmpty
        {
            btn1.isHidden = true
        }
        else
        {
            btn1.isHidden = false
        }
    }
   
    @IBAction func addList(sender : UIButton!)
    {
        let listItemsViewController = self.storyboard?.instantiateViewController(withIdentifier: "ListItemsViewController") as! ListItemsViewController
        listItemsViewController.flag = 0
        UserDefaults.standard.set(nil, forKey: "Place")
        UserDefaults.standard.set(nil, forKey: "Latitude")
        UserDefaults.standard.set(nil, forKey: "Longitude")
        self.navigationController?.pushViewController(listItemsViewController, animated: true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listNames.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:ListNameTableViewCell = self.listName.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! ListNameTableViewCell
        cell.name.setTitle("  \(ids[indexPath.row]). \(listNames[indexPath.row]) (\(places[indexPath.row]))", for: .normal)
        if delete == 1
        {
            cell.delete.isHidden = false
            cell.delete.tag = indexPath.row
            cell.delete.addTarget(self, action:#selector(onEditRow(sender:)), for: .touchUpInside)
        }
        else
        {
            cell.delete.isHidden = true
        }
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        return cell
    }
    @objc func onEditRow(sender:UIButton)
    {
        listNames.remove(at: sender.tag)
        places.remove(at: sender.tag)
        deleteData(id : sender.tag+1)
        listName.reloadData()
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
            places.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            deleteData(id : indexPath.row+1)
        }
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        let footerView = UIView(frame: CGRect(x:0, y:0, width:Int(tableView.frame.size.width), height:Int(tableView.frame.size.height)))
        footerView.backgroundColor = .clear
        
        return footerView
    }
    func retrievedata()
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let request:NSFetchRequest<List>
        request = NSFetchRequest<List>(entityName: "List")
        let requestItems:NSFetchRequest<Items>
        requestItems = NSFetchRequest<Items>(entityName: "Items")
        do
        {
            let entities = try appDelegate.managedObjectContext?.fetch(request)
            for item in entities!
            {
                //for key in item.entity.attributesByName.keys
                //{
                    //if key == "name"
                    //{
                        let nameValue: Any? = item.value(forKey: "name")
                 let IdValue: Any? = item.value(forKey: "id")
                        if nameValue == nil
                        {
                            listNames.append("a")
                        }
                        else
                        {
                            listNames.append("\(nameValue!)")
                        }
                    //}
                    //else
                    //{
                    if IdValue == nil
                    {
                        ids.append("no")
                    }
                    else
                    {
                        ids.append("\(IdValue!)")
                    }
                    //}
                //}
            }
           self.listName.reloadData()
        }catch{
            print("Unable to retrieve data")
        }
        do
        {
            let entities = try appDelegate.managedObjectContext?.fetch(requestItems)
            for item in entities!
            {
                //for key in item.entity.attributesByName.keys
               // {
                    if ids.contains("\(item.value(forKey: "id")!)")
                    {
                            
                            let place = "\(item.value(forKey: "place")!)"
                                
                            if place == ""
                            {
                                places.append("No Store Selected")
                            }
                            else
                            {
                                places.append(place)
                            }
                    //}
                }
            }
            self.listName.reloadData()
        }catch{
            print("Unable to retrieve data")
        }
        if listNames.count == 0
        {
            arrowNav.isHidden = false
            listName.isHidden = true
            btn1.isHidden = false
        }
        else
        {
            arrowNav.isHidden = true
            listName.isHidden = false
            btn1.isHidden = true
        }
    }
    @IBAction func onClickItem(sender : UIButton)
    {
        let listItemsViewController = self.storyboard?.instantiateViewController(withIdentifier: "ListItemsViewController") as! ListItemsViewController
        let name = (sender.currentTitle)?.components(separatedBy: ".")
        let names = name![1].components(separatedBy: "(")
        let itemName = names[0].trimmingCharacters(in: .whitespacesAndNewlines)
        let itemID = name![0].trimmingCharacters(in: .whitespacesAndNewlines)
        listItemsViewController.name = itemName
        listItemsViewController.itemId = Int(itemID)
        listItemsViewController.flag = 1
        btn1.setTitle("Edit", for: .normal)
        delete = 0
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
                        if let loc = item.value(forKey: "geotification")
                        {
                            let location = "\(loc)"
                            let arr = location.split(separator: "+").map(String.init)
                            let lat = Double(arr[0])!
                            let long = Double(arr[1])!
                            let geo = CLLocationCoordinate2DMake(lat, long);
                            let region = CLCircularRegion(center: geo , radius: 200, identifier: arr[2])
                            locationManager.stopMonitoring(for: region)
                        }
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
        if listNames.count == 0
        {
            arrowNav.isHidden = false
            listName.isHidden = true
            btn1.isHidden = false
        }
        else
        {
            arrowNav.isHidden = true
            listName.isHidden = false
            btn1.isHidden = true
        }
        updateID()
    }
    func updateID()
    {
        var newID = 1
        var geoid = 1
        ids = [String]()
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
                        ids.append("\(item.id)")
                        print(newID)
                        newID += 1
                    }
                    if key == "geotification"
                    {
                        if let geotification = item.geotification
                        {
                            let arr = geotification.split(separator: "+").map(String.init)
                            let lat = Double(arr[0])!
                            let long = Double(arr[1])!
                            let geo = CLLocationCoordinate2DMake(lat, long);
                            let region = CLCircularRegion(center: geo , radius: 200, identifier: arr[2])
                            locationManager.stopMonitoring(for: region)
                            let geonew = arr[2].split(separator: "@")
                            let newregion = CLCircularRegion(center:geo , radius: 200, identifier: "\(geonew[0])@\(geoid)")
                            locationManager.startMonitoring(for: newregion)
                            item.setValue("\(lat)+\(long)+\(region.identifier)", forKey: "geotification")
                        }
                        print(geoid)
                        geoid += 1
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
    @objc func edit(sender : UIButton)
    {
        if delete == 1
        {
            sender.setTitle("Edit", for: .normal)
            delete = 0
        }
        else
        {
            sender.setTitle("Done", for: .normal)
            delete = 1
        }
        self.listName.reloadData()
    }
}
  


