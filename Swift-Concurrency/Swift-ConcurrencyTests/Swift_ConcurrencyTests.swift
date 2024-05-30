//
//  Swift_ConcurrencyTests.swift
//  Swift-ConcurrencyTests
//
//  Created by Atul Mane on 30/05/24.
//

import XCTest
@testable import Swift_Concurrency

final class Swift_ConcurrencyTests: XCTestCase {
    
    var customDispatchGroup: CustomDispatchGroup!

    override func setUpWithError() throws {
        customDispatchGroup = CustomDispatchGroup()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        customDispatchGroup = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testCustomDispatchGroup() {
        
        let expectation = self.expectation(description: "Task Should colplete.")
        
        for _ in 1...3 {
            DispatchQueue.global().async { [weak self] in
                guard let self else { return }
                
                customDispatchGroup.enter()
                
                Thread.sleep(forTimeInterval: Double.random(in: 1...3))
                
                customDispatchGroup.leave()
            }
        }
        
        customDispatchGroup.notify(queue: .main) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testWaitWithTimeout() {
        
        for _ in 1...3 {
            DispatchQueue.global().async { [weak self] in
                guard let self else { return }
                
                customDispatchGroup.enter()
                Thread.sleep(forTimeInterval: Double.random(in: 1...3))
                customDispatchGroup.leave()
            }
        }
        
        let result = customDispatchGroup.wait(timeout: .now() + 5)
        XCTAssertEqual(result, .success)
        
    }

}
