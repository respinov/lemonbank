//
//  LemonBankViewController.swift
//  LemonBankSwift
//
//  Copyright © 2020 ThreatMetrix. All rights reserved.
//

import UIKit
import CoreLocation

class LemonBankViewController: UIViewController ,UITextFieldDelegate
{
    @IBOutlet weak var accountText:   UITextField!
    @IBOutlet weak var passwordText:  UITextField!
    @IBOutlet weak var loginButton:   UIButton!
    @IBOutlet weak var logoutButton:  UIButton!
    @IBOutlet weak var webView:       UIWebView!
    @IBOutlet weak var busyIndicator: UIActivityIndicatorView!
    @IBOutlet      var td:            LemonBankProfileController!

    var locationManager:CLLocationManager!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        // request accessing location while application is in used
        locationManager.requestWhenInUseAuthorization()
        showLoginWidgets()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func prepareLogin(_ sender: AnyObject)
    {
        // Here we want do a quick sanity check that the account/password has some value
        if(accountText.text!.count <= 0)
        {
            return
        }
        if(passwordText.text!.count <= 0)
        {
            return
        }

        // enable spinner to indicate we are doing stuff
        showBusy()
        while(!td.loginOkay)
        {
            print("Profiling isn't complete yet, show a spinner while we wait")

            // If profiling isn't complete, wait before submitting
            RunLoop.current.run(mode: RunLoop.Mode.default, before:Date().addingTimeInterval(td.profileTimeout))
        }

        print("Profiling complete, go ahead with login immediately")
        showDataWidgets()
    }

    @IBAction func prepareLogout(_ sender: AnyObject)
    {
        showLoginWidgets()
    }

    func showBusy()
    {
        print("show busy ui");
        accountText.isEnabled  = false;
        passwordText.isEnabled = false;
        loginButton.isEnabled  = false;
        busyIndicator.isHidden = false;
        busyIndicator.hidesWhenStopped = true;
        busyIndicator.startAnimating();
    }

    func endBusy()
    {
        print("end busy ui");
        accountText.isEnabled  = true;
        passwordText.isEnabled = true;
        loginButton.isEnabled  = true;
        busyIndicator.isHidden = true;
        busyIndicator.stopAnimating();
    }

    func showLoginWidgets()
    {
        webView.isHidden      = true
        endBusy()

        td.doProfile()

        accountText.text      = nil
        passwordText.text     = nil
        accountText.becomeFirstResponder()
        logoutButton.isHidden = true
    }

    func showDataWidgets()
    {
        print("Submitting login details to server")

        //Clear the content of webview to avoid confusion
        webView.loadRequest(URLRequest(url:URL(string:"about:blank")!))       
        endBusy()

        let session : String     = td.sessionID;
        let username: String     = accountText.text!
        let password: String     = passwordText.text!

        // Send the session id to the back end.
        // a POST is probably preferred here
        let temp: String = String("https://tdmobile.threatmetrix.com/mobile_5.php?type=1&session_id=\(session)&username=\(username)&password=\(password)")
        let url: URL = URL(string: temp)!
        let theRequest: NSMutableURLRequest = NSMutableURLRequest(url: url as URL)
        theRequest.httpMethod = "GET"

        // We don't actually have another view or XIB, we just
        // show a webview and load some server side info in it
        webView.isHidden      = false;
        webView.loadRequest(theRequest as URLRequest)
        logoutButton.isHidden = false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if(textField == accountText)
        {
            passwordText.becomeFirstResponder()
        }
        else if(textField == passwordText)
        {
            textField.resignFirstResponder()
            prepareLogin(loginButton)
        }
        return true
    }
}

