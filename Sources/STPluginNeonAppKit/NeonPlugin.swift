import Cocoa

import STTextView
@_exported import SwiftTreeSitter

// tree-sitter-xcframework
//import TreeSitter
import TreeSitterResource

public struct NeonPlugin: STPlugin {
    /// Closure invoked on the main actor after each successful parse, with the
    /// latest stable parse tree. Hosts use this to drive features (autocomplete,
    /// outlines, etc.) without running a second parser.
    public typealias TreeUpdateHandler = @MainActor @Sendable (SwiftTreeSitter.Tree) -> Void

    private let theme: Theme
    private let language: TreeSitterLanguage
    private let onTreeUpdated: TreeUpdateHandler?

    public init(theme: Theme = .default, language: TreeSitterLanguage) {
        self.theme = theme
        self.language = language
        self.onTreeUpdated = nil
    }

    public init(theme: Theme = .default,
                language: TreeSitterLanguage,
                onTreeUpdated: TreeUpdateHandler?) {
        self.theme = theme
        self.language = language
        self.onTreeUpdated = onTreeUpdated
    }

    public func setUp(context: any Context) {

        context.events.onWillChangeText { affectedRange, replacementString in
            let range = NSRange(affectedRange, in: context.textView.textContentManager)
            context.coordinator.willChangeContent(in: range)
        }

        context.events.onDidChangeText { affectedRange, replacementString in
            guard let replacementString else { return }

            let range = NSRange(affectedRange, in: context.textView.textContentManager)
            context.coordinator.didChangeContent(context.textView.textContentManager, in: range, delta: replacementString.utf16.count - range.length, limit: context.textView.textContentManager.length)
        }

        context.events.onDidLayoutViewport { viewportRange in
            context.coordinator.updateViewportRange(viewportRange)
        }
    }

    public func makeCoordinator(context: CoordinatorContext) -> Coordinator {
        Coordinator(textView: context.textView,
                    theme: theme,
                    language: language,
                    onTreeUpdated: onTreeUpdated)
    }

}

