import XCTest

class SentryThreadsTests: XCTestCase {
    func testExample()  {

        let stacktrace =  SentryStacktraceBuilder.buildStacktraceForCurrentThread()
        
        let i = 10;
    }
}
