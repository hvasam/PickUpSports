//
//  ListOfSportsTableViewController.swift
//  Pick Up Sports
//
//  Created by Harshavardhan Vasam on 2017-04-09.
//  Copyright © 2017 Harshavardhan Vasam. All rights reserved.
//

import UIKit
import Dispatch

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
    let numberOfSections = 1
    let numberOfRows = 9
    
    //MARK: Methods

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
        
        // SAVE SELECTION TO MODEL
        
        // segue to ...
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(500)) { [weak self] in
            self?.performSegue(withIdentifier: "setLocation", sender: self)
        }
        
    }
}
