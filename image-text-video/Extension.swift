//
//  Extension.swift
//  
//
//  Created by dl on 09/01/2022.
//



import SwiftUI
import UIKit
import AVFoundation
import LinkPresentation

extension View {
    /// Sets the text color for a navigation bar title.
    /// - Parameter color: Color the title should be
    ///
    /// Supports both regular and large titles.
    @available(iOS 14, *)
    func navigationBarTitleTextColor(_ color: Color) -> some View {
        let uiColor = UIColor(color)
    
        // Set appearance for both normal and large sizes.
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: uiColor ]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: uiColor ]
    
        return self
    }
}

extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self.ignoresSafeArea(.all))
        let view = controller.view
       //new : https://stackoverflow.com/a/69579510/2814778
//        let format = UIGraphicsImageRendererFormat()
//                format.scale = 1
//                format.opaque = true
        
        
        // 640x480
     //   let targetSize =  CGSize(width: 1920, height: 1280)
    let targetSize = controller.view.intrinsicContentSize // CGSize(width: 640, height: 480) //CGSize(width: 640, height: 480)//controller.view.intrinsicContentSize // CGSize(width: 300, height: 700)
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
       
//new : https://stackoverflow.com/a/69579510/2814778
//        let window = UIWindow(frame: view!.bounds)
//              window.addSubview(controller.view)
//              window.makeKeyAndVisible()
        
        
//
        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
        //new : https://stackoverflow.com/a/69579510/2814778
//        let renderer = UIGraphicsImageRenderer(bounds: view!.bounds, format: format)
//                return renderer.image { rendererContext in
//                        view?.layer.render(in: rendererContext.cgContext)
//                }
        
        
        
        
    }
    
}

extension UIColor {
    static var primaryColor: UIColor {
        return UIColor(named: "darkGreen") ?? UIColor.black
    }

}

//extension UIImage {
//extension UIImage {
//
//    func isLandcape() -> Bool {
//        return self.size.width > self.size.height
//    }
//
//
//
//
//}
extension CGImage {
    // 29 OCt
    static func pixelBuffer(fromImage image: CGImage, size: CGSize) throws -> CVPixelBuffer {
        print("pixelBuffer from CGImage")
        let options: CFDictionary = [kCVPixelBufferCGImageCompatibilityKey as String: true, kCVPixelBufferCGBitmapContextCompatibilityKey as String: true] as CFDictionary
        var pxbuffer: CVPixelBuffer? = nil
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32ARGB, options, &pxbuffer) //kCVPixelFormatType_32ARGB
        guard let buffer = pxbuffer, status == kCVReturnSuccess else { throw NSError() }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        guard let pxdata = CVPixelBufferGetBaseAddress(buffer)
        else { throw NSError() }
        let bytesPerRow = CVPixelBufferGetBytesPerRow(buffer)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()

         
            guard let context = CGContext(data: pxdata, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else { print("error in `CG context")
                throw NSError() }
        context.concatenate(CGAffineTransform(rotationAngle: 0))
        context.draw(image, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        CVPixelBufferUnlockBaseAddress(buffer, [])
        
        return buffer
        }
}
//extension CIImage {
//    func createPixelBuffer() -> CVPixelBuffer? {
////        guard  var staticImage =  CIImage(image: self)
////        else {
////            print("error: ")
////
////            return
////        }
//        //create a variable to hold the pixelBuffer
//        var pixelBuffer: CVPixelBuffer? = nil
//        //set some standard attributes
//        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
//             kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
//        //create the width and height of the buffer to match the image
////        let width:Int = Int(staticImage.extent.size.width)
////        let height:Int = Int(staticImage.extent.size.height)
//
//        let width:Int = Int(self.extent.size.width)
//        let height:Int = Int(self.extent.size.height)
//        //create a buffer (notice it uses an in/out parameter for the pixelBuffer variable)
//
//        print("Dimention of buffer is \(width) x \(height)")
////
//        CVPixelBufferCreate(kCFAllocatorDefault,
//                            width,
//                            height,
//                            kCVPixelFormatType_32BGRA, //32BGRA
//                            attrs,
//                            &pixelBuffer)
//
//
////        CVPixelBufferCreate(kCFAllocatorDefault,
////                            640,
////                            480,
////                            kCVPixelFormatType_32BGRA,
////                            attrs,
////                            &pixelBuffer)
//        //create a CIContext
//        let context = CIContext()
//
//        //use the context to render the image into the pixelBuffer
//        guard let buffer = pixelBuffer else {
//            return pixelBuffer
//        }
//        context.render(self, to: buffer)
//        return buffer
//
//      //  return pixelBuffer
//    }
//}

extension UIImage{
    func buffer(from image: UIImage) -> CVPixelBuffer? {
      let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
      var pixelBuffer : CVPixelBuffer?
      let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
      guard (status == kCVReturnSuccess) else {
        return nil
      }

      CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
      let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

      let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
      let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

      context?.translateBy(x: 0, y: image.size.height)
      context?.scaleBy(x: 1.0, y: -1.0)

      UIGraphicsPushContext(context!)
      image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
      UIGraphicsPopContext()
      CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

      return pixelBuffer
    }
}
extension Int {
    
    func getTimeStr() -> String {
        let timeInSeconds = Int(self)
        let hours = timeInSeconds  / 3600
        let minutes = (timeInSeconds % 3600) / 60
        let seconds = (timeInSeconds % 3600) % 60
        let timeStr =  hours == 0 ? String(format: "%02d:%02d", minutes,seconds): String(format: "%02d:%02d:%02d", hours, minutes,seconds)
        return timeStr
    }
}
    
 


struct Resizer: View {
    var body: some View {
        Rectangle()
            .fill(Color.yellow)
            .frame(width: 8, height: 75)
            .cornerRadius(10)
    }
}



