import UIKit

public struct Theme {
    
    // MARK: - Props
    public let colors: Colors
    public let fonts: Fonts

    // MARK: - Lifecycle
    public init(colors: Colors, fonts: Fonts) {
        self.colors = colors
        self.fonts = fonts
    }
    
    public func color(forToken tokenName: TokenName) -> UIColor? {
        colors.color(forToken: tokenName)
    }
    
    public func font(forToken tokenName: TokenName) -> UIFont? {
        fonts.font(forToken: tokenName)
    }

    public struct Colors {
        
        public let colors: [TokenName: UIColor]

        public init(colors: [String: UIColor]) {
            self.colors = Dictionary(uniqueKeysWithValues: colors.map { key, value in (TokenName(key), value) })
        }

        public init(bundle: Bundle, name: String) {
            colors = [
                "plain": UIColor(named: "\(name)/plain", in: bundle, compatibleWith: nil)!,
                "boolean": UIColor(named: "\(name)/boolean", in: bundle, compatibleWith: nil)!,
                "comment": UIColor(named: "\(name)/comment", in: bundle, compatibleWith: nil)!,
                "constructor": UIColor(named: "\(name)/constructor", in: bundle, compatibleWith: nil)!,
                "function.call": UIColor(named: "\(name)/function.call", in: bundle, compatibleWith: nil)!,
                "include": UIColor(named: "\(name)/include", in: bundle, compatibleWith: nil)!,
                "keyword": UIColor(named: "\(name)/keyword", in: bundle, compatibleWith: nil)!,
                "keyword.function": UIColor(named: "\(name)/keyword.function", in: bundle, compatibleWith: nil)!,
                "keyword.return": UIColor(named: "\(name)/keyword.return", in: bundle, compatibleWith: nil)!,
                "method": UIColor(named: "\(name)/method", in: bundle, compatibleWith: nil)!,
                "number": UIColor(named: "\(name)/number", in: bundle, compatibleWith: nil)!,
                "operator": UIColor(named: "\(name)/operator", in: bundle, compatibleWith: nil)!,
                "parameter": UIColor(named: "\(name)/parameter", in: bundle, compatibleWith: nil)!,
                "punctuation.special": UIColor(named: "\(name)/punctuation.special", in: bundle, compatibleWith: nil)!,
                "string": UIColor(named: "\(name)/string", in: bundle, compatibleWith: nil)!,
                "text.literal": UIColor(named: "\(name)/text.literal", in: bundle, compatibleWith: nil)!,
                "text.title": UIColor(named: "\(name)/text.title", in: bundle, compatibleWith: nil)!,
                "type": UIColor(named: "\(name)/type", in: bundle, compatibleWith: nil)!,
                "variable.builtin": UIColor(named: "\(name)/variable.builtin", in: bundle, compatibleWith: nil)!,
                "variable": UIColor(named: "\(name)/variable", in: bundle, compatibleWith: nil)!
            ]
        }
        
        public func color(forToken tokenName: TokenName) -> UIColor? {
            Theme.lookupHierarchical(tokenName, in: colors)
        }
    }

    public struct Fonts {

        public let fonts: [TokenName: UIFont]

        public init(fonts: [String: UIFont]) {
            self.fonts = Dictionary(uniqueKeysWithValues: fonts.map { key, value in (TokenName(key), value) })
        }

        public init(bundle: Bundle, name: String) {
            fonts = [
                "plain": UIFont.monospacedSystemFont(ofSize: 0, weight: .regular),
                "boolean": UIFont.monospacedSystemFont(ofSize: 0, weight: .regular),
                "comment": UIFont.monospacedSystemFont(ofSize: 0, weight: .regular),
                "constructor": UIFont.monospacedSystemFont(ofSize: 0, weight: .medium),
                "function.call": UIFont.monospacedSystemFont(ofSize: 0, weight: .regular),
                "include": UIFont.monospacedSystemFont(ofSize: 0, weight: .regular),
                "keyword": UIFont.monospacedSystemFont(ofSize: 0, weight: .medium),
                "keyword.function": UIFont.monospacedSystemFont(ofSize: 0, weight: .medium),
                "keyword.return": UIFont.monospacedSystemFont(ofSize: 0, weight: .medium),
                "method": UIFont.monospacedSystemFont(ofSize: 0, weight: .regular),
                "number": UIFont.monospacedSystemFont(ofSize: 0, weight: .regular),
                "operator": UIFont.monospacedSystemFont(ofSize: 0, weight: .regular),
                "parameter": UIFont.monospacedSystemFont(ofSize: 0, weight: .regular),
                "punctuation.special": UIFont.monospacedSystemFont(ofSize: 0, weight: .regular),
                "string": UIFont.monospacedSystemFont(ofSize: 0, weight: .regular),
                "text.literal": UIFont.monospacedSystemFont(ofSize: 0, weight: .regular),
                "text.title": UIFont.monospacedSystemFont(ofSize: 0, weight: .medium),
                "type": UIFont.monospacedSystemFont(ofSize: 0, weight: .regular),
                "variable.builtin": UIFont.monospacedSystemFont(ofSize: 0, weight: .regular),
                "variable": UIFont.monospacedSystemFont(ofSize: 0, weight: .regular)
            ]

        }

        public func font(forToken tokenName: TokenName) -> UIFont? {
            Theme.lookupHierarchical(tokenName, in: fonts)
        }
    }

    /// Tree-sitter capture names are dotted (e.g. `type.builtin`,
    /// `keyword.repeat`). Themes typically only define the parent
    /// (`type`, `keyword`); the child should fall back to it. Without
    /// this, captures like `@type.builtin` and `@keyword.repeat` render
    /// as plain text.
    fileprivate static func lookupHierarchical<V>(
        _ tokenName: TokenName,
        in dict: [TokenName: V]
    ) -> V? {
        if let exact = dict[tokenName] { return exact }
        var name = tokenName.description
        while let dot = name.lastIndex(of: ".") {
            name = String(name[..<dot])
            if let parent = dict[TokenName(name)] { return parent }
        }
        return nil
    }
}
