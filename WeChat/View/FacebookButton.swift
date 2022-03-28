//
//  FacebookButton.swift
//  WeChat
//
//  Created by Zohaib on 26/03/2022.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit

class FacebookButton: FBLoginButton {
    override func updateConstraints() {
        // deactivate height constraints added by the facebook sdk (we'll force our own instrinsic height)
        for contraint in constraints {
            if contraint.firstAttribute == .height, contraint.constant < 45 {
                // deactivate this constraint
                contraint.isActive = false
            }
        }
        super.updateConstraints()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 45)
    }

    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let logoSize: CGFloat = 24.0
        let centerY = contentRect.midY
        let y: CGFloat = centerY - (logoSize / 2.0)
        return CGRect(x: y, y: y, width: logoSize, height: logoSize)
    }

    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        if isHidden || bounds.isEmpty {
            return .zero
        }

        let imageRect = self.imageRect(forContentRect: contentRect)
        let titleX = imageRect.maxX + 10
        let titleRect = CGRect(x: titleX, y: 0, width: contentRect.width - titleX - titleX, height: contentRect.height)
        return titleRect
    }

}
