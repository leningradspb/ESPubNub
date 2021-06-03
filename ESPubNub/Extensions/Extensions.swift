//
//  Extensions.swift
//  ESPubNub
//
//  Created by Eduard Sinyakov on 03.06.2021.
//

import UIKit
extension UITableViewCell {
    static var identifier: String {
        "\(self)"
    }
}

extension UICollectionReusableView {
    static var identifier: String {
        "\(self)"
    }
}


extension UIView {
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach { self.addSubview($0) }
    }
}

extension UIStackView {
    func addArranged(subviews:[UIView]) {
        subviews.forEach { self.addArrangedSubview($0) }
    }
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") { cString.removeFirst() }

        if (cString.count) != 6 {
            self.init(hex: "ffffff")
            return
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}


extension UIColor {
    /// FF4364
    static let scarlet = UIColor(hex: "#FF4364")
    /// 30BA8F
    static let grass = UIColor(hex: "#30BA8F")
    /// UIColor.white.withAlphaComponent(0.1)
    static let commonGrey = UIColor.white.withAlphaComponent(0.1)
}


class VerticalStackView: UIStackView {
    init(distribution: UIStackView.Distribution = .fill, spacing: CGFloat, alignment: UIStackView.Alignment = .fill) {
        super.init(frame: .zero)
        axis = .vertical
        self.distribution = distribution
        self.alignment = alignment
        self.spacing = spacing
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class HorizontalStackView: UIStackView {
    init(distribution: UIStackView.Distribution = .fill, spacing: CGFloat, alignment: UIStackView.Alignment = .fill) {
        super.init(frame: .zero)
        axis = .horizontal
        self.distribution = distribution
        self.alignment = alignment
        self.spacing = spacing
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class InsetTextField: UITextField {

    let padding = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
