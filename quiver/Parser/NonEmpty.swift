struct NonEmpty<C: Collection>: Collection {
    subscript(position: C.Index) -> C.Element {
        _read { yield collection[position] }
    }
    
    func index(after i: C.Index) -> C.Index { collection.index(after: i) }
    
    var startIndex: C.Index { collection.startIndex }
    var endIndex: C.Index { collection.endIndex }
    
    typealias Index = C.Index
    let collection: C
    
    struct EmptyCollection: Error {}
    
    init(collection: C) throws {
        if collection.isEmpty { throw EmptyCollection() }
        self.collection = collection
    }
}

extension Collection {
    func asNonEmpty() throws -> NonEmpty<Self> {
        try NonEmpty(collection: self)
    }
}

extension NonEmpty: Equatable where C: Equatable {
    static func == (lhs: NonEmpty<C>, rhs: NonEmpty<C>) -> Bool {
        lhs.collection == rhs.collection
    }
}
