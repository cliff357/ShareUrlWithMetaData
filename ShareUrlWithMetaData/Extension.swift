//
//  Extension.swift
//  ShareUrlWithMetaData
//
//  Created by Cliff Chan on 22/12/2021.
//

import Foundation
import UIKit
//import SwiftyJSON

//MARK: UIView

public extension UIView {
/// Generating constraints to superview's edge
	func edgeConstraints(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) -> [NSLayoutConstraint] {
		return [
			self.leftAnchor.constraint(equalTo: self.superview!.leftAnchor, constant: left),
			self.rightAnchor.constraint(equalTo: self.superview!.rightAnchor, constant: -right),
			self.topAnchor.constraint(equalTo: self.superview!.topAnchor, constant: top),
			self.bottomAnchor.constraint(equalTo: self.superview!.bottomAnchor, constant: -bottom)
		]
	}
	
	func addShadow(shadowColor: UIColor, offSet: CGSize, opacity: Float, shadowRadius: CGFloat, cornerRadius: CGFloat, corners: UIRectCorner, fillColor: UIColor = .white) {
		
		let shadowLayer = CAShapeLayer()
		let size = CGSize(width: cornerRadius, height: cornerRadius)
		
		//Create a UIBezierPath using size and corners
		let cgPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: size).cgPath
		
		//Assign this UIBezierPath to CAShapeLayer
		shadowLayer.path = cgPath
		
		//It’s background color of UIView, default is white
		shadowLayer.fillColor = fillColor.cgColor
		
		//This is shadow color, change it as per your uses
		shadowLayer.shadowColor = shadowColor.cgColor
		shadowLayer.shadowPath = cgPath
		
		//This is shadowOffset change is as per your uses
		shadowLayer.shadowOffset = offSet
		shadowLayer.shadowOpacity = opacity
		shadowLayer.shadowRadius = shadowRadius
		
		
		if  self.layer.sublayers?.count ?? 0 > 0,
			let layer = self.layer.sublayers?.first,
			layer is CAShapeLayer{
			self.layer.replaceSublayer(layer, with: shadowLayer)
		}else{
			self.layer.insertSublayer(shadowLayer, at: 0)
		}
		
	}
	
	func shake(duration: TimeInterval = 0.5, values: [CGFloat]) {
		let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
		
		animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
		
		animation.duration = duration // You can set fix duration
		animation.values = values  // You can set fix values here also
		self.layer.add(animation, forKey: "shake")
	}
	
	
	func showToast(text: String){
		
		DispatchQueue.main.async {
			self.hideToast()
		
			let toastLb = UILabel()
			toastLb.tag = 9999
			toastLb.numberOfLines = 0
			toastLb.lineBreakMode = .byWordWrapping
			toastLb.backgroundColor = UIColor.black.withAlphaComponent(0.7)
			toastLb.textColor = UIColor.white
			toastLb.layer.cornerRadius = 10.0
			toastLb.textAlignment = .center
			toastLb.font = UIFont.systemFont(ofSize: 15.0)
			toastLb.text = text
			toastLb.layer.masksToBounds = true
			
			let maxSize = CGSize(width: self.bounds.width - 40, height: self.bounds.height)
			var expectedSize = toastLb.sizeThatFits(maxSize)
			var lbWidth = maxSize.width
			var lbHeight = maxSize.height
			if maxSize.width >= expectedSize.width{
				lbWidth = expectedSize.width
			}
			if maxSize.height >= expectedSize.height{
				lbHeight = expectedSize.height
			}
			expectedSize = CGSize(width: lbWidth, height: lbHeight)
			toastLb.frame = CGRect(x: ((self.bounds.size.width)/2) - ((expectedSize.width + 20)/2), y: self.bounds.height - expectedSize.height - 40 - 20, width: expectedSize.width + 20, height: expectedSize.height + 20)
			self.addSubview(toastLb)
			
			UIView.animate(withDuration: 1.5, delay: 1.5, animations: {
				toastLb.alpha = 0.0
			}) { (complete) in
				toastLb.removeFromSuperview()
			}
		}
	}
	
	func hideToast(){
		 for view in self.subviews{
			 if view is UILabel , view.tag == 9999{
				 view.removeFromSuperview()
			 }
		 }
	 }

	func roundCorners(corners: UIRectCorner, radius: CGFloat) {
		let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
		let mask = CAShapeLayer()
		mask.path = path.cgPath
		layer.mask = mask
	}
	
	func roundCorners(topLeft: CGFloat = 0, topRight: CGFloat = 0, bottomLeft: CGFloat = 0, bottomRight: CGFloat = 0) {//(topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat) {
		   let topLeftRadius = CGSize(width: topLeft, height: topLeft)
		   let topRightRadius = CGSize(width: topRight, height: topRight)
		   let bottomLeftRadius = CGSize(width: bottomLeft, height: bottomLeft)
		   let bottomRightRadius = CGSize(width: bottomRight, height: bottomRight)
		   let maskPath = UIBezierPath(shouldRoundRect: bounds, topLeftRadius: topLeftRadius, topRightRadius: topRightRadius, bottomLeftRadius: bottomLeftRadius, bottomRightRadius: bottomRightRadius)
		   let shape = CAShapeLayer()
		   shape.path = maskPath.cgPath
		   layer.mask = shape
	   }
	
	func isVisible(view: UIView) -> Bool {
		func isVisible(view: UIView, inView: UIView?) -> Bool {
			guard let inView = inView else { return true }
			let viewFrame = inView.convert(view.bounds, from: view)
			if viewFrame.intersects(inView.bounds) {
				return isVisible(view: view, inView: inView.superview)
			}
			return false
		}
		return isVisible(view: view, inView: view.superview)
	}
	
	func subviews<T:UIView>(ofType WhatType:T.Type) -> [T] {
		var result = self.subviews.compactMap {$0 as? T}
		for sub in self.subviews {
			result.append(contentsOf: sub.subviews(ofType:WhatType))
		}
		return result
	}
	
}

