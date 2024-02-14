//
//  Extensions.swift
//  DevRevAssignment
//
//  Created by Jatin Menghani on 09/02/24.
//

import UIKit

// MARK: UIImageView
let imageCache = NSCache<NSString, UIImage>()
extension UIImageView {
    
    @discardableResult
    func fetchImageFromURL(urlString: String, placeholder: UIImage? = nil) -> URLSessionDataTask? {
        
        // To prevent showing same images in cells
        self.image = nil
        
        if let cachedImage = imageCache.object(forKey: NSString(string: urlString)) {
            self.image = cachedImage
            return nil
        }
        
        guard let url = URL(string: urlString) else { return nil }
        
        if let placeholder = placeholder { self.image = placeholder }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let downloadImage = UIImage(data: data) {
                imageCache.setObject(downloadImage, forKey: NSString(string: urlString))
                DispatchQueue.main.async {
                    self.image = downloadImage
                }
            }
        }
        
        task.resume()
        return task
    }
}

// MARK: Int
extension Int {
    func currencyString() -> String {
        let number = Double(self)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        
        var currencyString = ""
        if number >= 1_000_000 {
            currencyString = formatter.string(from: NSNumber(value: number / 1_000_000)) ?? ""
            currencyString += "M"
        } else if number >= 1_000 {
            currencyString = formatter.string(from: NSNumber(value: number / 1_000)) ?? ""
            currencyString += "K"
        } else {
            currencyString = formatter.string(from: NSNumber(value: number)) ?? ""
        }
        
        return currencyString
    }
    
    func runtimeString() -> String {
        let hours = self / 60
        let minutes = self % 60
        
        if hours > 0 {
            if minutes > 0 {
                return "\(hours)hr \(minutes)mins"
            } else {
                return "\(hours)hr"
            }
        } else {
            return "\(minutes)mins"
        }
    }
}

extension Double {
    func roundedToOneDecimalPlace() -> Double {
        let multiplier = pow(10.0, 1.0)
        return (self * multiplier).rounded() / multiplier
    }
}

// MARK: String
extension String {
    var DRVFormat: String {
        let serverDateFormatter = DateFormatter()
        serverDateFormatter.dateFormat = "yyyy-MM-dd"
        let dateFromServer = serverDateFormatter.date(from: self)
        
        let customDateFormatter = DateFormatter()
        customDateFormatter.dateFormat = "dd MMMM yyyy"
        return customDateFormatter.string(from: dateFromServer ?? Date())
    }
}

// MARK: UILabel
extension UILabel {
    func setLineSpacing(lineSpacing: CGFloat) {
        guard let labelText = self.text else { return }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        
        let attributedString = NSMutableAttributedString(string: labelText)
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        
        self.attributedText = attributedString
    }
}

// MARK: UIViewController
extension UIViewController {
    func showErrorToast(message : String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 120, y: self.view.frame.size.height - 100, width: 250, height: 40))
        toastLabel.backgroundColor = UIColor.systemPink.withAlphaComponent(1)
        toastLabel.textColor = UIColor.white
        toastLabel.font = .systemFont(ofSize: 16, weight: .medium)
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 12;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 5.0, delay: 0.5, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
