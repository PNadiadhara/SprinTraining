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
    }

    private func stopRun(){
        infoStackView.isHidden = true
        stopButton.isHidden = true
    }
  
    @IBAction func startTapped(_ sender: Any) {
        startRun()
        print("Start Pressed")
    }
    
    @IBAction func stopTapped(_ sender: Any) {
        stopRun()
    }
    
}