extension UIBezierPath {
	convenience init(shouldRoundRect rect: CGRect, topLeftRadius: CGSize = .zero, topRightRadius: CGSize = .zero, bottomLeftRadius: CGSize = .zero, bottomRightRadius: CGSize = .zero){

		self.init()

		let path = CGMutablePath()

		let topLeft = rect.origin
		let topRight = CGPoint(x: rect.maxX, y: rect.minY)
		let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
		let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)

		if topLeftRadius != .zero{
			path.move(to: CGPoint(x: topLeft.x+topLeftRadius.width, y: topLeft.y))
		} else {
			path.move(to: CGPoint(x: topLeft.x, y: topLeft.y))
		}

		if topRightRadius != .zero{
			path.addLine(to: CGPoint(x: topRight.x-topRightRadius.width, y: topRight.y))
			path.addCurve(to:  CGPoint(x: topRight.x, y: topRight.y+topRightRadius.height), control1: CGPoint(x: topRight.x, y: topRight.y), control2:CGPoint(x: topRight.x, y: topRight.y+topRightRadius.height))
		} else {
			 path.addLine(to: CGPoint(x: topRight.x, y: topRight.y))
		}

		if bottomRightRadius != .zero{
			path.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y-bottomRightRadius.height))
			path.addCurve(to: CGPoint(x: bottomRight.x-bottomRightRadius.width, y: bottomRight.y), control1: CGPoint(x: bottomRight.x, y: bottomRight.y), control2: CGPoint(x: bottomRight.x-bottomRightRadius.width, y: bottomRight.y))
		} else {
			path.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y))
		}

		if bottomLeftRadius != .zero{
			path.addLine(to: CGPoint(x: bottomLeft.x+bottomLeftRadius.width, y: bottomLeft.y))
			path.addCurve(to: CGPoint(x: bottomLeft.x, y: bottomLeft.y-bottomLeftRadius.height), control1: CGPoint(x: bottomLeft.x, y: bottomLeft.y), control2: CGPoint(x: bottomLeft.x, y: bottomLeft.y-bottomLeftRadius.height))
		} else {
			path.addLine(to: CGPoint(x: bottomLeft.x, y: bottomLeft.y))
		}

		if topLeftRadius != .zero{
			path.addLine(to: CGPoint(x: topLeft.x, y: topLeft.y+topLeftRadius.height))
			path.addCurve(to: CGPoint(x: topLeft.x+topLeftRadius.width, y: topLeft.y) , control1: CGPoint(x: topLeft.x, y: topLeft.y) , control2: CGPoint(x: topLeft.x+topLeftRadius.width, y: topLeft.y))
		} else {
			path.addLine(to: CGPoint(x: topLeft.x, y: topLeft.y))
		}

		path.closeSubpath()
		cgPath = path
	}
}

