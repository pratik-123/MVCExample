//
//  ViewController.swift
//  MVCExample
//
//  Created by Pratik Lad on 01/06/16.
//  Copyright © 2016 Pratik. All rights reserved.
//

import UIKit
import CoreData


class ViewController: UIViewController,UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var studModel = [Student]()
    var studentManagedObj=[NSManagedObject]()

    
    //MARK:viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        tableView.dataSource = self
        tableView.delegate = self
        
        selectAllRecord()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Button Add record
    /*========================================================================
    * Function Purpose: add title and name in database
    * =====================================================================*/
    @IBAction func btnAddValue(sender: AnyObject) {
        
        var txtTitle: UITextField!
        var txtName: UITextField!
        
        //make and use a UIAlertController
        
        if #available(iOS 8.0, *) {
            let alertController = UIAlertController(title: "", message: "", preferredStyle: .Alert)
            
            alertController.addTextFieldWithConfigurationHandler { (textField) in
                textField.placeholder = "Enter title"
                txtTitle = textField
            }
            
            alertController.addTextFieldWithConfigurationHandler{ (textField) in
                textField.placeholder = "Enter your name"
                txtName = textField
            }
            
            
            let confirmAction = UIAlertAction(title: "Done", style: .Default) { (_) in
                
             //   print(txtTitle.text!)
             //   print(txtName.text!)
                
                self.addRecord(txtTitle.text!, name: txtName.text!)
               
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            
            alertController.view.setNeedsLayout()
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } else {
            // Fallback on earlier versions
            showAlertForAddRecored()
        }
    }
    
    //if ios virsion in < 8 then use this alertview methods
    func showAlertForAddRecored(){
        let alert = UIAlertView()
        alert.delegate = self
        alert.title = ""
        alert.addButtonWithTitle("Cancel")
        alert.addButtonWithTitle("Done")
        alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
        let txtTitle = alert.textFieldAtIndex(0)
        txtTitle!.placeholder = "Enter title"
        let txtName = alert.textFieldAtIndex(1)
        txtName!.placeholder = "Enter your name"
        alert.show()
    }
    func alertView(View: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        
          let txtTitle = View.textFieldAtIndex(0)
            let txtName = View.textFieldAtIndex(1)
            
            
            switch buttonIndex{
            case 0:
                break;
            case 1:
                // done click
              //  id = textField!.text!
                
              //  print(txtTitle!.text!)
              //  print(txtName!.text!)
                
                self.addRecord(txtTitle!.text!, name: txtName!.text!)

                break;
            default:
                NSLog("Default \(View.tag)");
                break;
            }
    }

    //MARK: Get All Student data from core data
    /*========================================================================
    * Function Name: selectAllRecord
    * Function Purpose: get all record from data base
    * =====================================================================*/
    func selectAllRecord()
    {
        let appDelegate =
            UIApplication.sharedApplication().delegate as? AppDelegate
        let managedContext = appDelegate?.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName:"Student")
        
        do
        {
            let fetchedResults =  try managedContext!.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            if let results = fetchedResults
            {
                studentManagedObj = results
                studModel = [Student]()
            }
        }
        catch _ {
            print("Could not fetch")
        }

        for i in  (0..<studentManagedObj.count)
        {
            let stud = studentManagedObj[i]
            
            let sTitle = stud.valueForKey("title") as! String
            let sName = stud.valueForKey("name") as! String

            //append value in model
            studModel.append(Student(title: sTitle, name: sName))
        }
        tableView.reloadData()
    }
    // end select record method----------------------------------------
    
    //MARK: Add Record into database
    /*========================================================================
    * Function Name: addRecord
    * Function Purpose: add name and title in database
    * =====================================================================*/
    func addRecord(title:String,name:String)  {

        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        let managedContext = appDelegate?.managedObjectContext
        
        let entity =  NSEntityDescription.entityForName("Student",inManagedObjectContext:managedContext!)
        
        let stud = NSManagedObject(entity: entity!,
                                   insertIntoManagedObjectContext:managedContext)
        
        stud.setValue(title, forKey: "title")
        stud.setValue(name, forKey: "name")
        
        do {
            try managedContext?.save()
            // print("succedd...")

        } catch _ {
            print("failed...")
        }

        studentManagedObj.append(stud)
        selectAllRecord()
    }
    // end insert record for student-------------------------------------------
    
    //MARK: Delete record
    /*========================================================================
    * Function Name: deleteRecord
    * Function Purpose: if name is match then student record delete
    * =====================================================================*/
    func deleteRecord(name:String)
    {
        let appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let context:NSManagedObjectContext = appDel.managedObjectContext
        
        // Assuming type has a reference to managed object context
        
        let predicate = NSPredicate(format: "name == %@", "\(name)")
        
        let fetchRequest = NSFetchRequest(entityName: "Student")
        fetchRequest.predicate = predicate
        
        do {
            let fetchedEntities = try context.executeFetchRequest(fetchRequest) //as! [Study]
            
            for entity in fetchedEntities {
                
                context.deleteObject(entity as! NSManagedObject)
            }
        } catch {
            // Do something in response to error condition
        }
        
        do {
            try context.save()
            
           // selectAllRecord()
            
            tableView.reloadData()
            
        } catch {
            // Do something in response to error condition
        }
    }
    // end delete record method-------------------------------------------------
    
    //MARK: table view Delegate method
    /*========================================================================
    * Function Purpose: default tableview delegate methods
    * =====================================================================*/
    //MARK: numberOfRowsInSection
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studModel.count
    }
    //MARK: cellForRowAtIndexPath
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
        
        let studObj = studModel[indexPath.row]

        let lblTitle = cell.viewWithTag(1) as! UILabel
        let lblName = cell.viewWithTag(2) as! UILabel
        
        lblTitle.text = studObj.title
        lblName.text = studObj.name
        
        return cell
    }
    
    //MARK: canEditRowAtIndexPath
    //swipe to delete record
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    //MARK: commitEditingStyle
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            
            let studObj = studModel[indexPath.row]

            studModel.removeAtIndex(indexPath.row)

          //  print(studObj.name)
            
            deleteRecord(studObj.name)

        }
    }
    //end table view delegate methods------------------------------------------------
}

