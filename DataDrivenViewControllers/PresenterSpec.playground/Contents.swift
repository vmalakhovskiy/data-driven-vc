//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import DataDrivenViewControllersUI

enum ViewModel: Equatable {
    case initial(() -> ())
    case loading
    case users([User])
    case error(Error)
    
    static func == (lhs: ViewModel, rhs: ViewModel) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial):
            return true
        case (.loading, .loading):
            return true
        case (.users(let left), .users(let right)):
            return left == right
        case (.error(let left), .error(let right)):
            return left == right
        default:
            return false
        }
    }
    
    struct User: Equatable {
        let name: String
        let age: String
        let action: () -> ()
        
        static func == (lhs: ViewModel.User, rhs: ViewModel.User) -> Bool {
            return lhs.name == rhs.name && lhs.age == rhs.age
        }
    }
    
    struct Error: Equatable {
        let description: String
        let action: () -> ()
        
        static func == (lhs: ViewModel.Error, rhs: ViewModel.Error) -> Bool {
            return lhs.description == rhs.description
        }
    }
}

protocol ViewOutput {
    var viewModel: Observable<ViewModel> { get }
}

class Presenter: ViewOutput {
    private lazy var viewModelObserver = Observer<ViewModel>(
        value: .initial { [weak self] in self?.populateViewModelWithError() }
    )
    lazy var viewModel: Observable<ViewModel> = viewModelObserver
    
    func populateViewModelWithError() {
        viewModelObserver.update(with: .loading)
        DispatchQueue.main.async { [weak self] in
            self?.viewModelObserver.update(
                with: .error(
                    ViewModel.Error(
                        description: "very bad",
                        action: { self?.populateViewModelWithUsers() }
                    )
                )
            )
        }
    }
    
    func populateViewModelWithUsers() {
        viewModelObserver.update(with: .loading)
        DispatchQueue.main.async { [weak self] in
            self?.viewModelObserver.update(
                with: .users([
                    ViewModel.User(name: "vasya", age: "19.4", action: { print("performing some actions with vasya") }),
                    ViewModel.User(name: "petya", age: "19.4", action: { print("performing some actions with petya") }),
                    ViewModel.User(name: "kolya", age: "19.4", action: { print("performing some actions with kolya") }),
                    ViewModel.User(name: "anton", age: "19.4", action: { print("performing some actions with anton") })
                ])
            )
        }
    }
}

import Quick
import Nimble

class PresenterSpec: QuickSpec {
    override func spec() {
        describe("Presenter") {
            var sut: Presenter!
            
            beforeEach {
                sut = Presenter()
            }
            
            describe("when initialized") {
                it("should have view model in initial state") {
                    expect(sut.viewModel.value).to(equal(.initial {}))
                }
                
                context("and view model was initialized too") {
                    beforeEach {
                        if case .initial(let action) = sut.viewModel.value {
                            action()
                        }
                    }
                    
                    it("should have loading state") {
                        expect(sut.viewModel.value).to(equal(.loading))
                    }
                    
                    xit("should ask service for users") {
                    }
                    
                    context("and if users request fails") {
                        it("should have view model in error state") {
                            let expected = ViewModel.error(ViewModel.Error(description:"very bad", action:{}))
                            expect(sut.viewModel.value).toEventually(equal(expected))
                        }
                        
                        context("and performing error action") {
                            beforeEach {
                                /// don't want to implement real service
                                DispatchQueue.main.async {
                                    if case .error(let errorData) = sut.viewModel.value {
                                        errorData.action()
                                    }
                                }
                            }
                            
                            it("should have loading state") {
                                expect(sut.viewModel.value).to(equal(.loading))
                            }
                            
                            xit("should ask service for users") {
                            }
                            
                            context("and if users request succeeds") {
                                beforeEach {
                                    /// mock response
                                }
                                
                                it("should have view model in error state") {
                                    let expected = ViewModel.users([
                                        ViewModel.User(name: "vasya", age: "19.4", action: {}),
                                        ViewModel.User(name: "petya", age: "19.4", action: {}),
                                        ViewModel.User(name: "kolya", age: "19.4", action: {}),
                                        ViewModel.User(name: "anton", age: "19.4", action: {})
                                    ])
                                    expect(sut.viewModel.value).toEventually(equal(expected))
                                }
                            }
                            
                            xcontext("and if users request fails") {
                                it("should have view model in error state") {
                                }
                            }
                        }
                    }
                    
                    xcontext("and if users request succeeds") {
                        it("should have view model in loaded state") {
                        }
                    }
                }
            }
        }
    }
}

PresenterSpec.defaultTestSuite.run()
