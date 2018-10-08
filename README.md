# Data Driven ViewController examples

## This repository contains examples of data driven view controllers.
The main idea of data driven view controller is to separate view controller from any dependencies and provide only `needed` data to represent any possible view controller state.

## There is also a presentation slides, that contains more teoretical info about data driven view controllers. [Link](https://speakerdeck.com/vmalakhovskiy/data-driven-view-controllers)

<img src="https://github.com/vmalakhovskiy/data-driven-vc/blob/master/Resources/1.png" width="256" height="144"> <img src="https://github.com/vmalakhovskiy/data-driven-vc/blob/master/Resources/11.png" width="256" height="144"> <img src="https://github.com/vmalakhovskiy/data-driven-vc/blob/master/Resources/22.png" width="256" height="144">


## Important note:
Project contain 3-rd party dependencies, installed through cocoapods, so to make playgrounds work - please build `DataDrivenViewControllersUI` target.

1. `Simple Input.playground` \
Shows example of how to organize view with 3 buttons, where you can select profession you like.
Also it provides you basic example of view output via optional closures, that also gives a context if action is available.
<br>

![Simple Input.playground](https://github.com/vmalakhovskiy/data-driven-vc/blob/master/Resources/1.gif)

2. `Input + Validation.playground` \
Shows example with 2 text fields and validation, without any reactive magic.
Password field with length validation, and confirm password field that checks equality with password field - also reacts with color change, if error occurs.
<br>

![Input + Validation.playground](https://github.com/vmalakhovskiy/data-driven-vc/blob/master/Resources/2.gif)

3. `Multi-state Screen.playground` \
Shows how to organize view controller that can represent multiple states - loading/error(description, reload button)/success(show data).
Also, that example contains table-view, that reacts on selection, without revealing index path, or any other view implementation detail outside.
<br>

![Multi-state Screen.playground](https://github.com/vmalakhovskiy/data-driven-vc/blob/master/Resources/3.gif)

4. `Animation.playground` \
Shows `breathing` ring.
View decides how to continue animation, based on previous data.
<br>

![Animation.playground](https://github.com/vmalakhovskiy/data-driven-vc/blob/master/Resources/4.gif)

The following examples has exactly the same appearance as example #3 (`Multi-state Screen.playground`).

5. `DataDrivenMVVM.playground` - **how to implement DDVC in `MVVM`**\
Shows how to integrate data driven view controllers into `MVVM`
<br>

6. `DataDrivenVIPERv1.playground` - **how to implement DDVC in imperative `VIPER`**\
Shows how to integrate data driven view controllers into `VIPER` using imperative approach, so presenter has viewOutput reference.
<br>

7. `DataDrivenVIPERv2.playground` - **how to implement DDVC in `VIPER` using observer pattern**\
Shows how to integrate data driven view controllers into `VIPER`, so presenter has only viewModel property, and view controller observes it.
<br>

8. `DataDrivenMVC.playground` - **how to implement in `MVC`**\
Shows how to integrate data driven view controllers into plain old `MVC`
<br>
