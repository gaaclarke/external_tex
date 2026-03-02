import Flutter
import UIKit
import CoreVideo
import CoreGraphics

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var texture: TriangleTexture?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "com.example.external_tex") {
        self.texture = TriangleTexture()
        let textureId = registrar.textures().register(self.texture!)
        
        let channel = FlutterMethodChannel(name: "com.example.external_tex/texture", binaryMessenger: registrar.messenger())
        channel.setMethodCallHandler { (call, result) in
            if call.method == "getTextureId" {
                result(textureId)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
    }
  }
}

class TriangleTexture: NSObject, FlutterTexture {
    var pixelBuffer: CVPixelBuffer?
    
    override init() {
        super.init()
        pixelBuffer = createBuffer()
    }
    
    func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
        if let buffer = pixelBuffer {
            return Unmanaged.passRetained(buffer)
        }
        return nil
    }
    
    private func createBuffer() -> CVPixelBuffer? {
        let width = 200
        let height = 200
        
        var buffer: CVPixelBuffer?
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferMetalCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferIOSurfacePropertiesKey: [:] as CFDictionary
        ] as CFDictionary
        
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         width,
                                         height,
                                         kCVPixelFormatType_32BGRA,
                                         attrs,
                                         &buffer)
        
        guard status == kCVReturnSuccess, let unwrappedBuffer = buffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(unwrappedBuffer, [])
        let data = CVPixelBufferGetBaseAddress(unwrappedBuffer)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        
        let context = CGContext(data: data,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(unwrappedBuffer),
                                space: colorSpace,
                                bitmapInfo: bitmapInfo)
        
        if let context = context {
            context.clear(CGRect(x: 0, y: 0, width: width, height: height))
            
            context.setFillColor(CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0))
            context.move(to: CGPoint(x: width / 2, y: 0))
            context.addLine(to: CGPoint(x: width, y: height))
            context.addLine(to: CGPoint(x: 0, y: height))
            context.closePath()
            context.fillPath()
        }
        
        CVPixelBufferUnlockBaseAddress(unwrappedBuffer, [])
        return unwrappedBuffer
    }
}
