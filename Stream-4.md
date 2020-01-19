#  Goals for this stream

- [x] Add possible type to action. If action has single value - it type can be written without wrapping entity.

`action Increment by value: Int` should be valid and finished definition.
For this to work together with `action Increment` I need to add more fields to `ActionDefinition` struct.

- [x] Add partially qualified reduces definition.

Currently `ReduceDefiinition` requires both `Action` and `State` to be declared.

```
reduce Counter with Increment { ... }
reduce Counter with Decrement { ... }
```

I want to have alternative style where multiple reducers can be written to single state: 
```
reduce Counter {
  with Increment {
    ...
  }
  
  with Decrement { 
    ...
  }
}
```

I need to make `ReduceDefinition` either fully qualified or partial.

Alternatively, I can go with single definition for state and array for actions by default. And parse single definition 
as an array with single action definition. 

- [ ] Run quiver on `counter.arrow` file and inspect AST

