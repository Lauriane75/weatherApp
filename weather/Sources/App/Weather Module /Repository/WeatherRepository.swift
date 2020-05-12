//
//  WeatherRepository.swift
//  weather
//
//  Created by Lauriane Haydari on 12/02/2020.
//  Copyright © 2020 Lauriane Haydari. All rights reserved.
//

import CoreData

protocol WeatherRepositoryType: class {

    // MARK: - Non unique city
    func containsCity(for city: CityVerif) -> Bool

    // MARK: - Get from openWeather API
    func getWeatherList(cityId: String, callback: @escaping (Result<WeatherList>) -> Void, onError: @escaping (String) -> Void)
    func getWeatherId(nameCity: String, country: String, callback: @escaping (Result<Weather>) -> Void, onError: @escaping (String) -> Void)
    func getWeatherWeek(idCity: String, callback: @escaping (Result<WeatherWeek>) -> Void, onError: @escaping (String) -> Void)
    func getLocationWeather(latitude: String, longitude: String, callback: @escaping (Result<WeatherWeek>) -> Void, onError: @escaping (String) -> Void)

    // MARK: - Save in coredata
    func saveCityItem(cityItem: CityItem)
    func saveWeatherListItem(weatherListItem: WeatherListItem)
    func saveWeatherWeekItem(weatherWeekItem: WeatherWeekItem)

    // MARK: - Get from coredata
    func getCityItems(callback: @escaping ([CityItem]) -> Void)
    func getWeatherListItems(callback: @escaping ([WeatherListItem]) -> Void)
    func getWeatherWeekItems(callback: @escaping ([WeatherWeekItem] ) -> Void)
    // MARK: - Delete from coredata
    func deleteAllWeatherListInDataBase()
    func deleteWeatherListItemInDataBase(idCity: String)
    func deleteCityItemInDataBase(idCity: String)
    func deleteWeatherWeekItemInDataBase(idCity: String)
}

final class WeatherRepository: WeatherRepositoryType {

    // MARK: - Properties

    private let token = Token()
    private let context: Context

    private var cityObjects: [CityObject] = []
    private var weatherListObjects: [WeatherListObject] = []
    private var weatherWeekObjects: [WeatherWeekObject] = []

    // MARK: - Initializer

    init(context: Context) {
        self.context = context
    }

    // MARK: - Non unique city

    func containsCity(for city: CityVerif) -> Bool {
        let requestCity: NSFetchRequest<CityObject> = CityObject.fetchRequest()
        guard let cityItems = try? context.stack.context.fetch(requestCity) else { return false }
        self.cityObjects = cityItems
        let cities: [CityItem] = cityItems.map { return CityItem(object: $0) }
        return cities.contains(where: {
            $0.nameCity == city.nameCity.lowercased() &&
                $0.country == city.country.lowercased()
        })
    }

    // MARK: - Get from openWeather API

    func getWeatherList(cityId: String, callback: @escaping (Result<WeatherList>) -> Void, onError: @escaping (String) -> Void) {

        let stringUrl = "http://api.openweathermap.org/data/2.5/group?id=\(cityId)&units=metric&appid=916792210f24330ed8b2f3f603669f4d"
        guard let url = URL(string: stringUrl) else { return }
        context.client.request(type: WeatherList.self,
                               requestType: .GET,
                               url: url,
                               cancelledBy: token) { weather in
                                switch weather {
                                case .success(value: let weatherItem):
                                    let result: WeatherList = weatherItem
                                    callback(.success(value: result))
                                case .error(error: let error):
                                    onError(error.localizedDescription)
                                }
        }
    }

    func getLocationWeather(latitude: String, longitude: String, callback: @escaping (Result<WeatherWeek>) -> Void, onError: @escaping (String) -> Void) {

        let stringUrl = "http://api.openweathermap.org/data/2.5/forecast?lat=\(latitude)&lon=\(longitude)&=metric&appid=916792210f24330ed8b2f3f603669f4d"
        guard let url = URL(string: stringUrl) else { return }
        context.client.request(type: WeatherWeek.self,
                               requestType: .GET,
                               url: url,
                               cancelledBy: token) { weather in
                                switch weather {
                                case .success(value: let weatherItem):
                                    let result: WeatherWeek = weatherItem
                                    callback(.success(value: result))
                                case .error(error: let error):
                                    onError(error.localizedDescription)
                                }
        }
    }

    func getWeatherId(nameCity: String, country: String, callback: @escaping (Result<Weather>) -> Void, onError: @escaping (String) -> Void) {
        let stringUrl = "http://api.openweathermap.org/data/2.5/forecast?q=\(nameCity),\(country)&units=metric&APPID=916792210f24330ed8b2f3f603669f4d"

        guard let url = URL(string: stringUrl) else { return }
        context.client.request(type: Weather.self,
                               requestType: .GET,
                               url: url,
                               cancelledBy: token) { weather in
                                switch weather {
                                case .success(value: let weatherItem):
                                    let result: Weather = weatherItem
                                    callback(.success(value: result))
                                case .error(error: let error):
                                    onError(error.localizedDescription)
                                }
        }
    }

    func getWeatherWeek(idCity: String, callback: @escaping (Result<WeatherWeek>) -> Void, onError: @escaping (String) -> Void) {
        let stringUrl = "http://api.openweathermap.org/data/2.5/forecast?id=\(idCity)&units=metric&appid=916792210f24330ed8b2f3f603669f4d"

        guard let url = URL(string: stringUrl) else { return }
        context.client.request(type: WeatherWeek.self,
                               requestType: .GET,
                               url: url,
                               cancelledBy: token) { weather in
                                switch weather {
                                case .success(value: let weatherWeekItem):
                                    let result: WeatherWeek = weatherWeekItem
                                    callback(.success(value: result))
                                case .error(error: let error):
                                    onError(error.localizedDescription)
                                }
        }
    }

