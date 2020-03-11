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

class CommandWith<T> {
    let action: (T) -> ()
    
    func perform(with value: T) {
        self.action(value)
    }
    
    init(action: @escaping (T) -> ()) {
        self.action = action
    }
    
    static var nop: CommandWith {
        CommandWith { _ in }
    }
    
    static func bind(_ action: @escaping (T) -> Action, to dispatch: @escaping (Action) -> ()) -> CommandWith {
        return CommandWith { value in
            dispatch(action(value))
        }
    }
    
    func bind(value: T) -> Command {
        return Command {
            self.action(value)
        }
    }
}
