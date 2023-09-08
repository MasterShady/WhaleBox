//
//  ImageExtension.swift
//  ReCamV5
//
//  Created by Park on 2020/3/19.
//  Copyright © 2020 Wade. All rights reserved.
//

import UIKit

extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1.0, height: 1.0)) {
        UIGraphicsBeginImageContextWithOptions(size, true, 1)
        defer {
            UIGraphicsEndImageContext()
        }
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(CGRect(origin: CGPoint.zero, size: size))
        context?.setShouldAntialias(true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        guard let cgImage = image?.cgImage else {
            self.init()
            return nil
        }
        self.init(cgImage: cgImage)
    }
    
    class func imageWithLinearColors(_ colors: [CGColor]!, _ startPoint: CGPoint, _ endPoint: CGPoint, _ size: CGSize = CGSize.init(width: 10, height: 10), _ scale: CGFloat = 1) -> UIImage? {

        UIGraphicsBeginImageContextWithOptions(size, true, scale)
        let context = UIGraphicsGetCurrentContext()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        var gradient: CGGradient? = nil
        
        if let tempColors = colors as CFArray? {
            gradient = CGGradient(colorsSpace: colorSpace, colors: tempColors, locations: nil)
        }
        let floatBlock: ((Float) -> Float)? = { x in
            if x <= 0.0 {
                return 0.0
            } else if x >= 1.0 {
                return 1.0
            } else {
                return x
            }
        }
        let rsPoint = CGPoint(x: CGFloat(floatBlock!(Float(startPoint.x))) * size.width, y: CGFloat(floatBlock!(Float(startPoint.y))) * size.height)
        let rePoint = CGPoint(x: CGFloat(floatBlock!(Float(endPoint.x))) * size.width, y: CGFloat(floatBlock!(Float(endPoint.y))) * size.height)
        context?.drawLinearGradient(gradient!, start: rsPoint, end: rePoint, options: [])
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    
    class func imageWithColorAndCenterImage(_ color: UIColor, _ centerImage: UIImage, _ size: CGSize) -> UIImage? {
        let background = UIView.init(frame: CGRect.init(x: 0, y: 0, width: floor(size.width), height: floor(size.height)))
        background.backgroundColor = color
        
        let imageView = UIImageView(image: centerImage)
        background.addSubview(imageView)
        imageView.center = background.center
        
        UIGraphicsBeginImageContextWithOptions(background.bounds.size, background.isOpaque, UIScreen.main.scale)
        background.layer.render(in: UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    class func getLogoIcon() -> UIImage? {
        if let infoPlist = Bundle.main.infoDictionary {
            if let dic1 = infoPlist["CFBundleIcons"] as? [String: Any] {
                if let dic2 = dic1["CFBundlePrimaryIcon"] as? [String: Any] {
                    if let icons = dic2["CFBundleIconFiles"] as? [String] {
                        if let iconName = icons.last {
                            return UIImage(named: iconName)
                        }
                    }
                }
            }
        }
        return nil
    }
    
    func scaleToMaxSize(size: CGSize) -> UIImage {
        if self.size.width < size.width && self.size.height < size.height {
            return self.copy() as! UIImage
        }
        let widthScale = size.width / self.size.width;
        let heightScale = size.height / self.size.height;
        let targetSize = CGSize.init(width: self.size.width*min(widthScale, heightScale), height: self.size.height*min(widthScale, heightScale))
        return self.resizeImageToSize(size: targetSize)
    }
    
    func resizeImageToSize(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size);
        self.draw(in: CGRect.init(origin: CGPoint.zero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return scaledImage ?? self;
    }
    
    func colored(_ color: UIColor) -> UIImage? {
        let img = self.withRenderingMode(.alwaysTemplate)
        UIGraphicsBeginImageContextWithOptions(img.size, false, UIScreen.main.scale)
        color.set()
        img.draw(in: .init(origin: .zero, size: img.size))
        let outImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return outImage
    }
    
    func toBase64() -> String {
        return self.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
    }
    
    class func fromLayer(layer: CALayer) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(layer.bounds.size, layer.isOpaque, 0.0)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    
    // 仅压缩质量
    func compressQuality(maxLength: Int) -> Data {
        var compression: CGFloat = 1
        var data = jpegData(compressionQuality: compression)
        if (data!.count < maxLength) {
            return data!
        }
        
        var max: CGFloat = 1
        var min: CGFloat = 0
        for _ in 0...6 {
            compression = (max + min) / 2
            data = jpegData(compressionQuality: compression)
            if (data!.count < Int(CGFloat(maxLength) * 0.9)) {
                min = compression
            } else if (data!.count > maxLength) {
                max = compression
            } else {
                break;
            }
        }
        
        return data!
    }
    
    // 压缩质量和大小
    func compressQualityAndSize(maxLength: Int) -> Data {
        var compression: CGFloat = 1
        var data = jpegData(compressionQuality: compression)
        if (data!.count < maxLength) {
            return data!
        }
        var max: CGFloat = 1
        var min: CGFloat = 0

        var newImage: UIImage = self
        for _ in 0...6 {
            compression = (max + min) / 2
            newImage = resizeImage(scale: compression)
            data = newImage.jpegData(compressionQuality: compression)
            if (data!.count < Int(CGFloat(maxLength) * 0.9)) {
                min = compression
            } else if (data!.count > maxLength) {
                max = compression
            } else {
                break;
            }
        }
        return data!
    }
    
    func resizeImage(scale: CGFloat) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: self.size.width * scale, height: self.size.height * scale))
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width * scale, height: self.size.height * scale))
        let resultImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return resultImg!
    }
    
    func fixedOrientation() -> UIImage? {
        guard imageOrientation != UIImage.Orientation.up else {
            //This is default orientation, don't need to do anything
            return self.copy() as? UIImage
        }
        
        guard let cgImage = self.cgImage else {
            //CGImage is not available
            return nil
        }
        
        guard let colorSpace = cgImage.colorSpace, let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil //Not able to create CGContext
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
            break
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
            break
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
            break
        case .up, .upMirrored:
            break
        @unknown default:
            break
            
        }
        
        //Flip image one more time if needed to, this is to prevent flipped image
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform.translatedBy(x: size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case .leftMirrored, .rightMirrored:
            transform.translatedBy(x: size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        @unknown default:
            break
        }
        
        ctx.concatenate(transform)
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }
        
        guard let newCGImage = ctx.makeImage() else { return nil }
        return UIImage.init(cgImage: newCGImage, scale: 1, orientation: .up)
    }
    
    func clipWithPath(_ path: UIBezierPath?) -> UIImage? {
        guard let fixPath = path else {return self}
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.clear.cgColor)
        context?.fill(.init(origin: .zero, size: size))
        fixPath.usesEvenOddFillRule = true
        fixPath.addClip()
        draw(in: .init(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func handleImageToContactIconSize() -> Data {
        var image = self
        let maxW = kScreenHeight
        UIGraphicsBeginImageContextWithOptions(CGSize(width: maxW, height: maxW), false, 3)
        
        var imageX: CGFloat = 0
        let imageY: CGFloat = 0
        var imageW: CGFloat = maxW
        let imageH: CGFloat = maxW
        
        var scale = image.size.width / image.size.height
        let screenScale = kScreenWidth / kScreenHeight
        if scale < screenScale { // 如果图片的太长，需要切掉上下部分
            image = image.cutImageToScale(scale: screenScale)
        } else if scale > 1 { // 如果图片太宽，需要切成1比1
            image = image.cutImageToScale(scale: 1)
        }
        scale = image.size.width / image.size.height
        imageW = imageH * scale
        imageX = (maxW - imageW) / 2
        
        image.draw(in: CGRect(x: imageX, y: imageY, width: imageW, height: imageH))
        let resultImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // 尽量压缩到100k以内,避免icloud上传失败
        let data = resultImg!.compressQuality(maxLength: 100000)
        
        return data
    }
    
    func cutImageToScale(scale: CGFloat) -> UIImage {
        let imageScale = size.width / size.height
        if imageScale > scale { // 裁剪横向部分
            let imageRef = self.cgImage!
            let width = CGFloat(imageRef.width)
            let height = CGFloat(imageRef.height)
            let toWidth = height * scale
            let x = (width - toWidth) / 2
            let newImageRef = imageRef.cropping(to: CGRect(x: x, y: 0, width: toWidth, height: height))
            let newImage = UIImage(cgImage: newImageRef!)
            return newImage
        } else {
            // 裁剪image
            let imageRef = self.cgImage!
            let width = CGFloat(imageRef.width)
            let height = CGFloat(imageRef.height)
            let toHeight = width / scale
            let y = (height - toHeight) / 2

            let newImageRef = imageRef.cropping(to: CGRect(x: 0, y: y, width: width, height: toHeight))
            let newImage = UIImage(cgImage: newImageRef!)
            return newImage
        }
    }
    
    //将图片裁剪成指定比例（多余部分自动删除）
    func crop(ratio: CGFloat) -> UIImage {
        //计算最终尺寸
        var newSize:CGSize!
        if size.width/size.height > ratio {
            newSize = CGSize(width: size.height * ratio, height: size.height)
        }else{
            newSize = CGSize(width: size.width, height: size.width / ratio)
        }
        
        ////图片绘制区域
        var rect = CGRect.zero
        rect.size.width  = size.width
        rect.size.height = size.height
        rect.origin.x    = (newSize.width - size.width ) / 2.0
        rect.origin.y    = (newSize.height - size.height ) / 2.0
        
        //绘制并获取最终图片
        UIGraphicsBeginImageContext(newSize)
        draw(in: rect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
    
    func drawInColor(color:UIColor,size:CGSize,cornerRadius:CGFloat, tintColor:UIColor?,insets:UIEdgeInsets) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        color.setFill()
        let circlePath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        circlePath.fill()
        if let tintColor = tintColor{
            self.withTintColor(tintColor).draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height).inset(by: insets))
        }else{
            self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height).inset(by: insets))
        }
        let resultImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImg!
    }
    
    func addImage(image: UIImage, in targetRect: CGRect) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        image.draw(in: targetRect)
        
        let resultImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resultImg
    }

}
