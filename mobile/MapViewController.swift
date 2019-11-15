//
//  MapViewController.swift
//  mobile
//
//  Created by Groylov on 07/05/2019.
//  Copyright © 2019 esbyt. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    private var locationManager: CLLocationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    private var arrayMap: [StructMap] = []
    private var arrayDistancionMap: [Int] = []
    private var countSubview: Int = 0
    
    /// Функция расчета растояния до точки и занисение данных о ростояние в массив (НЕИСПОЛЬЗУЕТСЯ)
    ///
    /// - Parameter ePoint: Данные точки для которой расчитывается растояние
    private func calcDistancion(point ePoint: StructMap) {
        if currentLocation == nil {
            arrayDistancionMap.append(0)
        } else {
            let ePointLat = ePoint.getLatitude()
            let ePointLng = ePoint.getLongitude()
            if ePointLat == 0 || ePointLng == 0 {
                arrayDistancionMap.append(0)
            }
            let startPlacemarket = MKPlacemark(coordinate: currentLocation!.coordinate)
            
            let coordinateEndPlacemarket = CLLocationCoordinate2D(latitude: ePointLat, longitude: ePointLng)
            let endPlacemarket = MKPlacemark(coordinate: coordinateEndPlacemarket)
            let startItem = MKMapItem(placemark: startPlacemarket)
            let endItem = MKMapItem(placemark: endPlacemarket)
            
            let directionRequest = MKDirections.Request()
            directionRequest.source = startItem
            directionRequest.destination = endItem
            directionRequest.transportType = .automobile
            let directions = MKDirections(request: directionRequest)
            directions.calculate(completionHandler: { (response, error) in
                if response != nil {
                    if response!.routes.count > 0 {
                        let route = response!.routes[0]
                        let distanceMetrs: Int = Int(route.distance)
                        self.arrayDistancionMap.append(distanceMetrs)
                    }
                }
                self.arrayDistancionMap.append(0)
            })
        }
    }
    
    /// Функция ннесения на карту точек объектов по координатам из массива точек
    private func addAnnotationPoint() {
        // удаляем анатации с карты
        let allAnnotation = mapView.annotations
        if allAnnotation.count != 0 {
            mapView.removeAnnotations(allAnnotation)
        }
        // размещаем все объекты на карте
        arrayMap = dataAccount.maps
        var arrayAnnotations: [MKPointAnnotation] = []
        for recMap in arrayMap {
            let newPointAnnotation = MKPointAnnotation()
            if recMap.title != nil {
                newPointAnnotation.title = recMap.title
            }
            if recMap.addr != nil {
                newPointAnnotation.subtitle = recMap.addr
            }
            let latMap = recMap.getLatitude()
            let lngMap = recMap.getLongitude()
            
            if latMap != 0 && lngMap != 0 {
                newPointAnnotation.coordinate = CLLocationCoordinate2D(latitude: latMap, longitude: lngMap)
                arrayAnnotations.append(newPointAnnotation)
            }
        }
        mapView.showAnnotations(arrayAnnotations, animated: true)
    }
    
    /// Функция открытия формы с информацией о точке
    ///
    /// - Parameters:
    ///   - ePoint: данные точки
    ///   - dist: растояние от текущего местоположения до точки
    private func openAnnotationInfo(point ePoint: StructMap?, distance dist: Int?) {
        if ePoint != nil {
            if view.subviews.count == countSubview {
                if let detailMapVC = storyboard!.instantiateViewController(withIdentifier: "detailMapViewController") as? DetailMapViewController {
                    detailMapVC.mapData = ePoint!
                    detailMapVC.distancionMap = dist
                    self.addChild(detailMapVC)
                    detailMapVC.view.frame = self.view.frame
                    self.view.addSubview(detailMapVC.view)
                    detailMapVC.didMove(toParent: self)
                }
            }
        }
    }
    
    /// Обработка события открытия формы
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countSubview = view.subviews.count
        
        // настройка дизайна ViewController
        setNavigationColor(self)
        
        addAnnotationPoint()
        // установка делегатов
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // проверка работы сервиса и получение разрешения
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    /// Функция определения геолокации пользователя и размещение точки на карте
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer { currentLocation = locations.last }
        
        if currentLocation == nil {
            // Zoom to user location
            if let userLocation = locations.last {
                let viewRegion = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
                mapView.setRegion(viewRegion, animated: false)
            }
        }
    }
    
    /// Функция обработки нажатия на точку на карте
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let mapData = view.getMapData(arrayMap: arrayMap)
        mapView.selectedAnnotations = []
        if mapData != nil {
            openAnnotationInfo(point: mapData, distance: nil)
        } else {
            if view.annotation != nil {
                var region = mapView.region
                region.center = view.annotation!.coordinate
                region.span.latitudeDelta /= 2.0
                region.span.longitudeDelta /= 2.0
                mapView.setRegion(region, animated: true)
            }
        }
    }
    
    /// Функция обработка события нажатия на кнопку увеличения маштаба
    @IBAction func zoomInTouch(_ sender: Any) {
        var region: MKCoordinateRegion = mapView.region
        region.span.latitudeDelta /= 2.0
        region.span.longitudeDelta /= 2.0
        mapView.setRegion(region, animated: true)
    }
    
    /// Функция обработка события нажатия на кнопку уменьшения маштаба
    @IBAction func zoomOutTouch(_ sender: Any) {
        var region: MKCoordinateRegion = mapView.region
        region.span.latitudeDelta = min(region.span.latitudeDelta * 2.0, 180.0)
        region.span.longitudeDelta = min(region.span.longitudeDelta * 2.0, 180.0)
        mapView.setRegion(region, animated: true)
    }
    
    /// Функция обработки события нажатия на кнопку перемещения на текущее место положение пользователя
    @IBAction func currentLocalTouch(_ sender: Any) {
        if currentLocation != nil {
            // Zoom to user location
            let viewRegion = MKCoordinateRegion(center: currentLocation!.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
                mapView.setRegion(viewRegion, animated: true)
        }
    }
    
    /// Функция обработки события открытия окна
    override func viewDidAppear(_ animated: Bool) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        addAnnotationPoint()
    }
    
    /// Функция обработки события закрытия окна
    override func viewDidDisappear(_ animated: Bool) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.stopUpdatingLocation()
        }
    }
}
