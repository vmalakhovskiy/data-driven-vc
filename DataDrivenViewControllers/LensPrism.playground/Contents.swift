import UIKit
import DataDrivenViewControllersUI

enum ViewModel: Equatable {
    case initial(() -> ())
    case loading
    case users([User])
    case error(Error)
    
    struct User: Equatable {
        let name: String
        let age: String
        let action: () -> ()
    }
    
    struct Error: Equatable {
        let description: String
        let action: () -> ()
    }
}

infix operator |>: AdditionPrecedence
func |> <A, B, C> (f: @escaping (A) -> B, g: @escaping (B) -> C) -> (A) -> C {
    return { g(f($0)) }
}


extension ViewModel {
    enum prism {
        static let initial = Prism<ViewModel, () -> ()>(
            tryGet: { if case .initial(let value) = $0 { return value } else { return nil } },
            inject: { (x1) in .initial(x1) }
        )
        static let loading = Prism<ViewModel, ()>(
            tryGet: { if case .loading = $0 { return () } else { return nil } },
            inject: { .loading }
        )
        static let users = Prism<ViewModel, [User]>(
            tryGet: { if case .users(let value) = $0 { return value } else { return nil } },
            inject: { (x1) in .users(x1) }
        )
        static let error = Prism<ViewModel, Error>(
            tryGet: { if case .error(let value) = $0 { return value } else { return nil } },
            inject: { (x1) in .error(x1) }
        )
    }
}

extension ViewModel.Error {
    struct lens {
        static let description = Lens<ViewModel.Error, String>(
            get: { $0.description },
            set: { whole, part in ViewModel.Error(description: part, action: whole.action) }
        )
        static let action = Lens<ViewModel.Error, () -> ()>(
            get: { $0.action },
            set: { whole, part in ViewModel.Error(description: whole.description, action: part) }
        )
    }
}

extension ViewModel.User {
    struct lens {
        static let name = Lens<ViewModel.User, String>(
            get: { $0.name },
            set: { whole, part in ViewModel.User(name: part, age: whole.age, action: whole.action) }
        )
        static let age = Lens<ViewModel.User, String>(
            get: { $0.age },
            set: { whole, part in ViewModel.User(name: whole.name, age: part, action: whole.action) }
        )
        static let action = Lens<ViewModel.User, () -> ()>(
            get: { $0.action },
            set: { whole, part in ViewModel.User(name: whole.name, age: whole.age, action: part) }
        )
    }
}

let a = ViewModel.initial({})

//before
if case .initial(let action) = a {
    action()
}

//after
ViewModel.prism.initial.tryGet(a)?.()

let b = ViewModel.error(ViewModel.Error(description: "some description", action: {}))


//before
var d = 
if case .error(let data) = b {
    
}
