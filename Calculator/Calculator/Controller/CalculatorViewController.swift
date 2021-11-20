//
//  Calculator - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

class CalculatorViewController: UIViewController {
    @IBOutlet weak var operandLabel: UILabel?
    @IBOutlet weak var operatorLabel: UILabel?
    @IBOutlet weak var countingHistoryStackView: UIStackView?
    @IBOutlet weak var countingHistoryScrollView: UIScrollView!
    
    private let numberFormatter = NumberFormatter()
    private var textInput = ""
    private var countingHistory = ""
    private var operandText = ""
    private var operatorText = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNumberFormat()
    }
    
    private func setNumberFormat() {
        numberFormatter.roundingMode = .ceiling
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 20
    }
        
    @IBAction func touchUpNumberButton(_ sender: UIButton) {
        if operandLabel?.text == "0"  {
            operandText = sender.currentTitle ?? "0"
        } else {
            operandText += sender.currentTitle ?? "0"
        }
        
        operandLabel?.text = operandText
    }
    
    @IBAction func touchUpZeroButton(_ sender: UIButton) {
        if operandLabel?.text == "0" {
            operandText = "0"
        } else {
            operandText += sender.currentTitle ?? "0"
        }
        
        operandLabel?.text = operandText
    }
    
    @IBAction func touchUpDotButton(_ sender: UIButton) {
        if operandText.contains(".") {
            return
        } else {
            operandText += sender.currentTitle ?? "0"
        }
        
        operandLabel?.text = operandText
    }
    
    @IBAction func touchUpOperatorButton(_ sender: UIButton) {
        addCountingHistory()
        
        textInput += operandText
        
        guard let lastWord = textInput.last else {
            return
        }
        
        if lastWord.isNumber {
            addScrollViewLabel()
        } else {
            textInput.removeLast()
        }
        
        changeLabelText(into: &operatorText, at: sender)
        operandText = ""
        operandLabel?.text = "0"
        
        scrollToBottom()
    }
    
    private func addCountingHistory() {
        if operandText == "" {
            return
        } else {
            countingHistory = operatorText + " " + operandText
        }
    }
    
    private func addScrollViewLabel() {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        label.textColor = .white
        label.text = countingHistory
        countingHistoryStackView?.addArrangedSubview(label)
    }
    
    private func changeLabelText(into text: inout String, at sender: UIButton) {
        text = sender.currentTitle ?? "0"
        textInput += text
        operatorLabel?.text = text
    }
    
    private func scrollToBottom() {
        countingHistoryScrollView.layoutIfNeeded()
        let bottomOffset = CGPoint(x: 0,
                                   y: countingHistoryScrollView.contentSize.height - countingHistoryScrollView.bounds.height + countingHistoryScrollView.contentInset.bottom)
        countingHistoryScrollView?.setContentOffset(bottomOffset, animated: false)
    }
    
    @IBAction func touchUpPlusMinusButton(_ sender: UIButton) {
        if operandText.hasPrefix("−") {
            operandText.removeFirst()
        } else {
            operandText = "−" + operandText
        }
        
        operandLabel?.text = operandText
    }
    
    @IBAction func touchUpACButton(_ sender: UIButton) {
        textInput = ""
        operandText = ""
        operatorText = ""
        operatorLabel?.text = ""
        operandLabel?.text = "0"
        removeScrollViewLabel()
    }
    
    private func removeScrollViewLabel() {
        let subviews = countingHistoryStackView?.arrangedSubviews
        
        subviews?.forEach({ subview in
            subview.removeFromSuperview()
        })
    }
    
    @IBAction func touchUpCEButton(_ sender: UIButton) {
        operandText = ""
        operandLabel?.text = "0"
    }
    
    @IBAction func touchUpEqualButton(_ sender: UIButton) {
        textInput += operandLabel?.text ?? "0"
        var parserResult = ExpressionParser.parse(from: textInput)
        
        do {
            textInput = ""
            operatorText = ""
            operandText = numberFormatter.string(for: try parserResult.result()) ?? "0"
            operatorLabel?.text = operatorText
            operandLabel?.text = operandText
        } catch QueueError.emptyOperandItem {
            showAlert(message: "숫자를 입력해주세요.")
        } catch QueueError.emptyOperatorItem {
            showAlert(message: "연산자를 입력해주세요.")
        } catch {
            showAlert(message: "예상치 못한 오류입니다.")
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
}
