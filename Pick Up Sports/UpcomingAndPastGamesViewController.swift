//
//  UpcomingAndPastGamesViewController.swift
//  
//
//  Created by Harshavardhan Vasam on 2017-04-05.
//
//

import UIKit

class UpcomingAndPastGamesViewController: UIViewController {

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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        optionsButtonManager.setup()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
