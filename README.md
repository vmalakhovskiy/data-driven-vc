# data-driven-vc
Data-Driven-ViewController examples

## This repository contains examples of data driven view controllers.
The main idea of data driven view controller is to separate view controller from any dependencies and provide only `needed` data to represent any possible view controller state.

- [x] **Simple table view** - `Table.playground`\
Shows how to organize view controller with table view with data and react on cell selection.
<br>

- [x] **Extendable picker view** - `Picker.playground`\
Shows how to organize view controller with multicomponent picker view and react on row selection.
Also that example contains internal state, so controller doesn't need to relate on previous data to represent actual state.
<br>

- [x] **Animation during data updates** - `Animation.playground`\
Shows how to organize view controller with animation and provide smooth experience to user while controller stays constantly updating.
<br>

- [x] **Multi-state screen** - `Enum.playground`\
Shows how to organize view controller that can represent multiple states - loading/error(description, reload button)/success(show data).
<br>

- [x] **High-loaded screen - smooth scroll** - `HighLoad.playground` WIP\
Shows how to organize view controller that stays highly responsive during frequent data updates.
<br>

- [x] **comparison with `MVVM`**\
Shows plain view and view-model communication organization in `MVVM`
<br>

- [ ] **comparison `VIPER`**\
Shows plain view and presenter communication organization in `VIPER`
<br>

- [ ] **comparison `MVC`**\
Shows plain view-controller-model communication organization in `MVC`
<br>

- [ ] **how to implement in `VIPER`**\
Shows how to integrate data driven view controllers into `VIPER`
<br>

- [ ] **how to implement in `MVVM`**\
Shows how to integrate data driven view controllers into `MVC`
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
Shows behaviour driven tests (Quick/Nimble/SwiftyMock/Sourcery) example for presenter/view-model that data-sources view controller
<br>

- [ ] **code generation**\
Shows how to automatically generate data driven view controller tests