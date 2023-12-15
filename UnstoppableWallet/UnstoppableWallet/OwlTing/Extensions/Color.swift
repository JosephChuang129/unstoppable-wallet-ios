import UIKit

extension UIColor {
    public static let placeholderGray = UIColor(hex: 0xC7C7CD)
}

extension UIColor {
    
    public static var themeBlackBorder: UIColor { color(dark: .themeGray, light: .themeDarker) }
    public static var themePlaceholder: UIColor { color(dark: .placeholderText, light: .themeDarker) }
    
    private static func color(dark: UIColor, light: UIColor) -> UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        }
    }
}
