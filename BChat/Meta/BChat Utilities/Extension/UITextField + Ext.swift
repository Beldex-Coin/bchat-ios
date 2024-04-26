// Copyright © 2023 Beldex International Limited OU. All rights reserved.

import Foundation

extension UITextField {
    @IBInspectable var doneAccessory: Bool {
        get {
            return self.doneAccessory
        }
        set (hasDone) {
            addDoneButtonKeybord()
        }
    }
    func addDoneButtonKeybord() {
        let doneToolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50  ))
        doneToolbar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done:UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        let items = [flexSpace,done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        self.inputAccessoryView = doneToolbar
    }
    @objc func doneButtonAction() {
        self.resignFirstResponder()
    }
}

extension UITextField {
    
    enum Direction {
        case Left
        case Right
    }
    
    // add image to textfield
    func withImage(direction: Direction, image: UIImage, colorBorder: UIColor){
        let mainView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 20))
        // mainView.layer.cornerRadius = 5
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 20))
        //    view.backgroundColor = .white
        //    view.clipsToBounds = true
        //  view.layer.cornerRadius = 5
        // view.layer.borderWidth = CGFloat(0.5)
        //    view.layer.borderColor = colorBorder.cgColor
        mainView.addSubview(view)
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        //  imageView.tintColor = UIColor.red
        imageView.frame = CGRect(x: 0, y: 0, width: 15, height: 20)
        view.addSubview(imageView)
        
        //    let seperatorView = UIView()
        //    seperatorView.backgroundColor = colorSeparator
        //    mainView.addSubview(seperatorView)
        
        if(Direction.Left == direction){ // image left
            // seperatorView.frame = CGRect(x: 45, y: 0, width: 5, height: 20)
            self.leftViewMode = .always
            self.leftView = mainView
        } else { // image right
            // seperatorView.frame = CGRect(x: 0, y: 0, width: 5, height: 20)
            self.rightViewMode = .always
            self.rightView = mainView
        }
        
        // self.layer.borderColor = colorBorder.cgColor
        // self.layer.borderWidth = CGFloat(0.5)
        // self.layer.cornerRadius = 5
    }
}

extension UITextField {
    func datePicker<T>(target: T,
                       doneAction: Selector,
                       cancelAction: Selector,
                       datePickerMode: UIDatePicker.Mode = .date) {
        let screenWidth = UIScreen.main.bounds.width
        func buttonItem(withSystemItemStyle style: UIBarButtonItem.SystemItem) -> UIBarButtonItem {
            let buttonTarget = style == .flexibleSpace ? nil : target
            let action: Selector? = {
                switch style {
                case .cancel:
                    return cancelAction
                case .done:
                    return doneAction
                default:
                    return nil
                }
            }()
            let barButtonItem = UIBarButtonItem(barButtonSystemItem: style,
                                                target: buttonTarget,
                                                action: action)
            
            return barButtonItem
        }
        let datePicker = UIDatePicker(frame: CGRect(x: 0,
                                                    y: 0,
                                                    width: screenWidth,
                                                    height: 216))
        datePicker.datePickerMode = datePickerMode
        
        datePicker.maximumDate = Date()
        
        if #available(iOS 14, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        self.inputView = datePicker
        let toolBar = UIToolbar(frame: CGRect(x: 0,
                                              y: 0,
                                              width: screenWidth,
                                              height: 44))
        toolBar.setItems([buttonItem(withSystemItemStyle: .cancel),
                          buttonItem(withSystemItemStyle: .flexibleSpace),
                          buttonItem(withSystemItemStyle: .done)],
                         animated: true)
        self.inputAccessoryView = toolBar
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
