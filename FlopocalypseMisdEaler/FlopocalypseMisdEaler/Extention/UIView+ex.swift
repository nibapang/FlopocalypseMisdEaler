//
//  UIView+ex.swift
//  FlopocalypseMisdEaler
//
//  Created by FlopocalypseMisdEaler on 2025/3/8.
//


import UIKit

//MARK: - View Properties (radius, border, shadow)
@IBDesignable extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set {
            layer.cornerRadius = newValue
            
            // If masksToBounds is true, subviews will be
            // clipped to the rounded corners.
            layer.masksToBounds = (newValue > 0)
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            guard let cgColor = layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: cgColor)
        }
        set { layer.borderColor = newValue?.cgColor }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    //    @IBInspectable var shadowColor: UIColor {
    //        get {
    //            return UIColor(cgColor: layer.shadowColor!)
    //        }
    //        set {
    //            layer.shadowColor = newValue.cgColor
    //        }
    //    }
    //
    //    @IBInspectable var shadowOpacity: Float {
    //        get {
    //            return layer.shadowOpacity
    //        }
    //        set {
    //            layer.shadowOpacity = newValue
    //        }
    //    }
    //
    //    @IBInspectable var shadowOffset: CGSize {
    //        get {
    //            return layer.shadowOffset
    //        }
    //        set {
    //            layer.shadowOffset = newValue
    //        }
    //    }
    //
    //    @IBInspectable var shadowRadius: CGFloat {
    //        get {
    //            return layer.shadowRadius
    //        }
    //        set {
    //            layer.shadowRadius = newValue
    //        }
    //    }
    //
    //    func addShadow() {
    //        layer.shadowColor = shadowColor.cgColor
    //        layer.shadowOpacity = shadowOpacity
    //        layer.shadowOffset = shadowOffset
    //        layer.shadowRadius = shadowRadius
    //    }
    
}

extension UIView {
    func addGradientBorderOutside(viewname: UIView, startColor: UIColor, endColor: UIColor, width: CGFloat, angleInDegrees: CGFloat, cornerRadius: CGFloat) {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: CGPoint.zero, size: bounds.size)
        gradient.colors = [startColor.cgColor, endColor.cgColor]
        
        let startPoint = CGPoint(x: 0.5 + cos(angleInDegrees * .pi / 180) * 0.5, y: 0.5 + sin(angleInDegrees * .pi / 180) * 0.5)
        let endPoint = CGPoint(x: 0.5 - cos(angleInDegrees * .pi / 180) * 0.5, y: 0.5 - sin(angleInDegrees * .pi / 180) * 0.5)
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        
        let shape = CAShapeLayer()
        shape.lineWidth = width
        shape.path = UIBezierPath(roundedRect: viewname.bounds, cornerRadius: cornerRadius).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        
        layer.addSublayer(gradient)
    }
}

extension UITextField {
    @IBInspectable var leftPadding: CGFloat {
        get {
            return leftView?.frame.size.width ?? 0
        }
        set {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: frame.size.height))
            leftView = paddingView
            leftViewMode = .always
        }
    }
    
    @IBInspectable var rightPadding: CGFloat {
        get {
            return rightView?.frame.size.width ?? 0
        }
        set {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: frame.size.height))
            rightView = paddingView
            rightViewMode = .always
        }
    }
    
    @IBInspectable var placeholderColor: UIColor? {
        get {
            return self.attributedPlaceholder?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor
        }
        set {
            guard let newValue = newValue else {
                self.attributedPlaceholder = nil
                return
            }
            
            var attributes = [NSAttributedString.Key: Any]()
            if let font = self.font {
                attributes[.font] = font
            }
            attributes[.foregroundColor] = newValue
            self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "", attributes: attributes)
        }
    }
}

extension UIView {
    func addPulsationAnimation() {
        /// transparency animation
        /// you can pick any values you like
        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.duration = 1.5
        pulseAnimation.fromValue = 0.7
        pulseAnimation.toValue = 1
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .greatestFiniteMagnitude
        self.layer.add(pulseAnimation, forKey: nil)
        
        /// transform scale animation
        /// you can pick any values you like
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.duration = 1.5
        scaleAnimation.fromValue = 0.95
        scaleAnimation.toValue = 1
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        scaleAnimation.autoreverses = true
        scaleAnimation.repeatCount = .greatestFiniteMagnitude
        self.layer.add(scaleAnimation, forKey: nil)
    }
}
