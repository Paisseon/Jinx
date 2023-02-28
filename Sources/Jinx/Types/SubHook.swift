import ObjectiveC

public class SubHook<T>: Groupable {
    // MARK: Lifecycle

    public init(selector: Selector, type: T.Type, replacement: T) {
        self.selector = selector
        self.type = type
        self.replacement = replacement
        id = selector.hashValue
    }

    // MARK: Public

    public let selector: Selector
    public let replacement: T
    public let type: T.Type
    public var id: Int

    public var orig: T {
        if case let .raw(ptr) = _orig {
            return unsafeBitCast(ptr, to: T.self)
        }

        if case let .opaque(ptr) = _orig {
            return unsafeBitCast(ptr, to: T.self)
        }

        return unsafeBitCast(_orig, to: T.self)
    }

    public func hook(
        _ cls: AnyClass?
    ) -> JinxResult {
        guard let cls else {
            return .noClass
        }

        return PowPow.replace(cls, selector, with: replacement, orig: &_orig)
    }

    public func unhook(
        _ cls: AnyClass?
    ) -> JinxResult {
        guard let cls else {
            return .noClass
        }

        return PowPow.replace(cls, selector, with: _orig, orig: &_orig)
    }

    // MARK: Private

    private var _orig: Pointer? {
        get {
            PowPow.origMap.get(id) ?? nil
        }

        set {
            PowPow.origMap.set(newValue, for: id)
        }
    }
}
