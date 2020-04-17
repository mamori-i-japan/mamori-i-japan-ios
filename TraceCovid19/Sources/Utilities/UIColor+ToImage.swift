//
//  UIColor+ToImage.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/11.
//

import UIKit

extension UIColor {
    var toImage: UIImage {
        // 1x1の画像を作成
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else { assertionFailure(); return UIImage() }
        context.setFillColor(cgColor)
        context.fill(rect)
        guard let image: UIImage = UIGraphicsGetImageFromCurrentImageContext() else { assertionFailure(); return UIImage() }
        UIGraphicsEndImageContext()
        return image
    }
}
