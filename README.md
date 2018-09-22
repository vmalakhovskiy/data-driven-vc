# data-driven-vc
Data-Driven-ViewController examples

# This repository contains examples of data driven view controllers.
The main idea of data driven view controller is to separate view controller from any dependencies and provide only `needed` data to represent any possible view controller state.

- [x] **Simple table view** - `Table.playground`\
Shows how to organize view controller with table view with data and react on cell selection.
<br>

- [x] **Extendable picker view** - `Picker.playground`\
Shows how to organize view controller with multicomponent picker view and react on row selection.
Also that example contains internal state, so controller doesn't need to relate on previous data to represent actual state.
//TODO: Fix `view will appear`
<br>

- [x] **Animation during data updates** - `Animation.playground`\
Shows how to organize view controller with animation and provide smooth experience to user while controller stays constantly updating.
<br>

- [x] **Multistate screen** - `Enum.playground`\
Shows how to organize view controller that can represent multiple states - loading/error(desription, reload button)/success(show data).\
//TODO: move state-dependent subviews into separate files
<br>

- [x] **High-loaded screen - smooth scroll** - `HighLoad.playground` WIP\
Shows how to organize view controller that stays highly responcive during frequent data updates.
<br>

- [ ] **comparison with `MVVM`**\
Shows view presenter communication organization differences between `MVVM` and data driven view controller (REDUX like)
<br>

- [ ] **comparison `VIPER`**\
Shows view presenter communication organization differences between `VIPER` and data driven view controller (REDUX like)
<br>

- [ ] **comparison `MVC`**\
Shows view presenter communication organization differences between `MVC` and data driven view controller (REDUX like)
<br>

- [ ] **how to implement in `VIPER`**\
Shows how to integrate data driven view controllers into `VIPER`
<br>

- [ ] **how to implement in `MVVM`**\
Shows how to integrate data driven view controllers into `MVC`\
<br>
- [ ] **how to implement in `MVC`**\
Shows how to integrate data driven view controllers into `MVC`
<br>

- [ ] **lenses/prisms**\
Shows how lenses and prisms can decrease boilerplate code, and increase understanding of production/test code
<br>

- [ ] **data driven view controller tests**\
Shows behaviour driven tests (Quick/Nimble/SwiftyMock/Sourcery) example for table view controller
<br>

- [ ] **presenter tests**\
Shows behaviour driven tests (Quick/Nimble/SwiftyMock/Sourcery) example for presenter/view-model that datasources view controller
<br>

- [ ] **code generation**\
Shows how to automatically generate data driven view controller tests\
