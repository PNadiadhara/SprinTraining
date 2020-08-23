//
//  TrainingViewController.swift
//  SprintTrainer
//
//  Created by Pritesh Nadiadhara on 8/22/20.
//  Copyright © 2020 PriteshN. All rights reserved.
//

import UIKit
import MapKit

class TrainingViewController: UIViewController {
    
    //hidding an element on the stack I.E. a button will cause it to use all the room in the stack on the story board
    @IBOutlet weak var infoStackView: UIStackView!
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var stopButton: UIButton!
    
   
    
    private var run: Run?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        view.backgroundColor = UIColor.green
        
    }
    
    private func startRun(){
        infoStackView.isHidden = false
        startButton.isHidden = true
        stopButton.isHidden = false
    }

    private func stopRun(){
        infoStackView.isHidden = true
        stopButton.isHidden = true
        startButton.isHidden = false
    }
  
    @IBAction func startTapped(_ sender: Any) {
        startRun()
        print("Start Pressed")
    }
    
    @IBAction func stopTapped(_ sender: Any) {
        stopRun()
        
        let alertController = UIAlertController(title: "Finish Run?", message: "", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { (UIAlertAction) in
            self.stopRun()
            self.performSegue(withIdentifier: .details, sender: nil)
        }))
        alertController.addAction(UIAlertAction(title: "Discard", style: .destructive, handler: { (UIAlertAction) in
            self.stopRun()
            _ = self.navigationController?.popViewController(animated: true)
        }))
        
        present(alertController, animated: true)
        
    }
    
}

extension TrainingViewController : SegueHandlerType {
    enum SegueIdentifier: String {
        case details = "RunDetailsViewController"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .details:
            let destination = segue.destination as! RunDetailsViewController
            destination.run = run
        }
    }
}
