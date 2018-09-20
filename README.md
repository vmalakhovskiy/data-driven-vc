# data-driven-vc
Data-Driven-ViewController examples for Cocoaheads#14 event

# This repository contains examples of data driven view controllers.

The main idea of data driven view controller is to separate view controller from any dependencies and provide only `needed` data to represent any possible view controller state.

- 1 `Table`
Shows how to organize view controller with table view with data and react on cell selection.

- 2 `Picker`
Shows how to organize view controller with multicomponent picker view and react on row selection.
Also that example contains internal state, so controller doesn't need to relate on previous data to represent actual state.

- 3 `Animation`
Shows how to organize view controller with animation and provide smooth animation experience to user while view controller stays constantly updating.

- 4 `High load` WIP
Shows how to organize view controller to manage frequent data updates.

Plans for the future
- [ ] comparison with mvvm
- [ ] comparison viper
- [ ] comparison mvc
- [ ] how to implement in VIPER
- [ ] how to implement in MVC
- [ ] how to implement in MVVM
- [ ] code generation
- [ ] view/presentation tests
- [ ] view/presenter tests
- [ ] lenses/prisms
