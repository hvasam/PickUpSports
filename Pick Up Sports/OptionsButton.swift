//
//  OptionsButton.swift
//
//
//  Created by Harshavardhan Vasam on 2017-04-06.
//
//

import UIKit

class OptionsButton: UIView, UITableViewDelegate, UITableViewDataSource {
    
    struct OptionsListTableViewProperties {
        static let heightRatioToSuperView = CGFloat(0.25)
        static let numberOfSections = 1
        static let numberOfRows = 3
    }
    
    //MARK: Properties
    weak var owningViewController: UIViewController?
    let backgroundCoverView = UIView()
    let optionsList = UITableView()
    let optionsListCellTemplate = UITableViewCell(style: .default, reuseIdentifier: "Standard")
    var createGameCell: UITableViewCell?
    var findGamesCell: UITableViewCell?
    var userSettingsCell: UITableViewCell?
    
    //MARK: Methods
    func setup() {
        guard let owningVC = owningViewController else {
            return
        }
        
        // Add guesture recognizers for tap event
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(presentOptions)))
        
        // Setting up background cover for when optionsButton is used
        backgroundCoverView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: owningVC.view.bounds.size)
        backgroundCoverView.isOpaque = false
        backgroundCoverView.alpha = 0
        backgroundCoverView.backgroundColor = UIColor.black
        backgroundCoverView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideOptions)))
        owningVC.view.addSubview(backgroundCoverView)
        
        // Setting up static tableview for options button
        optionsList.backgroundColor = UIColor.white
        optionsList.isOpaque = true
        optionsList.alpha = 1
        optionsList.frame = CGRect(x: 0,
                                   y: owningVC.view.bounds.maxY,
                                   width: owningVC.view.bounds.width,
                                   height: owningVC.view.bounds.height * OptionsListTableViewProperties.heightRatioToSuperView)
        optionsList.rowHeight = optionsList.frame.size.height / CGFloat(OptionsListTableViewProperties.numberOfRows)
        optionsList.delegate = self
        optionsList.dataSource = self
        owningVC.view.addSubview(optionsList)
        
        // Setting up static tableview cells
        
        // createGameCell
        createGameCell = createOptionsListCell(withText: "Post a game")
        
        // findGamesCell
        findGamesCell = createOptionsListCell(withText: "Find games")
        
        // userSettingsCell
        userSettingsCell = createOptionsListCell(withText: "User settings")
    }
    
    func createOptionsListCell(withText text: String) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Standard")
        cell.textLabel?.text = text
        cell.textLabel?.textAlignment = .center
        return cell
    }
    
    func presentOptions() {
        guard let owningVC = owningViewController else {
            return
        }
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.backgroundCoverView.alpha = 0.7
            self?.optionsList.frame.origin.y = owningVC.view.bounds.maxY - (self?.optionsList.frame.size.height)!
        }
        
    }
    
    // Hide menu options when user selects an option, or cancels it by tapping outside options list
    func hideOptions() {
        guard let owningVC = owningViewController else {
            return
        }
        
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.backgroundCoverView.alpha = 0
            self?.optionsList.frame.origin.y = owningVC.view.bounds.maxY
        }
    }
    
    //MARK: UITableView delegate methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let owningVC = owningViewController else {
            return
        }
        
        if indexPath.row == 0 {
            owningVC.performSegue(withIdentifier: "Post", sender: createGameCell!)
        }
        
        // Hide the options menu once option is chosen and deselect row
        hideOptions()
        tableView.deselectRow(at: indexPath, animated: true)

    }
    
    //MARK: UITableView datasource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OptionsListTableViewProperties.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return createGameCell!
        case 1:
            return findGamesCell!
        case 2:
            return userSettingsCell!
        default:
            return optionsListCellTemplate
        }
    }
    
    deinit {
        // Remove strong refences to allow deinitialization
        if owningViewController != nil {
            backgroundCoverView.removeFromSuperview()
            optionsList.removeFromSuperview()
        }
    }
}
