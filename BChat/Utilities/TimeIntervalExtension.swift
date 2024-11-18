// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import Foundation

extension TimeInterval {
    func stringFromTimeInterval() -> String {

        let time = NSInteger(self)

        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)

        return String(format: "%0.2d:%0.2d:%0.2d",hours, minutes, seconds)
    }
}
