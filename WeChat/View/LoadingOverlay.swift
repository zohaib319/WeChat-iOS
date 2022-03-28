//
//  LoadingOverlay.swift
//  WeChat
//
//  Created by Zohaib on 28/03/2022.
//

import Foundation
import UIKit

public class LoadingOverlay{
    
    var overlayView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var bgView = UIView()
    
    class var shared: LoadingOverlay {
        struct Static {
            static let instance: LoadingOverlay = LoadingOverlay()
        }
        return Static.instance
    }
    
    public func showOverlay(view: UIView) {
        
        bgView.frame = view.frame
        bgView.backgroundColor = UIColor(red: 46.0/255, green: 46.0/255, blue: 46.0/255, alpha: 0.0)
//        bgView.addSubview(overlayView)
        bgView.autoresizingMask = [.flexibleLeftMargin,.flexibleTopMargin,.flexibleRightMargin,.flexibleBottomMargin,.flexibleHeight, .flexibleWidth]
        overlayView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        overlayView.backgroundColor = UIColor(red: 26.0/255, green: 28.0/255, blue: 30.0/255, alpha: 1.0)
        overlayView.center = view.center
        overlayView.autoresizingMask = [.flexibleLeftMargin,.flexibleTopMargin,.flexibleRightMargin,.flexibleBottomMargin]
        overlayView.clipsToBounds = true
        overlayView.layer.cornerRadius = 10
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.style = .large
        activityIndicator.color = UIColor(red: 255.0/255, green: 151.0/255, blue: 4.0/255, alpha: 1.0)
        activityIndicator.center = CGPoint(x: overlayView.bounds.width / 2, y: overlayView.bounds.height / 2)
        overlayView.addSubview(activityIndicator)
        bgView.addSubview(overlayView)
        view.addSubview(bgView)
        self.activityIndicator.startAnimating()
        
    }
    
    public func hideOverlayView() {
        activityIndicator.stopAnimating()
        bgView.removeFromSuperview()
    }
}
