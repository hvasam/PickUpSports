//
//  LocationViewController.swift
//  Pick Up Sports
//
//  Created by Harshavardhan Vasam on 2017-04-11.
//  Copyright © 2017 Harshavardhan Vasam. All rights reserved.
//

import UIKit
import MapKit

class LocationViewController: UIViewController, UITextFieldDelegate, MKLocalSearchCompleterDelegate, UITableViewDataSource, UITableViewDelegate {
    
    struct AddressTextFieldEnclosureProperties {
        static var positionWhileNormal = CGPoint()
        static var positionWhileEditing = CGPoint()
        static var size = CGSize()
    }
    
    struct AutocompleteResultsTableProperties {
        static var positionWhileNormal = CGPoint()
        static var sizeWhileNormal = CGSize()
        static var positionWhileEditing = CGPoint()
        static var sizeWhileEditing = CGSize()
    }
    
    
    //MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressTextFieldEnclosure: UIView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var autocompleteResultsTable: UITableView!
    @IBOutlet weak var addressTextFieldEnclosureYPositionConstraint: NSLayoutConstraint!
    @IBOutlet weak var setLocationButton: UIButton!
    
    
    //MARK: Properties
    var mapViewCancelTapGesture: UITapGestureRecognizer?
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    var numberOfResults: Int {
        return searchResults.count
    }
    weak var delegate: GameCreationDelegate?
    var placemark: MKPlacemark?
    
    //MARK: Actions
    @IBAction func setLocation(_ sender: UIButton) {
        // SAVE SELECTION TO MODEL
        delegate?.locationViewController = self
        saveLocationToDelegate()
        
        // perform segue
        if delegate?.timingsViewController != nil {
            delegate?.pushTimingsViewControllerOnToNavigationStack()
        }
        else {
            performSegue(withIdentifier: "setTimings", sender: sender)
        }
    }
    
    
    //MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up addressTextField delegate, default text, and target-action for textfield changes
        addressTextField.delegate = self
        addressTextField.text = ""
        addressTextField.addTarget(self, action: #selector(addressTextFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        
        // Set up AddressTextFieldEnclosureProperties
        AddressTextFieldEnclosureProperties.positionWhileNormal = addressTextFieldEnclosure.frame.origin
        AddressTextFieldEnclosureProperties.positionWhileEditing = CGPoint(x: addressTextFieldEnclosure.frame.origin.x,
                                                                           y: mapView.frame.origin.y + addressTextFieldEnclosure.frame.size.height)
        AddressTextFieldEnclosureProperties.size = addressTextFieldEnclosure.frame.size
        
        // Set delegate for MKLocalSearchCompleter object
        searchCompleter.delegate = self
        
        // Set up AutocompleteResultsTableProperties
        AutocompleteResultsTableProperties.positionWhileNormal = autocompleteResultsTable.frame.origin
        AutocompleteResultsTableProperties.sizeWhileNormal = autocompleteResultsTable.frame.size
        AutocompleteResultsTableProperties.positionWhileEditing = CGPoint(x: autocompleteResultsTable.frame.origin.x,
                                                                          y: mapView.frame.origin.y + (CGFloat(2) * addressTextFieldEnclosure.frame.size.height))
        AutocompleteResultsTableProperties.sizeWhileEditing = CGSize(width: autocompleteResultsTable.frame.size.width,
                                                                     height: CGFloat(0.8) * mapView.bounds.height)
        
        // autocompleteResultsTable 
        autocompleteResultsTable.dataSource = self
        autocompleteResultsTable.delegate = self
    }
    
    //MARK: UITextFieldDelegate methods
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // hide setLocationButton
        setLocationButton.alpha = 0
        
        // remove constraint on textfield
        addressTextFieldEnclosure.removeConstraint(addressTextFieldEnclosureYPositionConstraint)
        UIView.animate(withDuration: 0.4) { [weak self] in
            self?.addressTextFieldEnclosure.frame = CGRect(origin: AddressTextFieldEnclosureProperties.positionWhileEditing,
                                                           size: AddressTextFieldEnclosureProperties.size)
            self?.autocompleteResultsTable.frame = CGRect(origin: AutocompleteResultsTableProperties.positionWhileEditing,
                                                          size: AutocompleteResultsTableProperties.sizeWhileEditing)
        }
        mapViewCancelTapGesture = UITapGestureRecognizer(target: self, action: #selector(cancelEditing(_:)))
        mapView.addGestureRecognizer(mapViewCancelTapGesture!)
    }
    
