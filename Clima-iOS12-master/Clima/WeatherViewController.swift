//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SVProgressHUD
import CoreLocation


class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityNameDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "a1ddbbc5605abb52e166d6a47d8c6863"
    /***Get your own App ID at https://openweathermap.org/appid ****/
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    var weatherDataModel =  WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url:String, parameter:[String:String]){
        Alamofire.request(url, method: .get, parameters: parameter).responseJSON {
            reponse in
            if reponse.result.isSuccess{
                print("Connection is Successful")
                let weatherJSON:JSON = JSON(reponse.result.value)
                print(weatherJSON)
                self.updateWeatherData(json: weatherJSON)
                
            }else{
                print("Error: \(reponse.result.error)")
                self.cityLabel.text = "Connection issues"
            }
        }
    }
    

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json:JSON){
        let tempResult = json["main"]["temp"].double
        weatherDataModel.temperature = Int(tempResult! - 273.15)
        weatherDataModel.city = json["name"].stringValue
        weatherDataModel.condition = json["weather"][0]["id"].intValue
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
        updateUIWithWeatherData()
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData(){
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
        }
        let latitude = String(location.coordinate.latitude)
        let logitude = String(location.coordinate.longitude)
        let params:[String:String] = ["lat":latitude,"lon":logitude,"appid":APP_ID]
        getWeatherData(url: WEATHER_URL, parameter: params)
    }
    
    //Write the didFailWithError method here:
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavaiable"
    }
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String) {
        let params:[String:String] = ["q":city,"appid":APP_ID]
        getWeatherData(url: WEATHER_URL, parameter: params)
    }

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName"{
            let destination = segue.destination as! ChangeCityViewController
            destination.delegate = self
        }
    }
    
    
    
    
}


