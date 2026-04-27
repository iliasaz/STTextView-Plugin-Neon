import Cocoa
import STTextView
import Neon

class STTextViewSystemInterface: TextSystemInterface {

    typealias AttributeProvider = (Neon.Token) -> [NSAttributedString.Key: Any]?

    private let textView: STTextView
    private let attributeProvider: AttributeProvider

    init(textView: STTextView, attributeProvider: @escaping AttributeProvider) {
        self.textView = textView
        self.attributeProvider = attributeProvider
    }

    func clearStyle(in range: NSRange) {
        guard let textRange = NSTextRange(range, in: textView.textContentManager) else {
            assertionFailure()
            return
        }

        // Atomic-replace with an empty dict instead of `removeRenderingAttribute`.
        // The remove path leaves nil holes in `_NSTextRunStorage` on macOS 26 that
        // crash the next overlapping `addRenderingAttribute` during rapid scroll.
        textView.textLayoutManager.setRenderingAttributes([:], for: textRange)
        textView.addAttributes([.font: textView.font], range: range)
    }

    func applyStyle(to token: Neon.Token) {
        guard let attrs = attributeProvider(token),
              let textRange = NSTextRange(token.range, in: textView.textContentManager)
        else {
            return
        }

        var renderingAttrs: [NSAttributedString.Key: Any] = [:]
        var textAttrs: [NSAttributedString.Key: Any] = [:]

        for attr in attrs {
            if attr.key == .foregroundColor {
                renderingAttrs[attr.key] = attr.value
            } else {
                textAttrs[attr.key] = attr.value
            }
        }

        if !renderingAttrs.isEmpty {
            // `setRenderingAttributes` writes the dict atomically and skips the
            // merge-with-existing-runs path that `addRenderingAttribute` uses.
            textView.textLayoutManager.setRenderingAttributes(renderingAttrs, for: textRange)
        }

        if !textAttrs.isEmpty {
            textView.addAttributes(textAttrs, range: token.range)
        }
    }

    var length: Int {
        textView.textContentManager.length
    }

    var visibleRange: NSRange {
        guard let viewportRange = textView.textLayoutManager.textViewportLayoutController.viewportRange else {
            return .zero
        }

        return NSRange(viewportRange, provider: textView.textContentManager)
    }
}
