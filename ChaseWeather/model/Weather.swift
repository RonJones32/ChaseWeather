//
//  Weather.swift
//  ChaseWeather
//
//  Created by Ronald Jones on 10/11/23.
//

import Foundation

struct WeatherObj: Codable {
    let dt: Int
    let clouds: Clouds
    let base: String
    let wind: Wind
    let id: Int
    let sys: Sys
    let coord: Coord
    let weather: [Weather]
    let cod: Int
    let name: String
    let visibility: Int
    let timezone: Int
    let main: Main
}
struct Main: Codable {
    let feels_like: Double
    let humidity: Int
    let pressure: Int
    let temp: Double
    let temp_max: Double
    let temp_min: Double
}
struct Wind: Codable {
    let deg: Int
    let speed: Double
}
struct Clouds: Codable {
    let all: Int
}
struct Sys: Codable {
    let country: String
    let id: Int
    let sunrise: Int
    let sunset: Int
    let type: Int
}
struct Coord: Codable {
    let lon: Double
    let lat: Double
}
struct Current: Codable {
    let sunrise: Int
    let sunset: Int
    let temp: Double
    let weather: Weather
}

struct Weather: Codable {
    let main: String
    let icon: String
    let description: String
    let id: Int
}
