public struct NonEmpty<C: Collection>: Collection {
    public subscript(position: C.Index) -> C.Element {
        _read { yield collection[position] }
    }
    
    public func index(after i: C.Index) -> C.Index { collection.index(after: i) }
    
    public var startIndex: C.Index { collection.startIndex }
    public var endIndex: C.Index { collection.endIndex }
    
    public typealias Index = C.Index
    let collection: C
    
    struct EmptyCollection: Error {}
    
    init(collection: C) throws {
        if collection.isEmpty { throw EmptyCollection() }
        self.collection = collection
    }
}

extension NonEmpty: RandomAccessCollection, BidirectionalCollection where C: RandomAccessCollection {
    public func index(before i: C.Index) -> C.Index {
        return collection.index(before: i)
    }
}

extension Collection {
    func asNonEmpty() throws -> NonEmpty<Self> {
        try NonEmpty(collection: self)
    }
}

extension NonEmpty: Equatable where C: Equatable {
    public static func == (lhs: NonEmpty<C>, rhs: NonEmpty<C>) -> Bool {
        lhs.collection == rhs.collection
    }
}
