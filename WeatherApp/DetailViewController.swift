//
//  DetailViewController.swift
//  WeatherApp
//
//  Created by Shahir Abdul-Satar on 3/22/18.
//  Copyright © 2018 Ahmad Shahir Abdul-Satar. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var cityName: String?
    var tableView: UITableView = UITableView()
    var cityId: String?
    var forecast = [FiveDayWeatherModel]()
    
    
    let baseURL = "http://api.openweathermap.org/data/2.5/forecast"
    let apiKey = "659743361ce6c2d4d2833e9b42a33ff5"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        self.navigationItem.title = cityName
        
        //tableview
        tableView.delegate = self
        tableView.dataSource = self
        let windowWidth: CGFloat = self.view.frame.width
        let windowHeight: CGFloat = self.view.frame.height
        tableView.frame = CGRect(x: 0, y:  0, width: windowWidth, height: windowHeight)
        
        view.addSubview(tableView)
       
        
        
        //if we get a city id the proceed with datatask
        if let id = cityId{
            let weatherRequestURL = URL(string: "\(self.baseURL)?id=\(id)&appid=\(apiKey)")!
            URLSession.shared.dataTask(with:weatherRequestURL, completionHandler: {(data, response, error) in
                guard let data = data, error == nil else { return }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                    let list = json["list"] as? [[String: Any]]
                    for item in list! {
                        
                        //print(item["main"])
                        if let main = item["main"] as? [String:Any]{
                            
                            let kelvin_max = main["temp_max"] as! Int
                            let temp_max = (9/5)*(kelvin_max-273)+32
                            let fullDay = item["dt_txt"] as! String
                            var token = fullDay.components(separatedBy: " ")
                            let day = token[0]
                            let time = token[1]
                            print(temp_max)
                            print(day)
                            let date = getDateFormat(day)
                            let timeFormatted = getTimeFormat(time)
                            
                            let fiveDayModel = FiveDayWeatherModel(day: date!, temp_max: String(temp_max), time: timeFormatted!)
                            
                            self.forecast.append(fiveDayModel!)

                            //move to main thread and reload data
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                            
                        }
                    }
                    
            
                } catch let error as NSError {
                    print(error)
                }
            }).resume()
        }
    
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !forecast.isEmpty {
            return self.forecast.count - 10
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = DetailTableViewCell(style: .default, reuseIdentifier: "cell")
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        cell.date.text = self.forecast[indexPath.row].day
       cell.time.text = self.forecast[indexPath.row].time
        cell.tempMax.text = self.forecast[indexPath.row].temp_max! + "°"
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }

}

// MARK:  helper functions
func getDateFormat(_ today:String) -> String? {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd,yyyy"
        
        let date: Date? = dateFormatterGet.date(from: today)
    
         return dateFormatterPrint.string(from: date!)
    }


func getTimeFormat(_ time:String) -> String? {
        
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "HH:mm:ss"
        
        let fullDate = dateFormatter.date(from: time)
        
        dateFormatter.dateFormat = "hh:mm a"
        
        let time2 = dateFormatter.string(from: fullDate!)
        return time2
    }





//MARK: tableview custom cell

class DetailTableViewCell: UITableViewCell {
    var date: UILabel! = UILabel()
    var tempMax: UILabel! = UILabel()
    var time: UILabel! = UILabel()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        date.frame = CGRect(x: 10, y: 15,width: 175,height: 40)
        time.frame = CGRect(x: 10, y: 50, width: 100, height: 45)
        tempMax.frame = CGRect(x: self.frame.width-100, y: 10, width: 80, height: 75)
        
        date.textColor = UIColor.black
        date.textAlignment = .left
        date.font = UIFont.systemFont(ofSize: 22)
        time.textColor = UIColor.black
        time.textAlignment = .left
        time.font = UIFont.systemFont(ofSize: 16)
        tempMax.textColor = UIColor.black
        tempMax.textAlignment = .center
        tempMax.font = UIFont.systemFont(ofSize: 32)
        contentView.addSubview(date)
        contentView.addSubview(time)
        contentView.addSubview(tempMax)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


