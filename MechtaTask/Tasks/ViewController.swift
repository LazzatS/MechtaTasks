//
//  ViewController.swift
//  MechtaTask
//
//  Created by Lazzat Seiilova on 10.03.2022.
//

import UIKit
import RxSwift
import Atomics

class ViewController: UIViewController {
    // task 1
    var viewModel = ViewModel()
    var rockets = [Rocket]()
    
    // task2
    private let disposeBag = DisposeBag()
    
    // task3 (below)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        task1()
//        task2()
//        task3()
    }
    
    private func task1() {
        print("\nTask 1\n")
        viewModel.fetchRockets { [weak self] response in
            switch response {
            case .success(let rocket):
                print("\(rocket.name) is in the \(rocket.country)")
            case .failure(let networkError):
                self?.viewModel.showMessage(for: networkError)
            }
        }
    }
    
    func task2() {
        print("\nTask 2\n")
        
        let arr = ["one", "two", "three"]
        let names: Observable<String> = Observable.from(arr)
        let chars: Observable<[String.Element]> = names.map { name in
            name.flatMap {
                String($0)
            }
        }
        
        chars.reduce([], accumulator: +)
            .asObservable()
            .subscribe { finalArray in
                print(finalArray.element ?? "Completed")
            }.disposed(by: disposeBag)
    }
    
    func task3() {
        print("\nTask 3\n")
        let qwerty = Batonic<Int>(10)
        qwerty.mutatingSet {
            print($0 * 5)
        }
    }
}


// Task 3

final class Batonic<T> {
    typealias intNumber = Int
    private let queue = DispatchQueue(label: "Serial queue")
    private var _value: T
    
    init(_ value: T) {
        self._value = value
    }
    
    var value: T {
        get {
            return queue.sync {
                self._value
            }
        }
        
    // MARK: - Why not?
        
        /*
        set {
            
            // так как это НЕ потокобезопасно. 1) Вначале мы получаем значение экземпляра атомарно, 2) затем оно атомарно присваивает новое значение. Но если другой поток присвоит значение в промежутке между чтением и записью, то мы получим неправильное значение. Лучше использовать отдельный метод, который будет изменять значение
            
            queue.sync {
                self._value = newValue
            }
        }
         */
    }
    
    // MARK: - Better solution
    
    // чтобы избегать ситуаций, когда мы одновременно читаем на одном потоке и изменяем на другом,
    // нам нужно предоставить синхронный доступ к переменной,
    // но не set-тить его в самой переменной экземпляра,
    // а создать метод с "&" и "inout" и тогда мы можем поменять значение переменной
    // через ее адресную ссылку
    
    func mutatingSet(_ transform: (inout T) -> Void) {
        queue.sync {
            transform(&self._value)
        }
    }
}
