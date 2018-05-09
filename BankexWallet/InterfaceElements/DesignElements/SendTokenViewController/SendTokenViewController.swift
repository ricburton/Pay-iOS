//
//  SendTokenViewController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina  on 4/8/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit
import QRCodeReader
import AVFoundation
import web3swift

class SendTokenViewController: UIViewController,
UITextFieldDelegate,
QRCodeReaderViewControllerDelegate {

    //MARK: Outlets
    
    @IBOutlet weak var additionalDataView: UIView!
    @IBOutlet weak var dataTopEmptyView: UIView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var topTokenSymbolLabel: UILabel!
    @IBOutlet weak var tokenIconImageView: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet var favNameContainer: UIView!
    
    @IBOutlet weak var selectedFavNameLabel: UILabel!
    
    @IBOutlet weak var enterAddressTextfield: UITextField!
    
    @IBOutlet weak var memoTextfield: UITextField!
    @IBOutlet weak var amountTextfield: UITextField!
    @IBOutlet var textFields: [UITextField]!
    
    @IBOutlet var separators: [UIView]!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet var additionalInputContainerView: UIView!
    
    @IBOutlet weak var insertFromClipboardButton: UIButton!
    
    @IBOutlet weak var tokenSymbolLabel: UILabel!
    
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var interDataAndBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var additionalDataSeparator: UIView!
    // MARK: Services
    var sendEthService: SendEthService!
    let tokensService = CustomERC20TokensServiceImplementation()
    var utilsService: UtilTransactionsService!

    // MARK: Lifecycle
    @IBAction func back(segue:UIStoryboardSegue) { }

    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.isEnabled = false

        favNameContainer.removeFromSuperview()
        dataTopEmptyView.removeFromSuperview()
        additionalDataView.removeFromSuperview()
        additionalDataSeparator.removeFromSuperview()
        
        // Do any additional setup after loading the view.
        sendEthService = tokensService.selectedERC20Token().address.isEmpty ?
            SendEthServiceImplementation() :
            ERC20TokenContractMethodsServiceImplementation()
        utilsService = tokensService.selectedERC20Token().address.isEmpty ? UtilTransactionsServiceImplementation() :
            CustomTokenUtilsServiceImplementation()
        updateBalance()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let fixedFrame = view.convert(stackView.frame, from: stackView.superview)
        let size = stackView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        let availableSpace = view.frame.height - size.height - fixedFrame.minY - 96 - 25
        interDataAndBottomConstraint.constant = availableSpace < 25 ? 25 : availableSpace
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showConfirmation",
        let confirmation = segue.destination as? SendingConfirmationController else {
            return
        }
        confirmation.amount = amountToSend
        confirmation.destinationAddress = destinationAddressToSend
        confirmation.transaction = transactionToSend
        confirmation.inputtedPassword = passwordTextfield.text
    }

    // MARK: Actions
    @IBAction func nextButtonTapped(_ sender: Any) {
        guard let amount = amountTextfield.text,
            let destinationAddress = enterAddressTextfield.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else {
                return
        }
        sendEthService.prepareTransactionForSending(destinationAddressString: destinationAddress, amountString: amount) { (result) in
            switch result {
            case .Success(let transaction):
                self.showConfirmation(forSending: amount, destinationAddress: destinationAddress, transaction: transaction)
            case .Error(let error):
                print("\(error)")
            }
        }
    }
    
    
    @IBAction func switchPasswordVisibility(_ sender: UIButton) {
        passwordTextfield.isSecureTextEntry = !passwordTextfield.isSecureTextEntry
        sender.setImage(passwordTextfield.isSecureTextEntry ? #imageLiteral(resourceName: "Eye open") : #imageLiteral(resourceName: "Eye closed"), for: .normal)
    }
    
    @IBAction func clearAddressTapped(_ sender: Any) {
        enterAddressTextfield.text = ""
    }
    
    @IBAction func scanQRTapped(_ sender: Any) {
        readerVC.delegate = self
        
        // Or by using the closure pattern
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in        }
        
        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true, completion: nil)
    }
    
    @IBAction func addFromFavouritesTapped(_ sender: Any) {
        // TODO: Open favs list
    }
    
    @IBAction func insertFromClipboardTapped(_ sender: Any) {
        enterAddressTextfield.text = UIPasteboard.general.string
    }
    
    @IBAction func deleteSelectedFavTapped(_ sender: Any) {
    }

    @IBAction func emptySpaceTapped(_ sender: Any) {
        view.endEditing(false)
    }
    
    // MARK: TextField Delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let index = textFields.index(of: textField) ?? 0
        separators[index].backgroundColor = WalletColors.blueText.color()
        textField.textColor = WalletColors.blueText.color()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text ?? "")  as NSString
        let futureString = currentText.replacingCharacters(in: range, with: string) as String
        nextButton.isEnabled = false

        switch textField {
        case enterAddressTextfield:
            if  !(amountTextfield.text?.isEmpty ?? true) &&
                !(passwordTextfield.text?.isEmpty ?? true) &&
                !futureString.isEmpty {
                nextButton.isEnabled = true
            }
        case passwordTextfield:
            if !(amountTextfield.text?.isEmpty ?? true) &&
                !(enterAddressTextfield.text?.isEmpty ?? true) &&
                !futureString.isEmpty {
                    nextButton.isEnabled = true
            }
        case amountTextfield:
            if !(passwordTextfield.text?.isEmpty ?? true) &&
                !(enterAddressTextfield.text?.isEmpty ?? true) &&
                !futureString.isEmpty
            {
                nextButton.isEnabled = true
            }
        default:
            nextButton.isEnabled = false
        }
        
        nextButton.backgroundColor = nextButton.isEnabled ? WalletColors.defaultDarkBlueButton.color() : WalletColors.disableButtonBackground.color()
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        let index = textFields.index(of: textField) ?? 0
        separators[index].backgroundColor = WalletColors.greySeparator.color()
        textField.textColor = WalletColors.defaultText.color()
        
        
        if textField == amountTextfield {
            guard let _ = Float((amountTextfield.text ?? "")) else {
                let amountIndex = textFields.index(of: amountTextfield) ?? 0
                separators[amountIndex].backgroundColor = WalletColors.errorRed.color()
                amountTextfield.textColor = WalletColors.errorRed.color()
                return true
            }
        }
        return true
    }
    
    // MARK: QR Code scan
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    // MARK: - QRCodeReaderViewController Delegate Methods
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        var value = result.value
        if !value.hasPrefix("0x") {
            value = "0x" + value
        }
        enterAddressTextfield.text = value
        dismiss(animated: true, completion: nil)
    }
    

    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Balance
    let keysService: SingleKeyService = SingleKeyServiceImplementation()
    func updateBalance() {
        topTokenSymbolLabel.text = tokensService.selectedERC20Token().symbol
        tokenSymbolLabel.text = tokensService.selectedERC20Token().symbol

        tokenIconImageView.image = PredefinedTokens(with: tokensService.selectedERC20Token().name ).image()
        guard let selectedAddress = keysService.selectedAddress() else {
            return
        }
        utilsService.getBalance(for: tokensService.selectedERC20Token().address, address: selectedAddress) { (result) in
            switch result {
            case .Success(let response):
                print("\(response)")
                // TODO: it shouldn't be here anyway and also, lets move to background thread
                let formattedAmount = Web3.Utils.formatToEthereumUnits(response, toUnits: .eth, decimals: 4)
                self.balanceLabel.text = formattedAmount!
            case .Error(let error):
                print("\(error)")
            }
        }
    }
    
    // MARK: Confirmation
    var amountToSend: String?
    var destinationAddressToSend: String?
    var transactionToSend: TransactionIntermediate?
    func showConfirmation(forSending amount: String,
                          destinationAddress:String,
                          transaction: TransactionIntermediate) {
        amountToSend = amount
        destinationAddressToSend = destinationAddress
        transactionToSend = transaction
        performSegue(withIdentifier: "showConfirmation", sender: self)
    }
}
