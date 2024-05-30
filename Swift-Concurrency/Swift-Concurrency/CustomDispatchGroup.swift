//
//  CustomDispatchGroup.swift
//  Swift-Concurrency
//
//  Created by Atul Mane on 30/05/24.
//

import Foundation

protocol TaskRegistrationManageable {
    
    var pendingTaskCount: Int { get }
    func enter()
    func leave(completionHandler: @escaping () -> Void)
}

protocol CompletionHandleable {
    func notify(queue: DispatchQueue, execute: @escaping () -> Void)
    func handleCompletion()
}

protocol WaitTimeManageable {
    func wait(for taskRegistration: TaskRegistrationManageable)
    func wait(timeout: DispatchTime, for taskRegistration: TaskRegistrationManageable) -> DispatchTimeoutResult
}


class TaskRegistrationManager: TaskRegistrationManageable {
    
    var pendingTaskCount: Int = 0
    
    func enter() {
        pendingTaskCount += 1
    }
    
    func leave(completionHandler: @escaping () -> Void) {
        pendingTaskCount -= 1
        
        if pendingTaskCount == 0 {
            completionHandler()
        }
    }
}

class CompletionHandlerManager: CompletionHandleable {
    
    private var completionHandler: () -> Void = {}
    
    func notify(queue: DispatchQueue, execute: @escaping () -> Void) {
        completionHandler = execute
    }
    
    func handleCompletion() {
        completionHandler()
    }
}

class WaitTimeManager: WaitTimeManageable {
    
    func wait(for taskRegistration: any TaskRegistrationManageable) {
        
        while taskRegistration.pendingTaskCount > 0 {
            Thread.sleep(forTimeInterval: 0.1)
        }
    }
    
    func wait(timeout: DispatchTime, for taskRegistration: any TaskRegistrationManageable) -> DispatchTimeoutResult {
        
        var result: DispatchTimeoutResult = .success
        
        let semaphore = DispatchSemaphore(value: 0)
        
        while taskRegistration.pendingTaskCount > 0 {
            let remainingTime = timeout.uptimeNanoseconds - DispatchTime.now().uptimeNanoseconds
            
            if remainingTime <= 0 {
                result = .timedOut
                break
            }
            
            let waitTime = DispatchTime.now() + DispatchTimeInterval.nanoseconds(Int(remainingTime))
            
            DispatchQueue.global().async {
                if taskRegistration.pendingTaskCount == 0 {
                    semaphore.signal()
                }
            }
            
            let waitResult = semaphore.wait(timeout: waitTime)
            if waitResult == .timedOut {
                result = .timedOut
                break
            }
        }
        
       return result
    }
    
}


class CustomDispatchGroup {
    
    private let taskRegistrationManager: TaskRegistrationManageable
    private let completionHandler: CompletionHandleable
    private let waitManager: WaitTimeManageable
    
    init(taskRegistrationManager: TaskRegistrationManageable, completionHandler: CompletionHandleable, waitManager: WaitTimeManageable) {
        self.taskRegistrationManager = taskRegistrationManager
        self.completionHandler = completionHandler
        self.waitManager = waitManager
    }
    
    convenience init() {
        self.init(taskRegistrationManager: TaskRegistrationManager(),
                  completionHandler: CompletionHandlerManager(),
                  waitManager: WaitTimeManager())
    }
    
    func enter() {
        taskRegistrationManager.enter()
    }
    
    func leave() {
        taskRegistrationManager.leave(completionHandler: completionHandler.handleCompletion)
    }
    
    func notify(queue: DispatchQueue, execute: @escaping () -> Void) {
        completionHandler.notify(queue: queue, execute: execute)
    }
    
    func wait() {
        waitManager.wait(for: taskRegistrationManager)
    }
    
    func wait(timeout: DispatchTime) -> DispatchTimeoutResult {
        waitManager.wait(timeout: timeout, for: taskRegistrationManager)
    }
}