public extension UILabel {
	func calculateMaxLines() -> Int {
		let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
		let charSize = font.lineHeight
		let text = (self.text ?? "") as NSString
		let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
		let linesRoundedUp = Int(ceil(textSize.height/charSize))
		return linesRoundedUp
	}
	
	func setCharacterSpacing(_ characterSpacing: CGFloat = 0.0) {

		  guard let labelText = text else { return }

		  let attributedString: NSMutableAttributedString
		  if let labelAttributedText = attributedText {
			  attributedString = NSMutableAttributedString(attributedString: labelAttributedText)
		  } else {
			  attributedString = NSMutableAttributedString(string: labelText)
		  }

		  // Character spacing attribute
		attributedString.addAttribute(NSAttributedString.Key.kern, value: characterSpacing, range: NSMakeRange(0, attributedString.length))

		  attributedText = attributedString
	  }
}

public extension UITableView {
	func reloadData(completion:@escaping ()->()) {
		UIView.animate(withDuration: 0, animations: { self.reloadData() })
			{ _ in completion() }
	}
	
	func autoSizeHeaderAndFooter() {
		let width = self.bounds.width
		let autoSize = { (view: UIView) in
			view.translatesAutoresizingMaskIntoConstraints = false
			
			let widthConstraint = NSLayoutConstraint(item: view,
													 attribute: NSLayoutConstraint.Attribute.width,
													 relatedBy: NSLayoutConstraint.Relation.equal,
													 toItem: nil,
													 attribute: NSLayoutConstraint.Attribute.notAnAttribute,
													 multiplier: 1,
													 constant: width)
			
			view.addConstraint(widthConstraint)
			let height = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
			view.removeConstraint(widthConstraint)
			
			view.frame = CGRect(x: 0, y: 0, width: width, height: height)
			view.translatesAutoresizingMaskIntoConstraints = true
		}
		
		if let view = tableHeaderView {
			autoSize(view)
			tableHeaderView = view
		}
		
		if let view = tableFooterView {
			autoSize(view)
			tableFooterView = view
		}
	}
	
}

public extension UITableViewCell {
	/// Generated cell identifier derived from class name
	static func cellIdentifier() -> String {
		return String(describing: self)
	}
}


public extension UITabBar {
//    override open func sizeThatFits(_ size: CGSize) -> CGSize {
//        super.sizeThatFits(size)
//        var sizeThatFits = super.sizeThatFits(size)
//        if UIDevice.current.userInterfaceIdiom == .phone{
//            sizeThatFits.height = 100
//        }
//        return sizeThatFits
//    }

//    override open var traitCollection: UITraitCollection {
//        if UIDevice.current.userInterfaceIdiom == .pad {
//            return UITraitCollection(horizontalSizeClass: .compact)
//        }
//        return super.traitCollection
//    }
}

extension UITabBarController {

//
//	func setTabBarVisible(visible:Bool, animated:Bool) {
//
//			// bail if the current state matches the desired state
//			let isVisible = tabBar.frame.origin.y < UIScreen.main.bounds.height
//			guard (isVisible != visible) else { return }
//
//			// get a frame calculation ready
//			let frame = tabBar.frame
//			let height = frame.size.height
//			let offsetY = (visible ? -height : height)
//
//			// zero duration means no animation
//			let duration:TimeInterval = (animated ? 0.3 : 0.0)
//
//			//  animate the tabBar
//			UIView.animate(withDuration: duration) {
//				self.tabBar.frame = frame.offsetBy(dx: 0, dy: offsetY)
//			}
//		}
	
	func orderedTabBarItemViews() -> [UIView] {
		let interactionViews = tabBar.subviews.filter({$0.isUserInteractionEnabled})
		return interactionViews.sorted(by: {$0.frame.minX < $1.frame.minX})
	}
	
}

extension UITextField {
	func setIcon(_ image: UIImage) {
	   let iconView = UIImageView(frame:
					  CGRect(x: 0, y: 7, width: 15, height: 15))
	   iconView.image = image
	   let iconContainerView: UIView = UIView(frame:
					  CGRect(x: 20, y: 0, width: 30, height: 30))
	   iconContainerView.addSubview(iconView)
	   leftView = iconContainerView
	   leftViewMode = .always
	}
}

extension UIScrollView {
   var currentPage: Int {
	  return Int((self.contentOffset.x + (0.5*self.frame.size.width))/self.frame.width)+1
   }
}

