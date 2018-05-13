//
//  MessageComposer.swift
//  iFall
//
//  Created by Sathvik Koneru on 5/8/18.
//  Copyright © 2018 Sathvik Koneru. All rights reserved.
//

import Foundation
import MessageUI

//pickedUsers is the recipient list

class MessageComposer: NSObject, MFMessageComposeViewControllerDelegate {
    
    // A wrapper function to indicate whether or not a text message can be sent from the user's device
    func canSendText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    // Configures and returns a MFMessageComposeViewController instance
    func configuredMessageComposeViewController() -> MFMessageComposeViewController {
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self  //  Make sure to set this property to self, so that the controller can be dismissed!
        //putting values into recipients
        for user in pickedUsers{
            messageComposeVC.recipients?.append(user.identifier)
        }
        messageComposeVC.body =  "Emergency Text Check"
        return messageComposeVC
    }
    
    // MFMessageComposeViewControllerDelegate callback - dismisses the view controller when the user is finished with it
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
