//
//  ListItemsViewController.swift
//  Grocery List
//
//  Created by Aashana on 11/7/17.
//  Copyright © 2017 Aashana. All rights reserved.
//

import UIKit

class ListItemsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var locationButton : UIButton!
    @IBOutlet var updateList: UIButton!
    @IBOutlet var listTable : UITableView!
    @IBOutlet var addItems : UIButton!
    @IBOutlet var addImage : UIImageView!
    var cellReuseIdentifier = "ListTableViewCell"
    var list = [""]
    

    override func viewDidLoad() {
        locationButton.layer.cornerRadius = 10
        locationButton.layer.borderWidth = 1
        locationButton.layer.borderColor = UIColor.black.cgColor
        locationButton.setTitle("Locate \u{25b8}", for: .normal)
        updateList.layer.cornerRadius = 10
        updateList.layer.borderWidth = 1
        updateList.layer.borderColor = UIColor.black.cgColor
        addItems.layer.cornerRadius = 10
        addItems.layer.borderWidth = 1
        addItems.layer.borderColor = UIColor.black.cgColor
        UserDefaults.standard.set(nil, forKey: "Place")
        addItems.isHidden = false
        addImage.isHidden = false
        listTable.isHidden = true
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool)
    {
        if (UserDefaults.standard.string(forKey: "Place") != nil)
        {
            locationButton.setTitle(UserDefaults.standard.string(forKey: "Place"), for: .normal)
        }
    }
    
    @IBAction func onCLickLocate(sender : UIButton)
    {
        let mapViewController = self.storyboard?.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        
        self.navigationController?.pushViewController(mapViewController, animated: true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:ListTableViewCell = self.listTable.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! ListTableViewCell
        cell.addButton.tag = indexPath.row;
        cell.addButton.addTarget(self, action:#selector(onaddRow(sender:)), for: .touchUpInside)
        return cell
    }
    @objc func onaddRow(sender:UIButton)
    {
        list.append("")
        listTable.beginUpdates()
        listTable.insertRows(at: [IndexPath(row: list.count-1, section: 0)], with: .automatic)
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
            list.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            if list.isEmpty
            {
                addItems.isHidden = false
                addImage.isHidden = false
                listTable.isHidden = true
            }
        }
    }
    @IBAction func clickAdd(sender : UIButton)
    {
        addItems.isHidden = true
        addImage.isHidden = true
        listTable.isHidden = false
    }
}