extension UIImage{
   
	public func rounded(radius: CGFloat) -> UIImage {
		let rect = CGRect(origin: .zero, size: size)
		UIGraphicsBeginImageContextWithOptions(size, false, 0)
		UIBezierPath(roundedRect: rect, cornerRadius: radius).addClip()
		draw(in: rect)
		return UIGraphicsGetImageFromCurrentImageContext()!
	}
	
	var roundedImage: UIImage {
		let rect = CGRect(origin:CGPoint(x: 0, y: 0), size: self.size)
		UIGraphicsBeginImageContextWithOptions(self.size, false, 1)
		UIBezierPath(
			roundedRect: rect,
			cornerRadius: self.size.height
			).addClip()
		draw(in: rect)
		return UIGraphicsGetImageFromCurrentImageContext()!
	}
	
	func imageWithInsets(insets: UIEdgeInsets) -> UIImage? {
		UIGraphicsBeginImageContextWithOptions(
			CGSize(width: self.size.width + insets.left + insets.right,
				   height: self.size.height + insets.top + insets.bottom), false, self.scale)
		let _ = UIGraphicsGetCurrentContext()
		let origin = CGPoint(x: insets.left, y: insets.top)
		self.draw(at: origin)
		let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return imageWithInsets
	}
	
	func saveToTemporaryFile() -> URL {
		let fileName = "\(ProcessInfo.processInfo.globallyUniqueString)_file.jpg"

		guard let data = self.jpegData(compressionQuality: 0.9) else {
			fatalError("Could not conert image to JPEG.")
		}

		let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)

		guard (try? data.write(to: fileURL, options: [.atomic])) != nil else {
			fatalError("Could not write the image to disk.")
		}

		return fileURL
	}
	
	func isImageSizeExceed(limitation:CGFloat)->Bool{
		var isExceed = false
		
		if self.size.height > limitation || self.size.width > limitation{
			isExceed = true
		}
		return isExceed
	}
	
	func resized(withPercentage percentage: CGFloat, isOpaque: Bool = true) -> UIImage? {
		let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
		let format = imageRendererFormat
		format.opaque = isOpaque
		return UIGraphicsImageRenderer(size: canvas, format: format).image {
			_ in draw(in: CGRect(origin: .zero, size: canvas))
		}
	}
	
	func resized(toWidth width: CGFloat, isOpaque: Bool = true) -> UIImage? {
		
		var actualHeight: CGFloat = size.height
		var actualWidth: CGFloat = size.width
		let maxHeight: CGFloat = width
		let maxWidth: CGFloat = width
		var imgRatio: CGFloat = actualWidth/actualHeight
		let maxRatio: CGFloat = maxWidth/maxHeight
		
		if (actualHeight > maxHeight || actualWidth > maxWidth) {
			if(imgRatio < maxRatio) {
				//adjust width according to maxHeight
				imgRatio = maxHeight / actualHeight
				actualWidth = imgRatio * actualWidth
				actualHeight = maxHeight
			} else if(imgRatio > maxRatio) {
				//adjust height according to maxWidth
				imgRatio = maxWidth / actualWidth
				actualHeight = imgRatio * actualHeight
				actualWidth = maxWidth
			} else {
				actualHeight = maxHeight
				actualWidth = maxWidth
			}
		}
		
		let canvas = CGSize(width: actualWidth, height: actualHeight)
		let format = imageRendererFormat
		format.opaque = isOpaque
		return UIGraphicsImageRenderer(size: canvas, format: format).image {
			_ in draw(in: CGRect(origin: .zero, size: canvas))
		}
	}
	
	func isImageMBExceed(limitation:Int)->Bool{
		var isExceed = false
		if let imageData = self.jpegData(compressionQuality: 1.0){
			let imageSize = Double(imageData.count)/1024.0/1024.0
			if imageSize > 1{
				isExceed = true
			}
		}
		
		return isExceed
	}

	func compressTo(_ expectedSizeInMb:Int) -> Data? {
		let sizeInBytes = expectedSizeInMb * 1024 * 1024
		var needCompress:Bool = true
		var imgData:Data?
		var compressingValue:CGFloat = 1.0
		while (needCompress && compressingValue > 0.0) {
			if let data:Data = self.jpegData(compressionQuality: compressingValue) {
				if data.count < sizeInBytes {
					needCompress = false
					imgData = data
				} else {
					compressingValue -= 0.1
				}
			}
		}

		if let data = imgData {
			if (data.count < sizeInBytes) {
				return data
			}
		}

		return nil
	}

	func getResizedImageData(imageSizeLimit:CGFloat, imageMBLimit:Int)->Data?{
		var rimage = self
		
		if rimage.isImageSizeExceed(limitation: imageSizeLimit){
			if let i = rimage.resized(toWidth: imageSizeLimit){
				rimage = i
			}
		}
		var imageData:Data?
		if rimage.isImageMBExceed(limitation: imageMBLimit) {
			if let i = rimage.compressTo(imageMBLimit){
				imageData = i
				
			}
		}
		
		if imageData == nil{
			return rimage.jpegData(compressionQuality: 1.0)
		}else{
			return imageData
		}
		
	}
	
	func getImageRatio() -> CGFloat {
		let imageRatio = CGFloat(self.size.width / self.size.height)
		return imageRatio
	}
	
	class func circle(diameter: CGFloat, color: UIColor) -> UIImage {
		   UIGraphicsBeginImageContextWithOptions(CGSize(width: diameter, height: diameter), false, 0)
		   let ctx = UIGraphicsGetCurrentContext()!
		   ctx.saveGState()

		   let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
		   ctx.setFillColor(color.cgColor)
		   ctx.fillEllipse(in: rect)

		   ctx.restoreGState()
		   let img = UIGraphicsGetImageFromCurrentImageContext()!
		   UIGraphicsEndImageContext()

		   return img
	}
}

