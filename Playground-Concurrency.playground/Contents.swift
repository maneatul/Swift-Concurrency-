import UIKit

var greeting = "Hello, playground"

let thread1 = DispatchQueue(label: "thread1", attributes: .concurrent)
let thread2 = DispatchQueue(label: "thread2", attributes: .concurrent)

thread1.async {
    for i in 0...10 {
        print("thread1.async", i)
    }
}

thread1.async(flags: .barrier)  {
    for i in 21...30 {
        print("thread2.async", i)
    }
}
thread1.sync {
    for i in 11...20 {
        print("thread1.sync", i)
    }
}

