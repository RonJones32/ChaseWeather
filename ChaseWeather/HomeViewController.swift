//
//  HomeViewController.swift
//  ChaseWeather
//
//  Created by Ronald Jones on 10/10/23.
//

import UIKit
import CoreLocation

class HomeViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate {
    
    //outlets
    @IBOutlet weak var sunset: UILabel!
    @IBOutlet weak var sunrise: UILabel!
    @IBOutlet weak var tdyLow: UILabel!
    @IBOutlet weak var tdyHigh: UILabel!
    @IBOutlet weak var currentWeather: UILabel!
    @IBOutlet weak var cityLbl: UILabel!
    @IBOutlet weak var currentTemp: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    //variables
    let locationManager = CLLocationManager()
    var currentLoc: CLLocation?
    var searchActive = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //request location
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        //get the location if granted
        checkGranted()
        
        //Dismiss keyboard on touches outside
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
            view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    @objc func dismissKeyboard() {
        self.searchBar.endEditing(true)
    }
    
    func checkGranted() {
        //we do not want to run this on the main UI thread
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                switch self.locationManager.authorizationStatus {
                case .notDetermined, .restricted, .denied:
                    break
                case .authorizedAlways, .authorizedWhenInUse:
                    //set current location
                    self.currentLoc = self.locationManager.location
                    //get todays forecast
                    self.getTodaysWeather()
                    break
                @unknown default:
                    break
                }
            }
        }
    }
    
    func getTodaysWeather() {
        //check if we have a valid location
        if (currentLoc != nil) {
            
            //create api call
            guard let requestUrl = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(String(describing: currentLoc!.coordinate.latitude.description))&lon=\(String(describing: currentLoc!.coordinate.longitude.description))&appid=5b4fb38b309a527c30e69352fcf2c98e") else {
                return
            }
            
            var request = URLRequest(url: requestUrl)
            request.httpMethod = "GET"

            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
                print(response!)
                do {
                    let json = try JSONSerialization.jsonObject(with: data!)
                    print(json)
                    //now we can use the json
                        do {
                            let currentWeather = try JSONDecoder().decode(WeatherObj.self, from: data!)
                            self.setCurrentWeather(weather: currentWeather)
                        }
                        catch {
                            print(error)
                        }
            } catch {
                    print("error")
                    print(error)
                }
            })

            task.resume()
        }
    }
    
    //function to get the information based on search (any geocodable adress works not just the city)
    func searchCity(city: String) {
        let address = city

        //using CLGeocoder since it is a built in resource
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
            else {
                // handle no location found
                self.cityLbl.text = address
                return
            }
            // Use the location
            self.currentLoc = location
            self.getTodaysWeather()
            
        }
    }
    
    func setCurrentWeather(weather: WeatherObj) {
        //set the details on the main thread
        DispatchQueue.main.async {
            self.cityLbl.text = weather.name
            self.currentWeather.text = weather.weather[0].main
            
            //kelvin to farenheit conversion  (K − 273.15) × 9/5 + 32 = °F
            let tdyFHigh = (weather.main.temp_max - 273.15) * 9/5 + 32
            let tdyFLow = (weather.main.temp_min - 273.15) * 9/5 + 32
            let tdyF = (weather.main.temp - 273.15) * 9/5 + 32
            self.currentTemp.text = "Current Temp: \(tdyF.rounded().description)"
            self.tdyHigh.text = "Todays High: \(tdyFHigh.rounded().description)"
            self.tdyLow.text = "Todays Low: \(tdyFLow.rounded().description)"
            
            //convert the times
            let formatter = DateFormatter()
            formatter.timeStyle = .medium
            formatter.dateStyle = .none
            
            let riseTimeInterval = TimeInterval(weather.sys.sunrise)
            let setTimeInterval = TimeInterval(weather.sys.sunset)
            
            let riseDate = Date(timeIntervalSince1970: riseTimeInterval)
            let setDate = Date(timeIntervalSince1970: setTimeInterval)
            
            //set the sunrise with the new fromatted times
            self.sunrise.text = "Sunrise: \(formatter.string(from: riseDate))"
            self.sunset.text = "Sunset: \(formatter.string(from: setDate))"
        }
        
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            // If status has not yet been determied, ask for authorization
            manager.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            // If authorized when in use
            manager.startUpdatingLocation()
            //set current location
            self.currentLoc = manager.location
            //get todays forecast
            self.getTodaysWeather()
            break
        case .authorizedAlways:
            // If always authorized
            manager.startUpdatingLocation()
            //set current location
            self.currentLoc = manager.location
            //get todays forecast
            self.getTodaysWeather()
            print(self.currentLoc as Any)
            break
        case .restricted:
            // If restricted by e.g. parental controls. User can't enable Location Services
            break
        case .denied:
            // If user denied your app access to Location Services, but can grant access from Settings.app
            self.checkLocation()
            break
        default:
            break
        }
    }
    
    
    func checkLocation() {
        //check location settings and allow enabling
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                switch self.locationManager.authorizationStatus {
                case .notDetermined, .restricted, .denied:
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "Location Error", message: "Please enable location settings", preferredStyle: .alert)
                        let OKAction = UIAlertAction(title: "Enable", style: .default, handler: { (action: UIAlertAction) in
                            if let url = URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION_SERVICES") {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        })
                        let canc = UIAlertAction(title: "cancel", style: .default, handler: nil)
                        alertController.addAction(canc)
                        alertController.addAction(OKAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                    break
                case .authorizedAlways, .authorizedWhenInUse:
                    
                    break
                @unknown default:
                    break
                }
            }
            else {
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Location Error", message: "Please enable location settings", preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "Enable", style: .default, handler: { (action: UIAlertAction) in
                        if let url = URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION_SERVICES") {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    })
                    let canc = UIAlertAction(title: "cancel", style: .default, handler: nil)
                    alertController.addAction(canc)
                    alertController.addAction(OKAction)
                }
            }
        }
    }
    
    //Search Functions
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            searchActive = true
        }

        func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            //reset the city
            if searchBar.text?.count == 0 {
                checkGranted()
            }
            searchActive = false
        }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchActive = false;

            searchBar.text = nil
            searchBar.resignFirstResponder()
            self.searchBar.showsCancelButton = false
        }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchActive = false
            searchBar.resignFirstResponder()
        }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        //reset the city
        if searchBar.text?.count == 0 {
            checkGranted()
        }
                    return true
        }


    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //reset the city
        if searchBar.text?.count == 0 {
            checkGranted()
        }

                self.searchActive = true;
                self.searchBar.showsCancelButton = true

                //get the wather info of the city on search updates
                searchCity(city: searchText)
        }
}