//MARK: UIKit
extension UIFont {
	
	class func lightFontWithSize(size: CGFloat) -> UIFont {
		return UIFont(name: "PingFangHK-Light", size: size)!
	}
	   
	class func mediumFontWithSize(size: CGFloat) -> UIFont {
		return UIFont(name: "PingFangTC-Medium", size: size)!
	}
	
	class func regularFontWithSize(size: CGFloat) -> UIFont {
		return UIFont(name: "PingFangHK-Regular", size: size)!
	}
	
	class func semiboldFontWithSize(size: CGFloat) -> UIFont {
		return UIFont(name: "PingFangHK-Semibold", size: size)!
	}
	
	class func thinFontWithSize(size: CGFloat) -> UIFont {
		return UIFont(name: "PingFangHK-Thin", size: size)!
	}
	
	class func thinHelveticaNeue(size: CGFloat) -> UIFont {
		return UIFont(name: "HelveticaNeue-Thin", size: size)!
	}
	class func boldHelveticaNeue(size: CGFloat) -> UIFont {
		return UIFont(name: "HelveticaNeue-Bold", size: size)!
	}
	
	
	class func systemFont(ofSize fontSize: CGFloat, symbolicTraits: UIFontDescriptor.SymbolicTraits) -> UIFont? {
		return UIFont.systemFont(ofSize: fontSize).including(symbolicTraits: symbolicTraits)
	}

	func including(symbolicTraits: UIFontDescriptor.SymbolicTraits) -> UIFont? {
		var _symbolicTraits = self.fontDescriptor.symbolicTraits
		_symbolicTraits.update(with: symbolicTraits)
		return withOnly(symbolicTraits: _symbolicTraits)
	}

	func excluding(symbolicTraits: UIFontDescriptor.SymbolicTraits) -> UIFont? {
		var _symbolicTraits = self.fontDescriptor.symbolicTraits
		_symbolicTraits.remove(symbolicTraits)
		return withOnly(symbolicTraits: _symbolicTraits)
	}

	func withOnly(symbolicTraits: UIFontDescriptor.SymbolicTraits) -> UIFont? {
		guard let fontDescriptor = fontDescriptor.withSymbolicTraits(symbolicTraits) else { return nil }
		return .init(descriptor: fontDescriptor, size: pointSize)
	}
	
