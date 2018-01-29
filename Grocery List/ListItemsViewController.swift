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
import CoreLocation
import UserNotifications


class ListItemsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, CLLocationManagerDelegate
{
    @IBOutlet var locationButton : UIButton!
    @IBOutlet var updateList: UIButton!
    @IBOutlet var listTable : UITableView!
    @IBOutlet var addItems : UIButton!
    @IBOutlet var addImage : UIImageView!
    @IBOutlet var listName : UITextField!
    @IBOutlet var itemTable : UITableView!
    
    var data = [Dictionary<String,String>]()
    var items : String!
    var cellReuseIdentifier = "ListTableViewCell"
    var cellReuseId = "ItemTableCell"
    var listArray = [""]
    var count = 1
    var name = ""
    var flag = 0
    var countArr = [""]
    var coordinate : CLLocationCoordinate2D!
    var place : String!
    var del = 0
    var locationManager : CLLocationManager = CLLocationManager()
    var setLocation = false
    var itemId : Int!
    
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
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool)
    {
        let btn1 = UIButton(type: .custom)
        btn1.titleLabel?.font =  UIFont(name: "American Typewriter", size: 18)
        btn1.backgroundColor = .clear
        btn1.setTitle("Edit", for: .normal)
        btn1.setTitleColor(UIColor.black, for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 50, height: 25)
        btn1.addTarget(self, action: #selector(edit(sender:)), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        self.navigationItem.rightBarButtonItem = item1
        listTable.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        listTable.separatorColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
        itemTable.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        itemTable.separatorColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        tapGesture.cancelsTouchesInView = true
        self.listTable.addGestureRecognizer(tapGesture)
        self.view.addGestureRecognizer(tapGesture)
        listName.delegate = self
        del = 0
        itemTable.isHidden = true
        if (UserDefaults.standard.string(forKey: "Place") != nil)
        {
            locationButton.setTitle(UserDefaults.standard.string(forKey: "Place"), for: .normal)
        }
        else if flag == 0
        {
            btn1.isHidden = true
            self.title = "New List"
            UserDefaults.standard.set(nil, forKey: "Place")
            UserDefaults.standard.set(nil, forKey: "Latitude")
            UserDefaults.standard.set(nil, forKey: "Longitude")
            locationButton.setTitle("Locate \u{25b8}", for: .normal)
            addItems.isHidden = false
            addImage.isHidden = false
            listTable.isHidden = true
            listArray = [""]
            countArr = ["0"]
            listTable.reloadData()
            updateList.setTitle("Add List", for: .normal)
            flag = 0
        }
        else
        {
            itemTable.isHidden = false
            self.title = name
            updateList.setTitle("Update List", for: .normal)
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
                countArr = ["0"]
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
    @objc func edit(sender : UIButton)
    {
        itemTable.isHidden = true
        sender.isHidden = true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.view.endEditing(true)
        return false
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        let footerView = UIView(frame: CGRect(x:0, y:0, width:Int(tableView.frame.size.width), height:Int(tableView.frame.size.height)))
        footerView.backgroundColor = .clear
        
        return footerView
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let cellI:ItemTableCell = self.itemTable.dequeueReusableCell(withIdentifier: cellReuseId) as! ItemTableCell
        if tableView == itemTable
        {
            cellI.backgroundColor = UIColor.cyan
            cellI.srno.text = "Sr.no";
            cellI.itemName.text = "Item Name"
            cellI.quantity.text = "Qty"
            cellI.isHidden = false
        }
        else
        {
            cellI.isHidden = true
        }
        return cellI
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return listArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
       
            let cell:ListTableViewCell = self.listTable.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! ListTableViewCell
            let cellI:ItemTableCell = self.itemTable.dequeueReusableCell(withIdentifier: cellReuseId) as! ItemTableCell
        
                cell.listText.text = listArray[indexPath.row]
                cell.count.text = countArr[indexPath.row]
                cellI.itemName.text = listArray[indexPath.row]
                cellI.quantity.text = countArr[indexPath.row]
                cellI.srno.text = "\(indexPath.row+1)."
                cell.addButton.addTarget(self, action:#selector(onaddRow(sender:)), for: .touchUpInside)
                cell.delButton.addTarget(self, action:#selector(ondelRow(sender:)), for: .touchUpInside)
                cell.listText.addTarget(self, action: #selector(UITextFieldDelegate.textFieldDidEndEditing(_:)), for: UIControlEvents.editingDidEnd)
                cell.count.addTarget(self, action: #selector(UITextFieldDelegate.textFieldDidEndEditing(_:)), for: UIControlEvents.editingDidEnd)
                cell.stepper.addTarget(self, action: #selector(stepperChange(_:)), for: .valueChanged)
        if tableView == listTable
        {
            return cell
        }
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        cellI.preservesSuperviewLayoutMargins = false
        cellI.separatorInset = UIEdgeInsets.zero
        cellI.layoutMargins = UIEdgeInsets.zero
        return cellI
        
    }
    func alert()
    {
        let alert = UIAlertController(title: "Grocery List", message: "Enter valid item name and quantity", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        let cellPosition:CGPoint = textField.convert(CGPoint.zero, to:listTable)
        let indexPath = listTable.indexPathForRow(at: cellPosition)
        if textField.tag == 0
        {
            if let text = textField.text
            {
                listArray[(indexPath?.row)!] = text
            }
        }
        else if textField.tag == 1
        {
            let cell = listTable.cellForRow(at:indexPath!) as! ListTableViewCell
            if let qty = textField.text
            {
                cell.stepper.value = Double(cell.count.text!)!
                countArr[(indexPath?.row)!] = qty
            }
        }
    }
    
   
    @objc func stepperChange(_ sender: UIStepper)
    {
        let cellPosition:CGPoint = sender.convert(CGPoint.zero, to:listTable)
        let indexPath = listTable.indexPathForRow(at: cellPosition)
        let cell = listTable.cellForRow(at:indexPath!) as! ListTableViewCell
        cell.count.resignFirstResponder()
        cell.listText.resignFirstResponder()
        cell.count.text = "\(Int(sender.value))"
        if let qty = cell.count.text
        {
            countArr[(indexPath?.row)!] = qty
        }
    }
    @objc func onaddRow(sender:UIButton)
    {
        listName.resignFirstResponder()
        let cell:ListTableViewCell = self.listTable.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! ListTableViewCell
        cell.listText.addTarget(self, action: #selector(UITextFieldDelegate.textFieldDidEndEditing(_:)), for: UIControlEvents.editingDidEnd)
        cell.count.addTarget(self, action: #selector(UITextFieldDelegate.textFieldDidEndEditing(_:)), for: UIControlEvents.editingDidEnd)
        listTable.reloadData()
        var i=0
        while(i<listArray.count)
        {
            listArray[i] = listArray[i].trimmingCharacters(in: .whitespacesAndNewlines)
            i+=1
        }
        if(listArray.contains("") || countArr.contains("0") || countArr.contains(""))
        {
            alert()
        }
        else
        {
            del = 1
            listTable.beginUpdates()
            listArray.append("")
            countArr.append("0")
            let indx = IndexPath(row:listArray.count-1, section: 0)
            listTable.insertRows(at: [indx], with: .automatic)
            listTable.endUpdates()
        }
    }
    @objc func ondelRow(sender: UIButton)
    {
        listName.resignFirstResponder()
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to:listTable)
        let indexPath = listTable.indexPathForRow(at: buttonPosition)
        listTable.beginUpdates()
        if listArray.count == 1
        {
            listArray.remove(at: (indexPath?.row)!)
            countArr.remove(at: (indexPath?.row)!)
            addItems.isHidden = false
            addImage.isHidden = false
            listTable.isHidden = true
        }
        else
        {
            listArray.remove(at: (indexPath?.row)!)
            countArr.remove(at: (indexPath?.row)!)
        }
        let cell = listTable.cellForRow(at:indexPath!) as! ListTableViewCell
        cell.stepper.value = 0.0
        cell.count.resignFirstResponder()
        cell.listText.resignFirstResponder()
        listTable.deleteRows(at: [indexPath!], with: UITableViewRowAnimation.automatic)
        listTable.endUpdates()
        listTable.reloadData()
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        if tableView == listTable
        {
            return true
        }
        else
        {
            return false
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if (editingStyle == UITableViewCellEditingStyle.delete)
        {
            listArray.remove(at: indexPath.row)
            countArr.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            if listArray.isEmpty
            {
                addItems.isHidden = false
                addImage.isHidden = false
                listTable.isHidden = true
                listArray.append("")
                countArr.append("0")
                listTable.reloadData()
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tableView == itemTable
        {
            return 50
        }
        return 104.0
    }
    @IBAction func clickAdd(sender : UIButton)
    {
        addItems.isHidden = true
        addImage.isHidden = true
        listTable.isHidden = false
        listArray = [""]
        countArr = ["0"]
        listTable.reloadData()
    }
    @IBAction func updateList(sender : UIButton)
    {
        var i=0
        listTable.endEditing(true)
        if addItems.isHidden == false
        {
            let alert = UIAlertController(title: "Grocery List", message: "Enter atleast one valid item and quantity", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if(listArray.contains("") || countArr.contains("0") || countArr.contains(""))
        {
            alert()
        }
        else
        {
        while i<listArray.count
        {
            let txt = listArray[i]
            let qty = countArr[i]
            data.append(["name":txt,"qty":qty])
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
        if listName.text == nil || listName.text == ""
        {
            let alert = UIAlertController(title: "Grocery List", message: "Enter Valid List Name", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
        retrievedata()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if flag == 0
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
                    if setLocation == true
                    {
                        let lat = UserDefaults.standard.double(forKey: "Latitude")
                        let long = UserDefaults.standard.double(forKey: "Longitude")
                        let geo = CLLocationCoordinate2DMake(lat, long);
                        let region = CLCircularRegion(center:geo , radius: 200, identifier: listName.text!)
                        locationManager.startMonitoring(for: region)
                        item.setValue("\(lat)+\(long)+\(region.identifier)", forKey: "geotification")
                    }
                }
                do {
                    try appDelegate.managedObjectContext?.save()
                    print("saved!")
                } catch let error as NSError
                {
                    print("Could not save \(error), \(error.userInfo)")
                } catch {}
            
        }
        else
        {
            let requestList:NSFetchRequest<List>
            requestList = NSFetchRequest<List>(entityName: "List")
            do
            {
                let entities = try appDelegate.managedObjectContext?.fetch(requestList)
                for item in entities!
                {
                    for key in item.entity.attributesByName.keys
                    {
                        if key == "id" && item.value(forKey: key) as? Int! == itemId
                        {
                            item.setValue(listName.text, forKey: "name")
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
            let requestItems:NSFetchRequest<Items>
            requestItems = NSFetchRequest<Items>(entityName: "Items")
            do
            {
                let entities = try appDelegate.managedObjectContext?.fetch(requestItems)
                for item in entities!
                {
                    for key in item.entity.attributesByName.keys
                    {
                        if key == "id" && item.value(forKey: key) as? Int! == itemId
                        {
                            item.setValue(items, forKey: "item")
                            if UserDefaults.standard.string(forKey: "Latitude") == nil || UserDefaults.standard.double(forKey: "Latitude") == 0.0
                            {
                                if locationButton.currentTitle == "Locate \u{25b8}"
                                {
                                    item.setValue("", forKey: "place")
                                    item.setValue(0.0, forKey: "latitude")
                                    item.setValue(0.0, forKey: "longitude")
                                }
                            }
                            else
                            {
                                
                                item.setValue(UserDefaults.standard.double(forKey: "Latitude"), forKey: "latitude")
                                item.setValue(UserDefaults.standard.double(forKey: "Longitude"), forKey: "longitude")
                                item.setValue(UserDefaults.standard.string(forKey: "Place"), forKey: "place")
                                if setLocation == true
                                {
                                    if let loc = item.value(forKey: "geotification")
                                    {
                                        let location = "\(loc)"
                                        let arr = location.split(separator: "+").map(String.init)
                                        let lat = Double(arr[0])
                                        let long = Double(arr[1])
                                        let geo = CLLocationCoordinate2DMake(lat!, long!);
                                        let region = CLCircularRegion(center: geo , radius: 200, identifier: arr[2])
                                        locationManager.stopMonitoring(for: region)
                                    }
                                    let lat = UserDefaults.standard.double(forKey: "Latitude")
                                    let long = UserDefaults.standard.double(forKey: "Longitude")
                                    let geo = CLLocationCoordinate2DMake(lat, long);
                                    let region = CLCircularRegion(center:geo , radius: 200, identifier: listName.text!)
                                    locationManager.startMonitoring(for: region)
                                    item.setValue("\(lat)+\(long)+\(region.identifier)", forKey: "geotification")
                                }
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
        }
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
        
        let requestItems:NSFetchRequest<Items>
        requestItems = NSFetchRequest<Items>(entityName: "Items")
        do
        {
            let entities = try appDelegate.managedObjectContext?.fetch(requestItems)
            for item in entities!
            {
                for key in item.entity.attributesByName.keys
                {
                    if key == "id" && item.value(forKey: key) as? Int! == itemId
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
                    if key == "id" && item.value(forKey: key) as? Int! == itemId
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
        let requestItems:NSFetchRequest<Items>
        requestItems = NSFetchRequest<Items>(entityName: "Items")
        do
        {
            let entities = try appDelegate.managedObjectContext?.fetch(requestItems)
            for item in entities!
            {
                for key in item.entity.attributesByName.keys
                {
                    if key == "id" && item.value(forKey: key) as? Int! == itemId
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
  
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        if (status == CLAuthorizationStatus.authorizedAlways)
        {
            self.setLocation = true
        }
    }
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer)
    {
        listTable.endEditing(true)
    }
    
}

