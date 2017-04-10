//
//  ListOfSportsTableViewController.swift
//  Pick Up Sports
//
//  Created by Harshavardhan Vasam on 2017-04-09.
//  Copyright © 2017 Harshavardhan Vasam. All rights reserved.
//

import UIKit

class ListOfSportsTableViewController: UITableViewController {

    //MARK: Outlets
    @IBOutlet weak var badmintonCell: UITableViewCell!
    @IBOutlet weak var basketballCell: UITableViewCell!
    @IBOutlet weak var footballCell: UITableViewCell!
    @IBOutlet weak var rugbyCell: UITableViewCell!
    @IBOutlet weak var soccerCell: UITableViewCell!
    @IBOutlet weak var softballCell: UITableViewCell!
    @IBOutlet weak var tennisCell: UITableViewCell!
    @IBOutlet weak var ultimateCell: UITableViewCell!
    @IBOutlet weak var volleyballCell: UITableViewCell!
    
    //MARK: Properties
    private weak var previouslySelectedCell: UITableViewCell?
    // Use if rootViewController is not != self
    //weak var listOfSportsTableViewControllerDelegate: ListOfSportsTableViewControllerDelegate?
    let numberOfSections = 1
    let numberOfRows = 9
    
    //MARK: Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use if rootViewController is not != self
        // Set previouslySelectedCell if delegate was previously set
        // setPreviouslySelectedCellTo(sport: listOfSportsTableViewControllerDelegate!.selectedSport)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // get newly selected cell
        let newlySelectedCell = self.tableView(tableView, cellForRowAt: indexPath)
        
        // check to see if the selected cell already has a checkmark
        guard newlySelectedCell != previouslySelectedCell else {
            return
        }
        
        // remove checkmark of previously selected item - if there is one
        if let cell = previouslySelectedCell {
            cell.accessoryType = .none
        }
        
        // set checkmark of newly selected cell
        newlySelectedCell.accessoryType = .checkmark
        previouslySelectedCell = newlySelectedCell
        
        // save the change to delegate variable, selectedSport
        // listOfSportsTableViewControllerDelegate?.selectedSport = newlySelectedCell.textLabel!.text!
    }
    
    
    // Use if rootViewController is not != self
    /*
    // Use this function to set the previouslySelectedCell when being segued to IF
    // a sport was previously set on the delegate
    func setPreviouslySelectedCellTo(sport: String) {
        switch sport {
        case "Badminton": previouslySelectedCell = badmintonCell
        case "Basketball": previouslySelectedCell = basketballCell
        case "Football": previouslySelectedCell = footballCell
        case "Rugby": previouslySelectedCell = rugbyCell
        case "Soccer": previouslySelectedCell = soccerCell
        case "Softball": previouslySelectedCell = softballCell
        case "Tennis": previouslySelectedCell = tennisCell
        case "Ultimate": previouslySelectedCell = ultimateCell
        case "Volleyball": previouslySelectedCell = volleyballCell
        default: break // previouslySelectedCell will not be set
        }
        previouslySelectedCell?.accessoryType = .checkmark
    }
    */
}

// Use if rootViewController is not != self
/*
protocol ListOfSportsTableViewControllerDelegate: class {
    var selectedSport: String { get set }
}
*/