	func withTraits(traits:UIFontDescriptor.SymbolicTraits...) -> UIFont? {
		let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits))
		return descriptor != nil ? UIFont(descriptor: descriptor!, size: self.pointSize) : nil
	}
	
	func toggleBold() -> UIFont? {
		let traits = self.fontDescriptor.symbolicTraits.rawValue ^ CTFontSymbolicTraits.boldTrait.rawValue
		return withTraits(traits:UIFontDescriptor.SymbolicTraits(rawValue:traits))
	}
	
	func toggleItalic() -> UIFont? {
		let traits = self.fontDescriptor.symbolicTraits.rawValue ^ CTFontSymbolicTraits.italicTrait.rawValue
		return withTraits(traits:UIFontDescriptor.SymbolicTraits(rawValue:traits))
	}
	
	func resize(pointSize: CGFloat) -> UIFont? {
		return UIFont(descriptor: self.fontDescriptor, size: pointSize)
	}
	
	func header() -> UIFont? {
		return resize(pointSize: self.pointSize * 2)
	}
	
	func isBold() -> Bool {
		return self.fontDescriptor.symbolicTraits.contains(UIFontDescriptor.SymbolicTraits.traitBold);
	}
	
	func isItalic() -> Bool {
		return self.fontDescriptor.symbolicTraits.contains(UIFontDescriptor.SymbolicTraits.traitItalic);
	}
}

public extension UIColor {

	// Usage: UIColor(hex: 0xFC0ACE)
	convenience init(hex: Int) {
		self.init(hex: hex, alpha: 1)
	}

	// Usage: UIColor(hex: 0xFC0ACE, alpha: 0.25)
	convenience init(hex: Int, alpha: Double) {
		self.init(
			red: CGFloat((hex >> 16) & 0xff) / 255,
			green: CGFloat((hex >> 8) & 0xff) / 255,
			blue: CGFloat(hex & 0xff) / 255,
			alpha: CGFloat(alpha))
	}

	
	func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
		return UIGraphicsImageRenderer(size: size).image { rendererContext in
			self.setFill()
			rendererContext.fill(CGRect(origin: .zero, size: size))
		}
	}
	
}

//extension JSON{
//	mutating func appendIfArray(json:JSON){
//		if var arr = self.array{
//			arr.append(json)
//			self = JSON(arr);
//		}
//	}
//
//	mutating func appendIfDictionary(key:String,json:JSON){
//		if var dict = self.dictionary{
//			dict[key] = json;
//			self = JSON(dict);
//		}
//	}
//}

extension UITapGestureRecognizer {

	func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
		// Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
		let layoutManager = NSLayoutManager()
		let textContainer = NSTextContainer(size: CGSize.zero)
		let textStorage = NSTextStorage(attributedString: label.attributedText!)

		// Configure layoutManager and textStorage
		layoutManager.addTextContainer(textContainer)
		textStorage.addLayoutManager(layoutManager)

		// Configure textContainer
		textContainer.lineFragmentPadding = 0.0
		textContainer.lineBreakMode = label.lineBreakMode
		textContainer.maximumNumberOfLines = label.numberOfLines
		let labelSize = label.bounds.size
		textContainer.size = labelSize

		// Find the tapped character location and compare it to the specified range
		let locationOfTouchInLabel = self.location(in: label)
		let textBoundingBox = layoutManager.usedRect(for: textContainer)
		//let textContainerOffset = CGPointMake((labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
											  //(labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
		let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)

		//let locationOfTouchInTextContainer = CGPointMake(locationOfTouchInLabel.x - textContainerOffset.x,
														// locationOfTouchInLabel.y - textContainerOffset.y);
		let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
		let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
		return NSLocationInRange(indexOfCharacter, targetRange)
	}

	
}
//MARK: Foundation

extension String {
	var htmlToAttributedString: NSAttributedString? {
		guard let data = data(using: .utf8) else { return NSAttributedString() }
		do {
			return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
		} catch {
			return NSAttributedString()
		}
	}
	var htmlToString: String {
		return htmlToAttributedString?.string ?? ""
	}
	
	
	//Regex handling
	func matches(_ regex: String) -> Bool {
		return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
	}
	
	func filterStringWith(regex: String) -> [String] {
		do {
			let regex = try NSRegularExpression(pattern: regex)
			let results = regex.matches(in: self,
										range: NSRange(self.startIndex..., in: self))
			return results.flatMap {
				Range($0.range, in: self).map { String(self[$0]) }
			}
		} catch let error {
//			log.error("invalid regex: \(error.localizedDescription)")
			return []
		}
	}
	
	func substring(from: Int?, to: Int?) -> String {
		if let start = from {
			guard start < self.count else {
				return ""
			}
		}
		
		if let end = to {
			guard end >= 0 else {
				return ""
			}
		}
		
		if let start = from, let end = to {
			guard end - start >= 0 else {
				return ""
			}
		}
		
		let startIndex: String.Index
		if let start = from, start >= 0 {
			startIndex = self.index(self.startIndex, offsetBy: start)
		} else {
			startIndex = self.startIndex
		}
		
		let endIndex: String.Index
		if let end = to, end >= 0, end < self.count {
			endIndex = self.index(self.startIndex, offsetBy: end + 1)
		} else {
			endIndex = self.endIndex
		}
		
		return String(self[startIndex ..< endIndex])
	}
	
