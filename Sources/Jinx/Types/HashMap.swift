struct HashMap<T: Hashable, U> {
    private var items: [T: U?] = [:]
    
    mutating func set(
        _ item: U?,
        for key: T
    ) {
        if items[key] == nil {
            items[key] = item
        }
    }
    
    func get(
        _ key: T
    ) -> U? {
        items[key] ?? nil
    }
}
