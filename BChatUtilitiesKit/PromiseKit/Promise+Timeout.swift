// Copyright © 2022 Beldex International. All rights reserved.

import PromiseKit

public extension Promise {
    
    func timeout(seconds: TimeInterval, timeoutError: Error) -> Promise<T> {
        return Promise<T> { seal in
            after(seconds: seconds).done {
                seal.reject(timeoutError)
            }
            self.done { result in
                seal.fulfill(result)
            }.catch { err in
                seal.reject(err)
            }
        }
    }
}