	func substring(from: Int) -> String {
		return self.substring(from: from, to: nil)
	}
	
	func substring(to: Int) -> String {
		return self.substring(from: nil, to: to)
	}
	
	func substring(from: Int?, length: Int) -> String {
		guard length > 0 else {
			return ""
		}
		
		let end: Int
		if let start = from, start > 0 {
			end = start + length - 1
		} else {
			end = length - 1
		}
		
		return self.substring(from: from, to: end)
	}
	
	func substring(length: Int, to: Int?) -> String {
		guard let end = to, end > 0, length > 0 else {
			return ""
		}
		
		let start: Int
		if let end = to, end - length > 0 {
			start = end - length + 1
		} else {
			start = 0
		}
		
		return self.substring(from: start, to: to)
	}
	
}

extension Array where Element: Hashable {
	func difference(from other: [Element]) -> [Element] {
		let thisSet = Set(self)
		let otherSet = Set(other)
		return Array(thisSet.symmetricDifference(otherSet))
	}
}

extension URL {
	/// test=1&a=b&c=d => ["test":"1","a":"b","c":"d"]
	public var queryParameters: [String: String]? {
		guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true), let queryItems = components.queryItems else {
			return nil
		}
		
		var parameters = [String: String]()
		for item in queryItems {
			parameters[item.name] = item.value
		}
		
		return parameters
	}
	
}

extension Date {
	/// returns an integer from 1 - 7, with 1 being Sunday and 7 being Saturday
	func dayNumberOfWeek() -> Int? {
		return Calendar.current.dateComponents([.weekday], from: self).weekday
	}
	
	func dayString(weekNumber:Int)->String?{
		switch weekNumber {
			case 1:
				return "SUNDAY"
			case 2:
				return "MONDAY"
			case 3:
				return "TUESDAY"
			case 4:
				return "WEDNESDAY"
			case 5:
				return "THURSDAY"
			case 6:
				return "FRIDAY"
			case 7:
				return "SATURDAY"
			default:
				return ""
		}
	}
	
	
	
	func timeAgoSinceDate() -> String {
		
		// From Time
		let fromDate = self
		
		// To Time
		let toDate = Date()
		
		// Estimation
		
		
		// Year
		if let interval = Calendar.current.dateComponents([.year], from: fromDate, to: toDate).year, interval > 0  {
			
			return "\(interval)年前"
		}
		
		// Month
		if let interval = Calendar.current.dateComponents([.month], from: fromDate, to: toDate).month, interval > 0  {
			
			return "\(interval)個月前"
		}
		
		// Day
		if let interval = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day, interval > 0 {
			
			if interval <= 6 {
				return "\(interval)日前"
			}else{
				let week = Int(interval/7)
				return "\(week)星期前"
			}
			
		}
		
		// Hours
		if let interval = Calendar.current.dateComponents([.hour], from: fromDate, to: toDate).hour, interval > 0 {
			
			return "\(interval)小時前"
		}
		
		// Minute
		if let interval = Calendar.current.dateComponents([.minute], from: fromDate, to: toDate).minute, interval > 0 {
			return "\(interval)分鐘前"
		}
		
		return "剛剛"
		
	}
	
	static func - (lhs: Date, rhs: Date) -> TimeInterval {
		return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
	}
	
}

extension NSMutableAttributedString {

	func setColor(color: UIColor, forText stringValue: String) {
	   let range: NSRange = self.mutableString.range(of: stringValue, options: .caseInsensitive)
		self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
	}
	
	
	func setUnderline(underlineColor:UIColor, stringValue: String) {
	   let range: NSRange = self.mutableString.range(of: stringValue, options: .caseInsensitive)
		self.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: range)
		self.addAttribute(NSAttributedString.Key.underlineColor, value: underlineColor, range: range)
	}
	
	func setClickableUrl(urlString:String,forText stringValue: String ){
		let range: NSRange = self.mutableString.range(of: stringValue, options: .caseInsensitive)
		 self.addAttribute(NSAttributedString.Key.link, value: urlString, range: range)
	}
	
	func setFont(font: UIFont, forText stringValue: String) {
	   let range: NSRange = self.mutableString.range(of: stringValue, options: .caseInsensitive)
		self.addAttribute(NSAttributedString.Key.font, value: font, range: range)
	}
	
	func setLineSpace(lineSpacing:CGFloat,forText stringValue: String){
		let range: NSRange = self.mutableString.range(of: stringValue, options: .caseInsensitive)
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = lineSpacing
		self.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
	}

}
//MARK: Controller
extension UIViewController {
	
