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

- [x] **`MVVM` example** - `PlainMVVM.playground`\
Shows plain view and view-model communication organization in `MVVM`
<br>

- [x] **`VIPER` example** - `PlainVIPER.playground`\
Shows plain view/presenter/data display manager communication organization in `VIPER`
<br>

- [x] **`MVC` example** - `PlainMVC.playground`\
Shows plain view-controller-model communication organization in `MVC`
<br>

- [x] **how to implement in imperative `VIPER`** - `DataDrivenVIPERv1.playground`\
Shows how to integrate data driven view controllers into `VIPER` using imperative approach, so presenter has viewOutput reference
<br>

- [x] **how to implement in `VIPER` user observer pattern** - `DataDrivenVIPERv2.playground`\
Shows how to integrate data driven view controllers into `VIPER`, so presenter has only viewModel property, and view controller observes it
<br>

- [x] **how to implement in `MVVM`** - `DataDrivenMVVM.playground`\
Shows how to integrate data driven view controllers into `MVC`
<br>

- [x] **how to implement in `MVC`** - `DataDrivenMVC.playground`\
Shows how to integrate data driven view controllers into `MVC`
<br>

- [x] **lenses/prisms** - `LensPrism.playground`\ WIP
Shows how lenses and prisms can decrease boilerplate code, and increase understanding of production/test code
<br>

- [x] **data driven view controller tests** - `DataDrivenViewControllerSpec.playground`\
Shows behaviour driven tests (Quick/Nimble/SwiftyMock/Sourcery) example for table view controller
<br>

- [x] **presenter tests** - `PresenterSpec.playground`\
Shows behaviour driven tests (Quick/Nimble/SwiftyMock/Sourcery) example for presenter/view-model that data-sources view controller
<br>