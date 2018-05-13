//
//  EntryViewController.swift
//  iFall
//
//  Created by Sathvik Koneru on 4/9/18.
//  Copyright © 2018 Sathvik Koneru. All rights reserved.
//

import Foundation
import UIKit
import CoreMotion
import ChameleonFramework
import MessageUI

var userName: String = ""

class EntryViewController: UIViewController {
    
    //creating motion manager instance for collecting accelerometer data
    let motion = CMMotionManager()
    var timer = Timer()
    
    //creating instance of message composer
    let messageComposer = MessageComposer()
    
    @IBOutlet weak var fallIndicator: UILabel!
    @IBOutlet weak var button: UIButton!
    
    //setting up views
    override func viewDidLoad() {
        super.viewDidLoad()
        Chameleon.setGlobalThemeUsingPrimaryColor(FlatCoffeeDark(), with: .contrast)
        styleButton()
        view.backgroundColor = UIColor.flatWhite
        self.navigationController?.hidesNavigationBarHairline = true
        
        print("Entered Main screen")
        //animated circle stuff -> insert
        
        //accelerometer stuff
        startAccelerometers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func styleButton() {
        button.layer.cornerRadius = 10
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    //showing input for name prompt
    @IBAction func infoButtonPopup(_ sender: Any) {
        showInputDialog()
    }
    
    func showInputDialog() {
        //Creating UIAlertController and
        //Setting title and message for the alert dialog
        let alertController = UIAlertController(title: "Enter Details", message: "Enter your name:", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            //getting the input values from user
            userName = (alertController.textFields?[0].text)!
            print(userName)
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter Name"
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    
    //getting accelerometer data @ 10 Hz
    func startAccelerometers() {
        
        var x_acc: [Double] = []
        var y_acc: [Double] = []
        var z_acc: [Double] = []
        
        // Making sure the accelerometer hardware is available.
        if self.motion.isAccelerometerAvailable {
            self.motion.accelerometerUpdateInterval = 1.0 / 10.0  // 10 Hz = 10 times per second
            self.motion.startAccelerometerUpdates()
            
            var start = DispatchTime.now() // <<<<<<<<<< Start time
            
            // Configure a timer to fetch the data.
            self.timer = Timer(fire: Date(), interval: (1.0/10.0),
               repeats: true, block: { (timer) in
                // Get the accelerometer data.
                if let data = self.motion.accelerometerData {
                    let x = data.acceleration.x
                    let y = data.acceleration.y
                    let z = data.acceleration.z
                    
                    // Use the accelerometer data in your app.
                    //print("x is: \(x) y is: \(y) z is: \(z)")
                    x_acc.append(x)
                    y_acc.append(y)
                    z_acc.append(z)
                    
                    //calculate
                    if x_acc.count == 100 {
                        print("entered inital if")
                        
                        //standard dev - x
                        var sum_x = 0.00
                        for value in x_acc{
                            sum_x += value
                        }
                        //mean of x-axis data
                        let mean_x = sum_x/Double(x_acc.count)
                        
                        //standard dev - z
                        var sum_z = 0.00
                        for value in z_acc{
                            sum_z += value
                        }
                        //mean of z-axis data
                        let mean_z = sum_z/Double(z_acc.count)
                        
                        //finding feature and comparing it to thresholded value
                        findFall: for value_x in x_acc{
                            for value_z in z_acc{
                                let stdev_x = self.standardDeviation(mean: mean_x, N: Double(x_acc.count), x: value_x)
                                let stdev_z = self.standardDeviation(mean: mean_z, N: Double(z_acc.count), x: value_z)
                                //magnitutde of standard
                                let stdevMagHorizontalPlane = ((stdev_x*stdev_x)+(stdev_z*stdev_z)).squareRoot()
                                print(stdevMagHorizontalPlane)
                                if stdevMagHorizontalPlane > 0.2 {
                                    print("fall!")
                                    self.fallIndicator.text = "You have fallen!!"
                                    break findFall
                                }
                            }
                        }
                        
                        //refreshing arrays
                        x_acc = []
                        y_acc = []
                        z_acc = []
                        
                        //check the length of x_acc to make sure refresh occurs
                        //print("length of x_acc is \(x_acc.count)")
                        
                        //getting time taking
                        let end = DispatchTime.now()   // <<<<<<<<<<   end time
                        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
                        let timeInterval = Double(nanoTime) / 1_000_000_000 // Technically could overflow for long running tests
                        print("Time to evaluate: \(timeInterval) seconds")
                        start = DispatchTime.now() // <<<<<<<<<< Start time
                        
                        if self.fallIndicator.text == "You have fallen!!" {
                            print("About to send text")
                            self.sendEmergencyText()
                        }
                    }
                }
            })
            
            // Add the timer to the current run loop.
            RunLoop.current.add(self.timer, forMode: .defaultRunLoopMode)
        }
    }
    
    func standardDeviation(mean: Double, N: Double, x: Double) -> Double{
        let variance = (x - mean) * (x - mean)
        let stdev = (variance/N).squareRoot()
        return stdev
    }
    
    //emergency text - fix and change to twillio
    func sendEmergencyText() {
        
        // Make sure the device can send text messages
        if !MFMessageComposeViewController.canSendText() {
            print("SMS services are not available")
        }else{
                //fill this stuff in
        }
        
        if (messageComposer.canSendText()) {
            // Obtain a configured MFMessageComposeViewController
            let messageComposeVC = messageComposer.configuredMessageComposeViewController()
            
            // Present the configured MFMessageComposeViewController instance
            present(messageComposeVC, animated: true, completion: nil)
        } else {
            // Let the user know if his/her device isn't able to send text messages
            print("Can't send the text")
            //let errorAlert = UIAlertView(title: "Cannot Send Text Message", message: "Your device is not able to send text messages.", delegate: self, cancelButtonTitle: "OK")
            //errorAlert.show()
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
}