    func cancelEditing(_ gesture: UITapGestureRecognizer) {
        addressTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if mapViewCancelTapGesture != nil {
            mapView.removeGestureRecognizer(mapViewCancelTapGesture!)
        }
        UIView.animate(withDuration: 0.4) { [weak self] in
            self?.addressTextFieldEnclosure.frame = CGRect(origin: AddressTextFieldEnclosureProperties.positionWhileNormal,
                                                           size: AddressTextFieldEnclosureProperties.size)
            self?.autocompleteResultsTable.frame = CGRect(origin: AutocompleteResultsTableProperties.positionWhileNormal,
                                                          size: AutocompleteResultsTableProperties.sizeWhileNormal)
        }
    }
    
    func addressTextFieldDidChange(_ textField: UITextField) {
        let text = textField.text ?? ""
        searchCompleter.queryFragment = text
    }
    
    //MARK: MKLocalSearchCompleterDelegate methods
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        autocompleteResultsTable.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // Regardless of the error, inform user that the search could not be performed for the provided string
        searchResults = [MKLocalSearchCompletion]()
        autocompleteResultsTable.reloadData()
    }
    
    //MARK: UITableViewDataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if numberOfResults == 0 {
            return 1 // To display one cell that shows "No results found."
        }
        return numberOfResults
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "searchResult")
        cell.backgroundColor = UIColor(red: CGFloat(184.0/255.0), green: CGFloat(184.0/255.0), blue: CGFloat(184.0/255.0), alpha: CGFloat(1))
        cell.isOpaque = false
        cell.alpha = 0.9
        cell.backgroundView?.backgroundColor = UIColor(red: CGFloat(184/255), green: CGFloat(184/255), blue: CGFloat(184/255), alpha: CGFloat(1))
        cell.backgroundView?.isOpaque = false
        cell.backgroundView?.alpha = 0.9
        if numberOfResults == 0 {
            cell.textLabel?.text = "No results found."
            return cell
        }
        let searchResult = searchResults[indexPath.row]
        cell.textLabel?.text = searchResult.title
        cell.detailTextLabel?.text = searchResult.subtitle
        return cell
    }
    
    //MARK: UITableViewDelegate methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard numberOfResults != 0 else {
            return
        }
        // reset addressTextField back to normal state clear
        addressTextField.resignFirstResponder()
        addressTextField.text = ""
        
        // remove previous annotation/pin
        if let annotation = mapView.annotations.first {
            mapView.removeAnnotation(annotation)
        }

        // set pin (MKAnnotationView object) to chosen address
        let searchRequest = MKLocalSearchRequest(completion: searchResults[indexPath.row])
        let search = MKLocalSearch(request: searchRequest)
        search.start { [weak self] (response, error) in
            if let error = error {
                // handle error scenarios
            }
            guard let response = response, response.mapItems.count > 0 else {
                return
            }
            let firstMapItem = response.mapItems[0]
            let placemark = firstMapItem.placemark
            self?.setLocationOnMapViewGiven(placemark, animated: true)
            
            // show setLocationButton
            self?.setLocationButton.alpha = 1
        }
    }
    
    
    func setLocationOnMapViewGiven(_ placemark: MKPlacemark, animated: Bool) {
        var region = mapView.region
        region.center = (placemark.location?.coordinate)!
        self.placemark = placemark
        region.span.longitudeDelta = 0.015
        region.span.latitudeDelta = 0.015
        mapView.setRegion(region, animated: animated)
        mapView.addAnnotation(placemark)
    }
    
    func saveLocationToDelegate() {
        guard let placemark = placemark else {
            return
        }
        delegate?.address = constructAddressFrom(name: placemark.name,
                                                 locality: placemark.locality,
                                                 administrativeArea: placemark.administrativeArea,
                                                 postalCode: placemark.postalCode)
        delegate?.latitude = placemark.location!.coordinate.latitude
        delegate?.longitude = placemark.location!.coordinate.longitude
    }
    
    func constructAddressFrom(name: String?, locality: String?, administrativeArea: String?, postalCode: String?) -> String {
        // subThoroughfare = street number
        // thoroughFare = street name
        // locality = city
        // administrativeArea = province/state
        
        guard let name = name, let locality = locality, let administrativeArea = administrativeArea, let postalCode = postalCode else {
            return ""
        }
        return name + ", " + locality + ", " + administrativeArea + " " + postalCode
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? TimingsViewController else {
            return
        }
        destinationVC.delegate = delegate
    }
}
