//
//  AssetManagementBtcViewController.swift
//  BankexWallet
//
//  Created by Oleg Kolomyitsev on 29/11/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class AssetManagementBtcViewController: UIViewController {
    
    @IBOutlet private var limitsLabel: UILabel!
    @IBOutlet private var infoLabel: UILabel!
    @IBOutlet private var destinationAddressLabel: UILabel!
    @IBOutlet private var agreementSwitch: UISwitch!
    @IBOutlet private var riskFactorSwitch: UISwitch!
    @IBOutlet private var copyButton: UIButton!
    @IBOutlet private var contactButton: UIButton!
    
    private let destination = "367aqxeq6SqVzaX5qza2HwvfxTJeruLoka"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateView()
    }

    @IBAction private func agreementChecked() {
        updateView()
    }
    
    @IBAction private func riskFactorChecked() {
        updateView()
    }
    
    @IBAction private func openAgreement() {
        let pageURL = URL(string: "https://bankex.com/en/sto/asset-management")!
        
        UIApplication.shared.openURL(pageURL)
    }
    
    @IBAction private func openRiskFactor() {
        let pageURL = URL(string: "https://bankex.com/en/sto/asset-management")!
        
        UIApplication.shared.openURL(pageURL)
    }
    
    @IBAction func finish() {
        performSegue(withIdentifier: "Home", sender: self)
    }
    
}

private extension AssetManagementBtcViewController {
    
    func updateView() {
        
        limitsLabel.text = LocalizedStrings.limits
        infoLabel.text = LocalizedStrings.info
        destinationAddressLabel.text = destination
        
        copyButton.isEnabled = agreementSwitch.isOn && riskFactorSwitch.isOn
    }
}

private extension AssetManagementBtcViewController {
    
    struct LocalizedStrings {
        static let limits = NSLocalizedString("Limits", tableName: "AssetManagementBtcViewController", comment: "")
        static let info = NSLocalizedString("Info", tableName: "AssetManagementBtcViewController", comment: "")

    }
}
