//
//  ListItemsViewController.swift
//  Grocery List
//
//  Created by Aashana on 11/7/17.
//  Copyright © 2017 Aashana. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class ListItemsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    @IBOutlet var locationButton : UIButton!
    @IBOutlet var updateList: UIButton!
    @IBOutlet var listTable : UITableView!
    @IBOutlet var addItems : UIButton!
    @IBOutlet var addImage : UIImageView!
    @IBOutlet var listName : UITextField!
    
    var data = [Dictionary<String,String>]()
    var items : String!
    var cellReuseIdentifier = "ListTableViewCell"
    var listArray = [""]
    var count = 1
    var name = ""
    var id : Int!
    var flag = 0
    var countArr = [""]
    var coordinate : CLLocationCoordinate2D!
    var place : String!
    var del = 0
    

    override func viewDidLoad()
    {
        super.viewDidLoad()
        locationButton.layer.cornerRadius = 10
        locationButton.layer.borderWidth = 1
        locationButton.layer.borderColor = UIColor.black.cgColor
        
        updateList.layer.cornerRadius = 10
        updateList.layer.borderWidth = 1
        updateList.layer.borderColor = UIColor.black.cgColor
        addItems.layer.cornerRadius = 10
        addItems.layer.borderWidth = 1
        addItems.layer.borderColor = UIColor.black.cgColor
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool)
    {
        del = 0
        if (UserDefaults.standard.string(forKey: "Place") != nil)
        {
            locationButton.setTitle(UserDefaults.standard.string(forKey: "Place"), for: .normal)
        }
        else if flag == 0
        {
            UserDefaults.standard.set(nil, forKey: "Place")
            UserDefaults.standard.set(nil, forKey: "Latitude")
            UserDefaults.standard.set(nil, forKey: "Longitude")
            locationButton.setTitle("Locate \u{25b8}", for: .normal)
            addItems.isHidden = false
            addImage.isHidden = false
            listTable.isHidden = true
            flag = 0
        }
        else
        {
            listName.text = name
            retrievedata()
            getList()
            getLoc()
            flag = 1
            if listArray.count == 0
            {
                addItems.isHidden = false
                addImage.isHidden = false
                listTable.isHidden = true
                listArray = [""]
                listTable.reloadData()
            }
            else
            {
                addItems.isHidden = true
                addImage.isHidden = true
                listTable.isHidden = false
            }
            
        }
    }
    
    @IBAction func onCLickLocate(sender : UIButton)
    {
        let mapViewController = self.storyboard?.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        if locationButton.currentTitle == "Locate \u{25b8}"
        {
            mapViewController.flag = 0
        }
        else
        {
            mapViewController.flag = 1
            mapViewController.name = locationButton.currentTitle
            if coordinate != nil
            {
                mapViewController.coordinate = coordinate
                coordinate = nil
            }
            else
            {
                let lat =  UserDefaults.standard.double(forKey: "Latitude")
                let long = UserDefaults.standard.double(forKey: "Longitude")
                coordinate = CLLocationCoordinate2DMake(lat, long)
                mapViewController.coordinate = coordinate
            }
        }
        self.navigationController?.pushViewController(mapViewController, animated: true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:ListTableViewCell = self.listTable.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! ListTableViewCell
        if flag == 0 || listArray[0] == ""
        {
            cell.addButton.tag = indexPath.row;
            cell.addButton.addTarget(self, action:#selector(onaddRow(sender:)), for: .touchUpInside)
        }
        else
        {
            cell.listText.text = listArray[indexPath.row]
            cell.count.text = countArr[indexPath.row]
            cell.addButton.tag = indexPath.row;
            cell.addButton.addTarget(self, action:#selector(onaddRow(sender:)), for: .touchUpInside)
        }
        return cell
    }
    @objc func onaddRow(sender:UIButton)
    {
        del = 1
        listArray.append("")
        countArr.append("0")
        listTable.beginUpdates()
        listTable.insertRows(at: [IndexPath(row: listArray.count-1, section: 0)], with: .automatic)
        listTable.endUpdates()
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
            listArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            if listArray.isEmpty
            {
                addItems.isHidden = false
                addImage.isHidden = false
                listTable.isHidden = true
            }
            if del == 0
            {
                deleteData(cellId : indexPath.row)
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100.0
    }
    @IBAction func clickAdd(sender : UIButton)
    {
        addItems.isHidden = true
        addImage.isHidden = true
        listTable.isHidden = false
    }
    @IBAction func updateList(sender : UIButton)
    {
        var i=0
        while i<listArray.count
        {
            
            let ndx = IndexPath(row:i, section: 0)
            let cell = listTable.cellForRow(at:ndx) as! ListTableViewCell
            let txt = cell.listText.text
            let qty = cell.count.text
            data.append(["name":txt!,"qty":qty!])
            i+=1
        }
        if data.count == 1 && data[0] == ["name": "", "qty": "0"]
        {
            items = "[\n\n]"
        }
        else
        {
        do {
            let data1 =  try JSONSerialization.data(withJSONObject: data, options: JSONSerialization.WritingOptions.prettyPrinted) // first of all convert json to the data
            let convertedString = String(data: data1, encoding: String.Encoding.utf8) // the data will be converted to the string
            items = convertedString!
            
        } catch let myJSONError {
            print(myJSONError)
        }
        }
        retrievedata()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if flag == 0
        {
            if listName.text == nil || listName.text == ""
            {
                let alert = UIAlertController(title: "Grocery List", message: "Enter Valid List Name", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else
            {
                let entityList =  NSEntityDescription.entity(forEntityName: "List", in: appDelegate.managedObjectContext!)
                
                let list = NSManagedObject(entity: entityList!, insertInto: appDelegate.managedObjectContext)
                let entityItem =  NSEntityDescription.entity(forEntityName: "Items", in: appDelegate.managedObjectContext!)
                
                let item = NSManagedObject(entity: entityItem!, insertInto: appDelegate.managedObjectContext)
                list.setValue(listName.text, forKey: "name")
                list.setValue(count+1, forKey: "id")
                item.setValue(count+1, forKey: "id")
                item.setValue(items, forKey: "item")
                if UserDefaults.standard.string(forKey: "Latitude") == nil || UserDefaults.standard.double(forKey: "Latitude") == 0.0
                {
                    item.setValue("", forKey: "place")
                    item.setValue(0.0, forKey: "latitude")
                    item.setValue(0.0, forKey: "longitude")
                }
                else
                {
                    item.setValue(UserDefaults.standard.double(forKey: "Latitude"), forKey: "latitude")
                    item.setValue(UserDefaults.standard.double(forKey: "Longitude"), forKey: "longitude")
                    item.setValue(UserDefaults.standard.string(forKey: "Place"), forKey: "place")
                }
                do {
                    try appDelegate.managedObjectContext?.save()
                    print("saved!")
                    } catch let error as NSError
                    {
                        print("Could not save \(error), \(error.userInfo)")
                    } catch {}
            }
        }
        else
        {
            let requestItems:NSFetchRequest<Items>
            requestItems = NSFetchRequest<Items>(entityName: "Items")
            do
            {
                let entities = try appDelegate.managedObjectContext?.fetch(requestItems)
                for item in entities!
                {
                    for key in item.entity.attributesByName.keys
                    {
                        if key == "id" && item.value(forKey: key) as? Int! == id
                        {
                            item.setValue(items, forKey: "item")
                            if UserDefaults.standard.string(forKey: "Latitude") == nil || UserDefaults.standard.double(forKey: "Latitude") == 0.0
                            {
                                item.setValue("", forKey: "place")
                                item.setValue(0.0, forKey: "latitude")
                                item.setValue(0.0, forKey: "longitude")
                            }
                            else
                            {
                                item.setValue(UserDefaults.standard.double(forKey: "Latitude"), forKey: "latitude")
                                item.setValue(UserDefaults.standard.double(forKey: "Longitude"), forKey: "longitude")
                                item.setValue(UserDefaults.standard.string(forKey: "Place"), forKey: "place")
                            }
                        }
                    }
                }
                do {
                    try appDelegate.managedObjectContext?.save()
                    print("saved!")
                } catch let error as NSError  {
                    print("Could not save \(error), \(error.userInfo)")
                }
            }catch{
                print("Unable to retrieve data")
            }
        }
        UserDefaults.standard.set(nil, forKey: "Place")
        UserDefaults.standard.set(nil, forKey: "Latitude")
        UserDefaults.standard.set(nil, forKey: "Longitude")
        self.navigationController?.popViewController(animated: true)
    }
    func retrievedata()
    {
        count = 0
        listArray = []
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
                        if key == "id" && item.value(forKey: key) != nil
                        {
                            count += 1
                        }
                    }
                }
            }catch{
                print("Unable to retrieve data")
            }
    }
    func getList()
    {
        listArray = []
        countArr = []
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let requestList:NSFetchRequest<List>
        requestList = NSFetchRequest<List>(entityName: "List")
        let requestItems:NSFetchRequest<Items>
        requestItems = NSFetchRequest<Items>(entityName: "Items")
        do
        {
            let entities = try appDelegate.managedObjectContext?.fetch(requestList)
            for item in entities!
            {
                for key in item.entity.attributesByName.keys
                {
                    if key == "name" && "\(item.value(forKey: key)!)" == listName.text
                    {
                        id = item.value(forKey: "id") as? Int!
                    }
                }
            }
        }catch{
            print("Unable to retrieve data")
        }
        do
        {
            let entities = try appDelegate.managedObjectContext?.fetch(requestItems)
            for item in entities!
            {
                for key in item.entity.attributesByName.keys
                {
                    if key == "id" && item.value(forKey: key) as? Int! == id
                    {
                        let fetchedItems = item.value(forKey: "item") as! String
                        if let data = fetchedItems.data(using: .utf8)
                        {
                            let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [Dictionary<String,String>]
                            for val in json
                            {
                                listArray.append("\(val["name"]!)")
                                countArr.append("\(val["qty"]!)")
                            }
                        }
                    }
                }
            }
            self.listTable.reloadData()
        }catch{
            print("Unable to retrieve data")
        }
    }
    func deleteData(cellId : Int)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
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
                    if key == "id" && item.value(forKey: key) as? Int! == id
                    {
                        let fetchedItems = item.value(forKey: "item") as! String
                        if let data = fetchedItems.data(using: .utf8)
                        {
                            var json = try! JSONSerialization.jsonObject(with: data, options: []) as! [Dictionary<String,Any>]
                           
                            json.remove(at: cellId)
                            do {
                                let data1 =  try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) // first of all convert json to the data
                                let convertedString = String(data: data1, encoding: String.Encoding.utf8) // the data will be converted to the string
                                items = convertedString!
                                
                            } catch let myJSONError {
                                print(myJSONError)
                            }
                        }
                        item.setValue(items, forKey: "item")
                        
                    }
                }
                
                print(item)
            }
            do {
                try context?.save()
                print("saved!")
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
            
            countArr.remove(at: cellId)
            self.listTable.reloadData()
        }catch{
            print("Unable to retrieve data")
        }
    }
    func getLoc()
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let requestList:NSFetchRequest<List>
        requestList = NSFetchRequest<List>(entityName: "List")
        let requestItems:NSFetchRequest<Items>
        requestItems = NSFetchRequest<Items>(entityName: "Items")
        do
        {
            let entities = try appDelegate.managedObjectContext?.fetch(requestList)
            for item in entities!
            {
                for key in item.entity.attributesByName.keys
                {
                    if key == "name" && "\(item.value(forKey: key)!)" == listName.text
                    {
                        id = item.value(forKey: "id") as? Int!
                    }
                }
            }
        }catch{
            print("Unable to retrieve data")
        }
        do
        {
            let entities = try appDelegate.managedObjectContext?.fetch(requestItems)
            for item in entities!
            {
                for key in item.entity.attributesByName.keys
                {
                    if key == "id" && item.value(forKey: key) as? Int! == id
                    {
                        place = "\(item.value(forKey: "place")!)"
                        
                        if place == ""
                        {
                            locationButton.setTitle("Locate \u{25b8}", for: .normal)
                        }
                        else
                        {
                            locationButton.setTitle(place, for: .normal)
                            let lat = item.value(forKey: "latitude")! as! CLLocationDegrees
                            let long = item.value(forKey: "longitude")! as! CLLocationDegrees
                            coordinate = CLLocationCoordinate2DMake(lat, long)
                        }
                    }
                }
            }
        }catch{
            print("Unable to retrieve data")
        }
    }
}
