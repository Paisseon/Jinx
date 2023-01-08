import Foundation

struct HashMap<T, U> {
    private var items: [String: T?] = [:]
    
    mutating func set(
        _ item: T?,
        for key: U
    ) {
        if items["\(key)"] == nil {
            items["\(key)"] = item
        }
    }
    
    func get(
        _ key: U
    ) -> T? {
        if let val: T? = items["\(key)"] {
            return val
        }
        
        return nil
    }
}

var hndlMap: HashMap<UnsafeMutableRawPointer, String> = .init()
var impMap: HashMap<IMP, Any.Type> = .init()
var voidMap: HashMap<UnsafeMutableRawPointer, Any.Type> = .init()