	//TODO : enhancement , can add custom button in alertcontroller
	
//	func showAlertWith(message: AlertMessage , style: UIAlertController.Style = .alert) {
//		let alertController = UIAlertController(title: message.title, message: message.body, preferredStyle: style)
//		let action = UIAlertAction(title: Lang.get(key: "Alert.default.option.ok.title"), style: .default) { (action) in
////            self.dismiss(animated: true, completion: nil)
//		}
//		alertController.addAction(action)
//		DispatchQueue.main.async {
//			self.present(alertController, animated: true, completion: nil)
//		}
//	}
//
//	func showOverlayMessage(message:String){
//		//TODO : Change to overlay
//		DispatchQueue.main.async {
//			self.showAlertWith(message: AlertMessage(title: "", body: message))
//		}
//	}
//
//	func showError(error:FMError){
//		let alertController = UIAlertController(title: nil, message: "\(error.message):\(error.code)", preferredStyle: .alert)
//		let action = UIAlertAction(title: Lang.get(key: "Alert.default.option.ok.title"), style: .default) { (action) in
////            self.dismiss(animated: true, completion: nil)
//		}
//		alertController.addAction(action)
//		DispatchQueue.main.async {
//			self.present(alertController, animated: true, completion: nil)
//		}
//	}
//
//	func showError(error:Error){
//		let alertController = UIAlertController(title: nil, message: "\(error.localizedDescription)", preferredStyle: .alert)
//		let action = UIAlertAction(title: Lang.get(key: "Alert.default.option.ok.title"), style: .default) { (action) in
////            self.dismiss(animated: true, completion: nil)
//		}
//		alertController.addAction(action)
//		DispatchQueue.main.async {
//			self.present(alertController, animated: true, completion: nil)
//		}
//	}
	
	
	
	func shouldHideLoader(isHidden: Bool) {
		if isHidden {
//            MBProgressHUD.hide(for: self.view, animated: true)
		} else {
//            MBProgressHUD.showAdded(to: self.view, animated: true)
		}
	}
	
	//Hide keyboard
	func hideKeyboardWhenTappedAround() {
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
		tap.cancelsTouchesInView = false
		view.addGestureRecognizer(tap)
	}

	@objc func dismissKeyboard() {
		view.endEditing(true)
	}

	
}

//MARK: Auto Layout
public extension NSLayoutConstraint {
	/// Chainging a layout constraint with priority
	func withPriority(priority: UILayoutPriority) -> NSLayoutConstraint {
		self.priority = priority
		return self
	}
	func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
		return NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
	}
}

extension UITextInput {
	var selectedRange: NSRange? {
		guard let range = selectedTextRange else { return nil }
		let location = offset(from: beginningOfDocument, to: range.start)
		let length = offset(from: range.start, to: range.end)
		return NSRange(location: location, length: length)
	}
}

//	func compressSizeByScale (sourceImage:UIImage, scaledToWidth: CGFloat) -> UIImage? {
//		let oldWidth = sourceImage.size.width
//		let scaleFactor = scaledToWidth / oldWidth
//
//		let newHeight = sourceImage.size.height * scaleFactor
//		let newWidth = oldWidth * scaleFactor
//
//		UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
//		sourceImage.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
//		let newImage = UIGraphicsGetImageFromCurrentImageContext()
//		UIGraphicsEndImageContext()
//		return newImage
//	}
	
//func resizedTo1MB() -> UIImage? {
//	guard let imageData = self.pngData() else { return nil }
//
//	var resizingImage = self
//	var imageSizeKB = Double(imageData.count) / 1024.0
//
//	while imageSizeKB > 1024 {
//		guard let resizedImage = resizingImage.resized(withPercentage: 0.9),
//			let imageData = resizedImage.pngData()
//			else { return nil }
//
//		resizingImage = resizedImage
//		imageSizeKB = Double(imageData.count) / 1024.0
//	}
//
//	return resizingImage
//}
