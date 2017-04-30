//
//  UpcomingAndPastGamesViewController.swift
//  
//
//  Created by Harshavardhan Vasam on 2017-04-05.
//
//

import UIKit

class UpcomingAndPastGamesViewController: UIViewController, PostGameNavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    //MARK: Outlets
    @IBOutlet weak var gamesTab: UIView! {
        didSet {
            gamesTab.layer.cornerRadius = 7
        }
    }
    @IBOutlet weak var upcomingGamesButton: UIButton! {
        didSet {
            upcomingGamesButton.layer.borderWidth = CGFloat(0.5)
            upcomingGamesButton.layer.borderColor = UIColor.blue.cgColor
        }
    }
    @IBOutlet weak var pastGamesButton: UIButton! {
        didSet {
            pastGamesButton.layer.borderWidth = CGFloat(0.5)
            pastGamesButton.layer.borderColor = UIColor.blue.cgColor
        }
    }
    @IBOutlet weak var optionsButtonManager: OptionsButtonManager! {
        didSet {
            optionsButtonManager.owningViewController = self
        }
    }
    @IBOutlet weak var upcomingGamesTableView: UITableView! {
        didSet {
            upcomingGamesTableView.delegate = self
            upcomingGamesTableView.dataSource = self
        }
    }
    
    //MARK: Properties
    var upcomingGamesArray = [Game]() {
        didSet {
            upcomingGamesTableView.reloadData()
        }
    }
    
    //MARK: Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        optionsButtonManager.setup()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueIdentifier = segue.identifier else { return }
        
        if segueIdentifier == "Post" {
            guard let destinationVC = segue.destination as? PostGameNavigationController else { return }
            destinationVC.postGameDelegate = self
        }
    }
    
    func addGameToUpcomingGamesArray(_ newGame: Game) {
        // The upcomingGamesArray is already sorted by ascending date. The new game must be added to maintain the order property.
        let newGameStartTimeAsInteger = Int(newGame.startTime)!
        for index in 0..<upcomingGamesArray.count {
            let gameStartTimeAsInteger = Int(upcomingGamesArray[index].startTime)!
            if newGameStartTimeAsInteger <= gameStartTimeAsInteger {
                upcomingGamesArray.insert(newGame, at: index)
                return
            }
        }
        upcomingGamesArray.append(newGame)
        return
    }
    
    //MARK: Table view data source methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return upcomingGamesArray.count
    }
    
    //MARK: Table view delegate methods
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = upcomingGamesTableView.dequeueReusableCell(withIdentifier: "GameCell") as! GameCell
        let cellInfo = upcomingGamesArray[indexPath.row]
        cell.sportAndTimeLabel.text = cellInfo.sport + " @ " + cellInfo.startTimeInDisplayFormat
        cell.locationLabel.text = cellInfo.locationAddress
        cell.monthLabel.text = cellInfo.abbreviatedMonthString
        cell.dayLabel.text = cellInfo.dayOfStartTime
        //cell.dayLabel.text = cellInfo.dayOfStartTime
        return cell
    }
    
}
