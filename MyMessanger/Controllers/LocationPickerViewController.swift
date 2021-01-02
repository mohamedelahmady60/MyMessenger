//
//  LocationPickerViewController.swift
//  MyMessanger
//
//  Created by Mo Elahmady on 01/01/2021.
//

import UIKit
import CoreLocation
import MapKit


final class LocationPickerViewController: UIViewController {

    //MARK: - Map view
    private let map: MKMapView = {
        let map = MKMapView()
        return map
    }()

    //MARK: - Completion
    public var completion: ((CLLocationCoordinate2D) -> Void)?

    //MARK: - coordinates
    private var coordinates: CLLocationCoordinate2D?
    
    //MARK: - coordinates
    private var isPickable = true
    
    init(coordinates: CLLocationCoordinate2D?) {
        
        if let passedCoordinates = coordinates {
            self.coordinates = passedCoordinates
            self.isPickable = false
        }
        else {
            self.isPickable = true

        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewDidLoad location")
        
        // set title
        view.backgroundColor = .systemBackground
        // if we wanna get a location
        if isPickable {
            
            // add a right button item
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send",
                                                                style: .done,
                                                                target: self,
                                                                action: #selector(didTapSendButton))
            map.isUserInteractionEnabled = true
            let gesture = UITapGestureRecognizer(target: self,
                                                 action: #selector(didTapMap(gesture:)))
            gesture.numberOfTouchesRequired = 1
            gesture.numberOfTapsRequired = 1
            map.addGestureRecognizer(gesture)

        }
        // we will just show the passed location on the map
        else {
            // drop a pin on that location
            guard let currentCoordinates = self.coordinates else {
                return
            }
            let region = MKCoordinateRegion(center: currentCoordinates, latitudinalMeters: 300, longitudinalMeters: 300)
            let pin = MKPointAnnotation()
            pin.coordinate = currentCoordinates
            map.addAnnotation(pin)
            map.setRegion(region, animated: true)
        }
        
        
        // add the map view
        view.addSubview(map)
        
        
    }
    
    
    
    //MARK: - viewDidLayoutSubviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // set the map frame
        map.frame =  view.bounds
    }

    
    //MARK: - Actions
    @objc private func didTapSendButton() {
        guard let coordinates = self.coordinates else {
            return
        }
        // pop the view contoller
        navigationController?.popViewController(animated: true)
        completion?(coordinates)
    }
    
    @objc private func didTapMap(gesture: UIGestureRecognizer) {
        
        // 1- get the location
        let locationInView = gesture.location(in: map)
        let currentCoordinates = map.convert(locationInView, toCoordinateFrom: map)
        self.coordinates = currentCoordinates
        
        // 2- remove the last annotaion so the user cant choose mor then one point (one pin on the map)
        for annotation in map.annotations {
            map.removeAnnotation(annotation)
        }
        
        // 2- drop a pin on that location
        let pin = MKPointAnnotation()
        pin.coordinate = currentCoordinates
        map.addAnnotation(pin)
        
    }

}
