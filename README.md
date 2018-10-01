# data-driven-vc
Data-Driven-ViewController examples

## This repository contains examples of data driven view controllers.
The main idea of data driven view controller is to separate view controller from any dependencies and provide only `needed` data to represent any possible view controller state.

1. `Table.playground` - **Simple table view**\
Shows how to organize view controller with table view with data and react on cell selection.
<br>

2. `Picker.playground` - **Extendable picker view**\
Shows how to organize view controller with multicomponent picker view and react on row selection.
Also that example contains internal state, so controller doesn't need to relate on previous data to represent actual state.
<br>

3. `Animation.playground` - **Animation during data updates**\
Shows how to organize view controller with animation and provide smooth experience to user while controller stays constantly updating.
<br>

4. `Enum.playground` - **Multi-state screen**\
Shows how to organize view controller that can represent multiple states - loading/error(description, reload button)/success(show data).
<br>

5. `Validation.playground` - **View output example**\
Shows how to organize view output.
<br>

6. `PlainMVVM.playground` - **`MVVM` example**\
Shows plain view and view-model communication organization in `MVVM`
<br>

7. `DataDrivenMVVM.playground` - **how to implement DDVC in `MVVM`**\
Shows how to integrate data driven view controllers into `MVVM`
<br>

8. `PlainVIPER.playground` - **`VIPER` example**\
Shows plain view/presenter/data display manager communication organization in `VIPER`
<br>

9. `DataDrivenVIPERv1.playground` - **how to implement DDVC in imperative `VIPER`**\
Shows how to integrate data driven view controllers into `VIPER` using imperative approach, so presenter has viewOutput reference
<br>

10. `DataDrivenVIPERv2.playground` - **how to implement DDVC in `VIPER` using observer pattern**\
Shows how to integrate data driven view controllers into `VIPER`, so presenter has only viewModel property, and view controller observes it
<br>

11. `PlainMVC.playground` - **`MVC` example**\
Shows plain view-controller-model communication organization in `MVC`
<br>

12. `DataDrivenMVC.playground` - **how to implement in `MVC`**\
Shows how to integrate data driven view controllers into `MVC`
<br>