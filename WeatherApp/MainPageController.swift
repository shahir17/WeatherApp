//
//  ViewController.swift
//  WeatherApp
//
//  Created by Shahir Abdul-Satar on 3/21/18.
//  Copyright © 2018 Ahmad Shahir Abdul-Satar. All rights reserved.
//

import UIKit
import Firebase
import os.log

class MainPageController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    

    var tableView: UITableView = UITableView()
    var locations = [WeatherModel]()

    let baseURL = "http://api.openweathermap.org/data/2.5/weather"
    let apiKey = "41db44e42479733a7cce6bc8c7ea0da4"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        self.navigationItem.title = "My Weather"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addLocationDialogBox))
        
        
        //tableview
        tableView.delegate = self
        tableView.dataSource = self
        let windowWidth: CGFloat = self.view.frame.width
        let windowHeight: CGFloat = self.view.frame.height
        tableView.frame = CGRect(x: 0, y:  0, width: windowWidth, height: windowHeight)
        view.addSubview(tableView)
        self.tableView.reloadData()
        
        
        
        if let savedWeather = loadWeather() {
            locations += savedWeather
        }
        else {
            // Load the sample data.
            self.tableView.reloadData()
        }
        
    }
    
    
    func addLocationDialogBox(){
        let setLocationAlert = UIAlertController(title: "Find Weather for Location", message: "Enter City and Zipcode", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Add", style: .default) { (_) in
            
            if (setLocationAlert.textFields?[0].text?.isEmpty)! || (setLocationAlert.textFields?[1].text?.isEmpty)! {
                
                let emptyTextFieldAlert = UIAlertController(title: "Empty Entry", message: "Make sure you don't leave any fields empty", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .cancel) { (_) in }
                emptyTextFieldAlert.addAction(okAction)
                self.present(emptyTextFieldAlert, animated: true, completion: nil)
                
            }
            else {
                
                //getting the input values from user
                if let cityName = setLocationAlert.textFields?[0].text!,
                    let zipcode = setLocationAlert.textFields?[1].text! {
                    
                    let weatherRequestURL = URL(string: "\(self.baseURL)?APPID=\(self.apiKey)&q=\(cityName)")!
                    
                    URLSession.shared.dataTask(with:weatherRequestURL, completionHandler: {(data, response, error) in
                        guard let data = data, error == nil else {
                            
                            //in case no data was found
                            let noCityAlert = UIAlertController(title: "City Not Found", message: "Make sure to enter a valid city", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .cancel) { (_) in }
                            noCityAlert.addAction(okAction)
                            self.present(noCityAlert, animated: true, completion: nil)
                        return
                        }
                        
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                            if let main = json["main"] as? [String:Any]{
                                let kelvinTemp = main["temp"] as? Int
                                let name = json["name"] as! String
                                let temp = (9/5)*(kelvinTemp!-273)+32
                                let id = json["id"] as! Int
                                
                                let location = WeatherModel(cityName: name, zipcode: zipcode, temperature: String(temp), id: String(id))
                                self.locations.append(location!)
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                                self.saveWeather()
                            }
                           
                            
                        } catch let error as NSError {
                            print(error)
                        }
                    }).resume()
                }
            
                
            }
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        //adding textfields to our dialog box
        setLocationAlert.addTextField { (textField) in
            textField.placeholder = "City"
            textField.keyboardType = .default
            textField.autocapitalizationType = .words
            
        }
        setLocationAlert.addTextField { (textField) in
            textField.placeholder = "Zipcode"
            textField.keyboardType = .numberPad
        }
        
        //adding the action to dialogbox
        setLocationAlert.addAction(confirmAction)
        setLocationAlert.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(setLocationAlert, animated: true, completion: nil)
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if locations.isEmpty {
            return 0
        }
        else {
        
            return locations.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TableViewCell(style: .default, reuseIdentifier: "myCell")
        cell.name.text = locations[indexPath.row].cityName
        cell.temperature.text = locations[indexPath.row].temperature! + "°"
        cell.zipcode.text = locations[indexPath.row].zipcode
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //push new controller on navigation stack
        let detailController = DetailViewController()
        
        detailController.cityName = locations[indexPath.row].cityName
        detailController.cityId = locations[indexPath.row].id
        
        self.navigationController?.pushViewController(detailController, animated: true)
        
    }
    
     func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            locations.remove(at: indexPath.row)
            saveWeather()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert{
            
            
        }
    }

    
    private func saveWeather() {
    
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(locations, toFile: WeatherModel.ArchiveURL.path)
        if isSuccessfulSave {
            if #available(iOS 10.0, *) {
                os_log("Weather successfully saved.", log: OSLog.default, type: .debug)
            } else {
                // Fallback on earlier versions
            }
        } else {
            if #available(iOS 10.0, *) {
                os_log("Failed to save weather...", log: OSLog.default, type: .error)
            } else {
                // Fallback on earlier versions
            }
        }
    
    
    }
    
    private func loadWeather() -> [WeatherModel]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: WeatherModel.ArchiveURL.path) as? [WeatherModel]
    }

    
}





//MARK: tableview custom cell

class TableViewCell: UITableViewCell {
    var name: UILabel! = UILabel()
    var zipcode: UILabel! = UILabel()
    var temperature: UILabel! = UILabel()

    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        name.frame = CGRect(x: 10, y: 15,width: 175,height: 40)
        zipcode.frame = CGRect(x: 10, y: 60, width: 70, height: 25)
        temperature.frame = CGRect(x: self.frame.width-125, y: 10, width: 90, height: 75)

        name.textColor = UIColor.black
        name.textAlignment = .left
        name.font = UIFont.systemFont(ofSize: 22)
        zipcode.textColor = UIColor.black
        zipcode.textAlignment = .left
        zipcode.font = UIFont.systemFont(ofSize: 14)
        temperature.textColor = UIColor.black
        temperature.textAlignment = .center
        temperature.font = UIFont.systemFont(ofSize: 32)
        contentView.addSubview(name)
        contentView.addSubview(zipcode)
        contentView.addSubview(temperature)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    
}