    // MARK: - Save in coredata

    func saveCityItem(cityItem: CityItem) {
        let cityObject = CityObject(context: context.stack.context)
        cityObject.idCity = cityItem.id
        cityObject.nameCity = cityItem.nameCity
        cityObject.countryCity = cityItem.country
        context.stack.saveContext()
    }

    func saveWeatherListItem(weatherListItem: WeatherListItem) {
            let weatherListObject = WeatherListObject(context: self.context.stack.context)
            weatherListObject.idCityListObject = weatherListItem.id
            weatherListObject.countryCityList = weatherListItem.country
            weatherListObject.nameCityList = weatherListItem.nameCity
            weatherListObject.tempCityList = weatherListItem.temperature
            self.context.stack.saveContext()
    }

    func saveWeatherWeekItem(weatherWeekItem: WeatherWeekItem) {
            let weatherObject = WeatherWeekObject(context: self.context.stack.context)
            weatherObject.cityIDWeek = weatherWeekItem.cityId
            weatherObject.nameCityWeek = weatherWeekItem.nameCity
            weatherObject.iconIDWeek = weatherWeekItem.iconID
            weatherObject.timeWeek = weatherWeekItem.time
            weatherObject.tempWeek = weatherWeekItem.temperature
            weatherObject.tempMinWeek = weatherWeekItem.temperatureMin
            weatherObject.tempMaxWeek = weatherWeekItem.temperatureMax
            weatherObject.pressureWeek = weatherWeekItem.pressure
            weatherObject.humidityWeek = weatherWeekItem.humidity
            weatherObject.feelsLikeWeek = weatherWeekItem.feelsLike
            weatherObject.descriptionWeek = weatherWeekItem.description
            self.context.stack.saveContext()
    }

    // MARK: - Get from coredata

    func getWeatherListItems(callback: @escaping ([WeatherListItem]) -> Void) {
        let requestWeatherList: NSFetchRequest<WeatherListObject> = WeatherListObject.fetchRequest()
        guard let weatherListItems = try? context.stack.context.fetch(requestWeatherList) else { return }
        self.weatherListObjects = weatherListItems
        let weatherList: [WeatherListItem] = weatherListItems.map { return WeatherListItem(object: $0) }
        callback(weatherList)
    }

    func getCityItems(callback: @escaping ([CityItem]) -> Void) {
        let requestCity: NSFetchRequest<CityObject> = CityObject.fetchRequest()
        guard let cityItems = try? context.stack.context.fetch(requestCity) else { return }
        self.cityObjects = cityItems
        let city: [CityItem] = cityItems.map { return CityItem(object: $0) }
        callback(city)
    }

    func getWeatherWeekItems(callback: @escaping ([WeatherWeekItem] ) -> Void) {
        let requestWeather: NSFetchRequest<WeatherWeekObject> = WeatherWeekObject.fetchRequest()
        guard let weatherWeekItems = try? context.stack.context.fetch(requestWeather) else { return }
        self.weatherWeekObjects = weatherWeekItems
        let weather: [WeatherWeekItem] = weatherWeekItems.map { return WeatherWeekItem(object: $0) }
        callback(weather)
    }

    // MARK: - Delete from coredata

    func deleteAllWeatherListInDataBase() {
        let requestWeather: NSFetchRequest<WeatherListObject> = WeatherListObject.fetchRequest()
        guard let weatherListItems = try? self.context.stack.context.fetch(requestWeather) else { return }
        guard !weatherListItems.isEmpty else { return }
        self.weatherListObjects = weatherListItems
        self.weatherListObjects.enumerated().forEach { (_, object) in
            self.context.stack.context.delete(object)
            self.context.stack.saveContext()
        }
    }

    func deleteCityItemInDataBase(idCity: String) {
        let requestCity: NSFetchRequest<CityObject> = CityObject.fetchRequest()
        guard let cityItems = try? self.context.stack.context.fetch(requestCity) else { return }
        self.cityObjects = cityItems
        guard let object = self.cityObjects.first(where: { $0.idCity ==
            idCity }) else { return }
        self.context.stack.context.delete(object)
        self.context.stack.saveContext()
    }

    func deleteWeatherListItemInDataBase(idCity: String) {
        let requestWeatherList: NSFetchRequest<WeatherListObject> = WeatherListObject.fetchRequest()
        guard let weatherListItems = try? self.context.stack.context.fetch(requestWeatherList) else { return }
        self.weatherListObjects = weatherListItems
        guard let object = self.weatherListObjects.first(where: { $0.idCityListObject == idCity }) else { return }
        self.context.stack.context.delete(object)
        self.context.stack.saveContext()
    }

    func deleteWeatherWeekItemInDataBase(idCity: String) {
        let requestWeather: NSFetchRequest<WeatherWeekObject> = WeatherWeekObject.fetchRequest()
        guard let weatherItems = try? self.context.stack.context.fetch(requestWeather) else { return }
        self.weatherWeekObjects = weatherItems
        let object = self.weatherWeekObjects.filter { (items) in
            items.cityIDWeek == idCity }
        guard !object.isEmpty else { return}
        object.enumerated().forEach { (_, item) in
            self.context.stack.context.delete(item)
            self.context.stack.saveContext()
        }
    }
}
