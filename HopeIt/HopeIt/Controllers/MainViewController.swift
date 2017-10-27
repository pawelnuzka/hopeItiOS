//
//  MainViewController.swift
//  HopeIt
//
//  Created by Paweł Nużka on 27/10/2017.
//  Copyright © 2017 Paweł Nużka. All rights reserved.
//

import Foundation
import UIKit
import Braintree
import BraintreeDropIn

class PaymentManager {
    func performPayment(nonce: String, amount: Int) {
        print("Performing payment: \(nonce) \(amount)")
    }
}

class PaymentController {
    
    let key: String
    lazy var paymentManager = PaymentManager()
    
    init(key: String = "sandbox_52jzsdhz_7q8gbjg56f3mm6pz") {
        self.key = key
    }
    
    func showDropIn(controler: UIViewController, amount: Int) {
        let request =  BTDropInRequest()
        let dropIn = BTDropInController(authorization: key, request: request)
        { [weak self] (controller, result, error) in
            if (error != nil) {
                print("ERROR")
            } else if (result?.isCancelled == true) {
                print("CANCELLED")
            } else if let nonce = result?.paymentMethod?.nonce {
                self?.paymentManager.performPayment(nonce: nonce, amount: amount)
            }
            controller.dismiss(animated: true, completion: nil)
        }
        controler.present(dropIn!, animated: true, completion: nil)
    }
}

class MainViewController: UIViewController {
    
    @IBOutlet var tipButtons: [UIButton]!

    @IBOutlet weak var payment: UIButton!
    
    lazy var paymentController = PaymentController();
    var selectedAmount: Int = -1
    let amounts = [10, 30, 50]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        payment.isEnabled = false
        payment.setTitle("Wybierz kwotę, by pomóc 👆🏼", for: .normal)
    }
    
    @IBAction func didSelectAmount(_ button: UIButton) {
        payment.setTitle("Pomagam ❤️", for: .normal)
        payment.isEnabled = true
        toggleTipButton(button)
    }
    
    /**
     * Deselects all tip toggle buttons except the one provided.
     */
    private func toggleTipButton(_ button: UIButton) {
        deselectTipButtons()
        button.isSelected = true
        if let index = tipButtons.index(of: button), index < amounts.count {
            selectedAmount = amounts[index]
        } else {
            selectedAmount = -1
        }
    }
    
    private func deselectTipButtons() {
        tipButtons.forEach { $0.isSelected = false }
    }
    
    @IBAction func didSelectPayment(_ sender: Any) {
        paymentController.showDropIn(controler: self, amount: selectedAmount)
    }
    
}
