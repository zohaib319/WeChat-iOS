//
//  MyHelper.swift
//  WeChat
//
//  Created by Zohaib on 28/03/2022.
//

import Foundation
import UIKit


public protocol MyHelperCompatible {
    associatedtype someType
    var pickleup: someType { get }
}

public extension MyHelperCompatible {
     var pickleup: MyHelper<Self> {
        get { return MyHelper(self) }
    }
}

public struct MyHelper<Base> {
    let base: Base
    init(_ base: Base) {
        self.base = base
    }
}

/*
 extension to set left and right padding inside text fields
 */
extension UITextField : MyHelperCompatible {
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

/*
 // extension to hide keyboard by touching anywhere in safe area
 */
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


extension Dictionary {
    func percentEscaped() -> String {
        return map { (key, value) in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
            }
            .joined(separator: "&")
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
extension UIViewController{
    func alert(message: String, title: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
extension UIViewController{
    func isValidEmail(emailStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: emailStr)
    }
}
extension UIImage {
    
    func addImagePadding(x: CGFloat, y: CGFloat) -> UIImage? {
        let width: CGFloat = size.width + x
        let height: CGFloat = size.height + y
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0)
        let origin: CGPoint = CGPoint(x: (width - size.width) / 2, y: (height - size.height) / 2)
        draw(at: origin)
        let imageWithPadding = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return imageWithPadding
    }
}
extension String {
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
}
extension UITableView {
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = UIColor(red: 121.0/255, green: 121.0/255, blue: 121.0/255, alpha: 1)
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "Roboto-Regular", size: 12)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel
        self.separatorStyle = .none
    }
    
    func restore123() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
    
}
extension UIView {
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor(named: "shadowColor")?.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        layer.shadowRadius = 4
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}
extension UIView{
    
}

extension UIView {
    func addShadow(){
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 4.0
        self.layer.masksToBounds = true
        self.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
    }
}
extension UIView {
    func addBackgroundToStats(imageName: String) {
    // screen width and height:
    let width = UIScreen.main.bounds.size.width
    let height = UIScreen.main.bounds.size.height

    let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
    imageViewBackground.image = UIImage(named: imageName)

    // you can change the content mode:
        imageViewBackground.contentMode = UIView.ContentMode.bottom

    self.addSubview(imageViewBackground)
    self.sendSubviewToBack(imageViewBackground)
    }
    
}
extension UIView {
    func addBackgroundToProfile(imageName: String) {
    // screen width and height:
    let width = UIScreen.main.bounds.size.width
    let height = UIScreen.main.bounds.size.height

    let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
    imageViewBackground.image = UIImage(named: imageName)

    // you can change the content mode:
        imageViewBackground.contentMode = UIView.ContentMode.topLeft

    self.addSubview(imageViewBackground)
    self.sendSubviewToBack(imageViewBackground)
    }
    
}
// extension for empty table view
extension UITableView {
    func setTextToEmptyTableView(title: String, message: String) {
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.lightGray
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        messageLabel.textColor = UIColor.lightGray
        messageLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 17)
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
        titleLabel.text = title
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
// The only tricky part is here:
        self.backgroundView = emptyView
        self.separatorStyle = .none
}
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}

// extension for setting empty table view
extension UITableView {
    
    func setEmptyView(title: String, message: String, image: String) {
        
        let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        
        //Initialize an image view with desired frame and add image
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0 , width: 240, height: 128))
        imageView.center = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2 - 50)
        imageView.contentMode = .scaleAspectFit
        emptyView.addSubview(imageView)
        imageView.image = UIImage(named: image)
        
        // initialize title and message for the top and bottom text.
        let titleLabel = UILabel()
        let messageLabel = UILabel()

        //Setup title and label propoerties.
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.lightGray
        titleLabel.font = UIFont(name: "Roboto-Bold", size: 18)
        messageLabel.textColor = UIColor.lightGray
        messageLabel.font = UIFont(name: "Roboto-Medium", size: 17)
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        
        // setup constraints for title and label
        titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true

        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true

        
        // setup title and label properties.
        titleLabel.text = title
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        titleLabel.textAlignment = .center
        self.backgroundView = emptyView
        self.separatorStyle = .none
    }
    func restoreTableView() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
    
}

extension UIViewController{
    @objc func hidesKeyboardFromTF(){
        view.endEditing(true)
    }
}

extension UIViewController{
    func checkConnectivity() -> Bool
    {
        if InternetConnectivity.isConnectedToNetwork(){
            return true
        }else{
            return false
        }
    }
}

extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
extension UICollectionView {
    func setTextToEmptyCollectionView(title: String, message: String) {
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.lightGray
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        messageLabel.textColor = UIColor.lightGray
        messageLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 17)
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
        titleLabel.text = title
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
// The only tricky part is here:
        self.backgroundView = emptyView
}
    func restore() {
        self.backgroundView = nil
    }
}
extension UIViewController{
    func sessionExpiredAlert(message: String, title: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: {(action:UIAlertAction!) in
            
            let userPreferences = UserDefaults(suiteName: "UserPreferences")
            userPreferences?.set(false, forKey: "isLoggedIn")
            userPreferences?.removeObject(forKey: "first_name")
            userPreferences?.removeObject(forKey: "last_name")
            userPreferences?.removeObject(forKey: "email")
            userPreferences?.removeObject(forKey: "phone_number")
            userPreferences?.removeObject(forKey: "company_name")
            userPreferences?.removeObject(forKey: "address")
            userPreferences?.removeObject(forKey: "role")
            userPreferences?.removeObject(forKey: "avatar")
            userPreferences?.removeObject(forKey: "access_token")
            userPreferences?.removeObject(forKey: "token_type")
            userPreferences?.removeObject(forKey: "user_id")
            userPreferences?.removeObject(forKey: "isLoggedIn")
            self.dismiss(animated: true, completion: nil)

            
        })
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
}



extension String {
    
    public var initials: String {
        
        let words = components(separatedBy: .whitespacesAndNewlines)
        
        //to identify letters
        let letters = CharacterSet.letters
        var firstChar : String = ""
        var secondChar : String = ""
        var firstCharFoundIndex : Int = -1
        var firstCharFound : Bool = false
        var secondCharFound : Bool = false
        
        for (index, item) in words.enumerated() {
            
            if item.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                continue
            }
            
            //browse through the rest of the word
            for (_, char) in item.unicodeScalars.enumerated() {
                
                //check if its a aplha
                if letters.contains(char) {
                    
                    if !firstCharFound {
                        firstChar = String(char)
                        firstCharFound = true
                        firstCharFoundIndex = index
                        
                    } else if !secondCharFound {
                        
                        secondChar = String(char)
                        if firstCharFoundIndex != index {
                            secondCharFound = true
                        }
                        
                        break
                    } else {
                        break
                    }
                }
            }
        }
        
        if firstChar.isEmpty && secondChar.isEmpty {
            firstChar = "D"
            secondChar = "P"
        }
        
        return firstChar + secondChar
    }
}


// extension for setting empty table view
extension UICollectionView {
    
    func setEmptyView(title: String, message: String, image: String) {
        
        let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        
        //Initialize an image view with desired frame and add image
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0 , width: 240, height: 128))
        imageView.center = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2 - 50)
        imageView.contentMode = .scaleAspectFit
        emptyView.addSubview(imageView)
        imageView.image = UIImage(named: image)
        
        // initialize title and message for the top and bottom text.
        let titleLabel = UILabel()
        let messageLabel = UILabel()

        //Setup title and label propoerties.
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.label
        titleLabel.font = UIFont(name: "Roboto-Medium", size: 18)
        messageLabel.textColor = UIColor.lightGray
        messageLabel.font = UIFont(name: "Roboto-Regular", size: 16)
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        
        // setup constraints for title and label
        titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true

        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true

        
        // setup title and label properties.
        titleLabel.text = title
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        titleLabel.textAlignment = .center
        self.backgroundView = emptyView
    }
    func restoreCollectionView() {
        self.backgroundView = nil
    }
    
}

extension String {

    // formatting text for currency textField
    func currencyInputFormatting() -> String {
    
        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyAccounting
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
    
        var amountWithPrefix = self
    
        // remove from String: "$", ".", ","
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count), withTemplate: "")
    
        let double = (amountWithPrefix as NSString).doubleValue
        number = NSNumber(value: (double / 100))
    
        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber else {
            return ""
        }
    
        return formatter.string(from: number)!
    }
}


extension String {
    // formatting text for currency textField
    func currencyFormatting() -> String {
        if let value = Double(self) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.maximumFractionDigits = 2
            formatter.minimumFractionDigits = 2
            if let str = formatter.string(for: value) {
                return str
            }
        }
        return ""
    }
}


extension UICollectionView{
    func setLabelToImagesCollectionView(title: String){
        let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        let titleLabel = UILabel()
        //Setup title and label propoerties.
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.label
        titleLabel.font = UIFont(name: "Roboto-Regular", size: 14)
        emptyView.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: emptyView.topAnchor, constant: 0).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 0).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: 0).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: emptyView.bottomAnchor, constant: 0).isActive = true
        titleLabel.text =  title
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        self.backgroundView = emptyView
        
        
    }
    func restoreImagesCollectionView(){
        self.backgroundView = nil
    }
}
