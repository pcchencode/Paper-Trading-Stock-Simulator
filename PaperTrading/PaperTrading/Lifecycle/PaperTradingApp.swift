//
//  PaperTradingApp.swift
//  PaperTrading
//
//  Created by Apps4World on 3/5/21.
//

import SwiftUI
import GoogleMobileAds

@main
struct PaperTradingApp: App {
    
    @State private var showWhatsNew: Bool = false
    
    // MARK: - Main rendering function
    var body: some Scene {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        return WindowGroup {
            DashboardContentView()
                .sheet(isPresented: $showWhatsNew, content: {
                    AppFeaturesView()
                })
                .onAppear(perform: {
                    if !UserDefaults.standard.bool(forKey: "didShowWhatsNew") {
                        showWhatsNew = true
                        UserDefaults.standard.setValue(true, forKey: "didShowWhatsNew")
                        UserDefaults.standard.synchronize()
                    }
                })
        }
    }
}

// MARK: - Google AdMob Interstitial - Support class
class Interstitial: NSObject, GADFullScreenContentDelegate {
    var interstitial: GADInterstitialAd?
    private var didLoadAd: Bool = false
    
    /// Default initializer of interstitial class
    init(previewMode: Bool = false) {
        super.init()
        if previewMode { return }
        loadInterstitial()
    }
    
    /// Request AdMob Interstitial ads
    func loadInterstitial() {
        if didLoadAd { return }
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: AppConfig.adMobAdID, request: request, completionHandler: { [self] ad, error in
            if ad != nil {
                didLoadAd = true
                interstitial = ad
                interstitial?.fullScreenContentDelegate = self
            }
        })
    }
    
    func showInterstitialAds() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if self.interstitial != nil {
                let root = UIApplication.shared.windows.first?.rootViewController
                self.interstitial?.present(fromRootViewController: root!)
            }
        }
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        loadInterstitial()
    }
}

// MARK: - Extensions
extension Path {
    static func chart(withPoints points: [Double], highLowPoint: CGPoint, closePath: Bool) -> Path {
        var path = Path()
        if closePath { path.move(to: .zero) }
        var p1 = CGPoint(x: 0, y: CGFloat(points[0]-points.min()!)*highLowPoint.y)
        if closePath { path.addLine(to: p1) } else { path.move(to: p1) }
        for pointIndex in 1..<points.count {
            let p2 = CGPoint(x: highLowPoint.x * CGFloat(pointIndex), y: highLowPoint.y*CGFloat(points[pointIndex]-points.min()!))
            let midPoint = CGPoint.midPointForPoints(p1: p1, p2: p2)
            path.addQuadCurve(to: midPoint, control: CGPoint.controlPointForPoints(p1: midPoint, p2: p1))
            path.addQuadCurve(to: p2, control: CGPoint.controlPointForPoints(p1: midPoint, p2: p2))
            p1 = p2
        }
        if closePath {
            path.addLine(to: CGPoint(x: p1.x, y: 0))
            path.closeSubpath()
        }
        return path
    }
}

extension CGPoint {
    static func midPointForPoints(p1:CGPoint, p2:CGPoint) -> CGPoint {
        return CGPoint(x:(p1.x + p2.x) / 2,y: (p1.y + p2.y) / 2)
    }
    
    static func controlPointForPoints(p1:CGPoint, p2:CGPoint) -> CGPoint {
        var controlPoint = CGPoint.midPointForPoints(p1:p1, p2:p2)
        let diffY = abs(p2.y - controlPoint.y)
        if (p1.y < p2.y) {
            controlPoint.y += diffY
        } else if (p1.y > p2.y) {
            controlPoint.y -= diffY
        }
        return controlPoint
    }
}

/// Create a shape with specific rounded corners
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension Double {
    var dollarAmount: String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current
        return currencyFormatter.string(from: NSNumber(value: self)) ?? "- -"
    }
    
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        return Binding(
            get: { self.wrappedValue },
            set: { selection in
                self.wrappedValue = selection
                handler(selection)
        })
    }
}

// MARK: - Custom image view class to load images from web
public struct RemoteImage: View {
    @ObservedObject var remoteImageUrl: RemoteImageUrl
    private var usePlaceholder: String = "image_placeholder"
    private var imageName: String = ""

    public init(placeholder: String = "image_placeholder", imageUrl: String) {
        imageName = imageUrl
        usePlaceholder = placeholder
        remoteImageUrl = RemoteImageUrl(imageUrl: imageUrl)
    }

    public var body: some View {
        Image(uiImage: UIImage(named: imageName) ?? UIImage(data: remoteImageUrl.data) ?? ImageCache.localImages[imageName] ?? UIImage(named: usePlaceholder)!)
            .resizable().aspectRatio(contentMode: .fill)
    }
}

// MARK: - Load image from URL
class RemoteImageUrl: ObservableObject {
    @Published var data = Data()
    var imageCache = ImageCache.getImageCache()
    
    init(imageUrl: String) {
        if let cacheImage = imageCache.get(forKey: imageUrl)?.pngData() {
            DispatchQueue.main.async { self.data = cacheImage }
        } else {
            if let documentsFolderImage = imageCache.loadImageFromDocumentDirectory(fileName: imageUrl)?.jpegData(compressionQuality: 1.0) {
                DispatchQueue.main.async { self.data = documentsFolderImage }
            }
            guard let url = URL(string: imageUrl) else { return }
            URLSession.shared.dataTask(with: url) { (data, _, _) in
                DispatchQueue.main.async {
                    if let imageData = data, let image = UIImage(data: imageData) {
                        self.data = imageData
                        self.imageCache.set(forKey: imageUrl, image: image)
                    }
                }
            }.resume()
        }
    }
}

// MARK: - Image caching system
public class ImageCache {
    var cache = NSCache<NSString, UIImage>()
    
    public func get(forKey: String) -> UIImage? {
        cache.object(forKey: NSString(string: forKey))
    }
    
    public func set(forKey: String, image: UIImage) {
        ImageCache.localImages[forKey] = image
        saveImageInDocumentDirectory(image: image, fileName: forKey)
        cache.setObject(image, forKey: NSString(string: forKey))
    }
    
    public static var localImages = [String: UIImage]()
    
    private func saveImageInDocumentDirectory(image: UIImage, fileName: String) {
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documentsUrl.appendingPathComponent(fileName.replacingOccurrences(of: "/", with: "_"))
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            try? imageData.write(to: fileURL, options: .atomic)
        }
    }
    
    public func loadImageFromDocumentDirectory(fileName: String) -> UIImage? {
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let fileURL = documentsUrl.appendingPathComponent(fileName.replacingOccurrences(of: "/", with: "_"))
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {}
        return nil
    }
}

extension ImageCache {
    private static var imageCache = ImageCache()
    static func getImageCache() -> ImageCache {
        return imageCache
    }
}
