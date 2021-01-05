//
//  WeatherCoordinator.swift
//  weather
//
//  Created by Lauriane Haydari on 12/02/2020.
//  Copyright © 2020 Lauriane Haydari. All rights reserved.
//

import UIKit

final class WeatherCoordinator {

    // MARK: - Properties

    private let navigationController: UINavigationController

    var childCoordinator: CoordinatorProtocol?

    private let screens: Screens

    // MARK: - Initializer

    init(presenter: UINavigationController, screens: Screens) {
        self.navigationController = presenter
        self.screens = screens
    }
}

extension WeatherCoordinator: CoordinatorProtocol {

    // MARK: - Coodinator

    func start() {
        showCityList(cityId: "")
    }

    // MARK: - Create viewControllers

    private func showCityList(cityId: String) {
        let viewController = screens.createSelectViewController(delegate: self, cityId: cityId)
        navigationController.pushViewController(viewController, animated: false)
    }

    private func showWeekWeather(weatherListItem: WeatherListItem) {
        let viewController = screens.createWeekViewController(delegate: self, weatherListItem: weatherListItem)
        navigationController.pushViewController(viewController, animated: true)
    }

    private func showDetailDayWeather(weatherItem: WeatherWeekItem) {
        let viewController = screens.createWeatherDetailViewController(selectedWeatherItem: weatherItem, delegate: self)
        navigationController.pushViewController(viewController, animated: true)
    }

    // MARK: - Alert

    private func showAlert(for type: AlertType) {
        let alert = screens.createAlertView(for: type)
        navigationController.visibleViewController?.present(alert, animated: true, completion: nil)
    }
}

extension WeatherCoordinator: CityListViewModelDelegate {
    func didSelectCity(weatherListItem: WeatherListItem) {
        showWeekWeather(weatherListItem: weatherListItem)
    }

    func displayAlert(for type: AlertType) {
        DispatchQueue.main.async {
            self.showAlert(for: type)
        }
    }
}

extension WeatherCoordinator: WeekViewModelDelegate {

    func displayWeatherAlert(for type: AlertType) {
        DispatchQueue.main.async {
            self.showCityList(cityId: "")
            self.showAlert(for: type)
        }
    }

    func didSelectDay(item: WeatherWeekItem) {
        showDetailDayWeather(weatherItem: item)
    }
}

extension WeatherCoordinator: DetailDayViewModelDelegate {
}

extension WeatherCoordinator: MapViewModelDelegate {
    func goToCityListView(cityId: String) {
        showCityList(cityId: cityId)
    }

}
