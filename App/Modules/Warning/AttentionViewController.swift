//
//  AttentionViewController.swift
//  BankexWallet
//
//  Created by Георгий Фесенко on 20/08/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import web3swift



class AttentionViewController: BaseViewController {
    
    
    enum State {
        case PrivateKey,CustomNetwork
    }
    
    
    @IBOutlet weak var descriptionLabel:UILabel!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var heightConstraint:NSLayoutConstraint!
    var isFromDeveloper:Bool = false
    var publicAddress: String?
    var directionSegue:String = ""
    var state:State = .PrivateKey {
        didSet {
            if state == .PrivateKey {
                descriptionLabel.text = NSLocalizedString("Anyone", comment: "")
                titleLabel.text = NSLocalizedString("Private Key", comment: "")
                directionSegue = "showPrivateKey"
            }else {
                descriptionLabel.text = NSLocalizedString("Options", comment: "")
                titleLabel.text = NSLocalizedString("CustomNetworks", comment: "")
                directionSegue = "showCustomNetworks"
            }
        }
    }
    let keysService = SingleKeyServiceImplementation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = heightConstraint.setMultiplier(multiplier: UIDevice.isIpad ? 0.17 : 0.27)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        state = isFromDeveloper ? .CustomNetwork : .PrivateKey
        navigationItem.title = state == .CustomNetwork ? NSLocalizedString("CustomNetworks", comment: "") : NSLocalizedString("Private Key", comment: "")
        navigationController?.setNavigationBarHidden(true, animated: true)
        UIApplication.shared.statusBarView?.backgroundColor = UIDevice.isIpad ? .white : UIColor.errorColor
        UIApplication.shared.statusBarStyle = UIDevice.isIpad ? .default : .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        UIApplication.shared.statusBarStyle = .default
    }
    
    @IBAction func proceed() {
        self.performSegue(withIdentifier: directionSegue, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AddressQRCodeController {
            vc.navTitle = NSLocalizedString("Private Key", comment: "")
            let item = UIBarButtonItem()
            item.title = "Back"
            navigationItem.backBarButtonItem = item
            guard let selectedAddress = publicAddress, let ethAddress = EthereumAddress(selectedAddress) else { return }
            vc.addressToGenerateQR = try? keysService.keystoreManager(forAddress: selectedAddress).UNSAFE_getPrivateKeyData(password: "BANKEXFOUNDATION", account: ethAddress).toHexString()
//            let _ = try! keysService.keystoreManager(forAddress: selectedAddress).UNSAFE_getPrivateKeyData(password: "BANKEXFOUNDATION", account: ethAddress)
        }else if let netwokrsVC = segue.destination as? NetworksViewController {
            netwokrsVC.isFromDeveloper = true
        }
    }
    

    
    @IBAction func back() {
        navigationController?.popViewController(animated: true)
    }
}
