//
//  Extensions.swift
//  MyMessanger
//
//  Created by Mo Elahmady on 16/12/2020.
//

import Foundation
import UIKit


extension UIView {
    public var width: CGFloat {
        return frame.size.width
    }
    
    public var height: CGFloat {
        return frame.size.height
    }
    public var top: CGFloat {
        return frame.origin.y
    }
    public var bottom: CGFloat {
        return frame.size.height + frame.origin.y
    }

    public var left: CGFloat {
        return frame.origin.x
    }
    public var right: CGFloat {
        return frame.size.width + frame.origin.x
    }

}



extension Notification.Name {
    /// Notification when user logs in with google
    static let didLoginNotification = Notification.Name("didLoginNotification")
}
