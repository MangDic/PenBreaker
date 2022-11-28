//
//  UIView+.swift
//  PenBreaker
//
//  Created by 이명직 on 2022/11/24.
//
import UIKit

extension UIView {
    /// 해당 view를 이미지로 변환합니다.
    func transfromToImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0.0)
        defer {
            UIGraphicsEndImageContext()
        }
        if let context = UIGraphicsGetCurrentContext() {
            layer.render(in: context)
            return UIGraphicsGetImageFromCurrentImageContext()
        }
        return nil
    }
}
