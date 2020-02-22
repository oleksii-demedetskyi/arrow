class Command {
    let action: () -> ()
    
    func perform() {
        self.action()
    }
    
    init(action: @escaping () -> ()) {
        self.action = action
    }
    
    static let nop = Command { }
    
    static func bind(_ action: Action, to dispatch: @escaping (Action) -> ()) -> Command {
        return Command {
            dispatch(action)
        }
    }
}
