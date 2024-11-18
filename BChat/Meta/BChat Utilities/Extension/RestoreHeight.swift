// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import Foundation



class RestoreHeight {
    static let DIFFICULTY_TARGET = 30 // seconds
    
    static var instance: RestoreHeight? = nil
    
    static func getInstance() -> RestoreHeight {
        if instance == nil {
            instance = RestoreHeight()
        }
        return instance!
    }
    
    private var blockheight: [String: Int64] = [:]
    
    private init() {
        blockheight["2019-03-01"] = 21164
        blockheight["2019-04-01"] = 42675
        blockheight["2019-05-01"] = 64918
        blockheight["2019-06-01"] = 348926
        blockheight["2019-07-01"] = 108687
        blockheight["2019-08-01"] = 130935
        blockheight["2019-09-01"] = 152452
        blockheight["2019-10-01"] = 174680
        blockheight["2019-11-01"] = 196906
        blockheight["2019-12-01"] = 217017
        blockheight["2020-01-01"] = 239353
        blockheight["2020-02-01"] = 260946
        blockheight["2020-03-01"] = 283214
        blockheight["2020-04-01"] = 304758
        blockheight["2020-05-01"] = 326679
        blockheight["2020-06-01"] = 348926
        blockheight["2020-07-01"] = 370533
        blockheight["2020-08-01"] = 392807
        blockheight["2020-09-01"] = 414270
        blockheight["2020-10-01"] = 436562
        blockheight["2020-11-01"] = 458817
        blockheight["2020-12-01"] = 479654
        blockheight["2021-01-01"] = 501870
        blockheight["2021-02-01"] = 523356
        blockheight["2021-03-01"] = 545569
        blockheight["2021-04-01"] = 567123
        blockheight["2021-05-01"] = 589402
        blockheight["2021-06-01"] = 611687
        blockheight["2021-07-01"] = 633161
        blockheight["2021-08-01"] = 655438
        blockheight["2021-09-01"] = 677038
        blockheight["2021-10-01"] = 699358
        blockheight["2021-11-01"] = 721678
        blockheight["2021-12-01"] = 741838
        blockheight["2022-01-01"] = 788501
        blockheight["2022-02-01"] = 877781
        blockheight["2022-03-01"] = 958421
        blockheight["2022-04-01"] = 1006790
        blockheight["2022-05-01"] = 1093190
        blockheight["2022-06-01"] = 1199750
        blockheight["2022-07-01"] = 1291910
        blockheight["2022-08-01"] = 1361030
        blockheight["2022-09-01"] = 1456070
        blockheight["2022-10-01"] = 1574150
        blockheight["2022-11-01"] = 1674950
        blockheight["2022-12-01"] = 1764230
        blockheight["2023-01-01"] = 1850630
        blockheight["2023-02-01"] = 1942950
        blockheight["2023-03-01"] = 2022950
        blockheight["2023-04-01"] = 2112950
        blockheight["2023-05-01"] = 2199950
        blockheight["2023-06-01"] = 2289269
        blockheight["2023-07-01"] = 2363143
        blockheight["2023-08-01"] = 2420443
        blockheight["2023-09-01"] = 2503900
        blockheight["2023-10-01"] = 2585550
        blockheight["2023-11-01"] = 2696980
        blockheight["2023-12-01"] = 2816300
        blockheight["2024-01-01"] = 2894560
        blockheight["2024-02-01"] = 2986700
        blockheight["2024-03-01"] = 3049909
    }
    
    func getHeight(_ date: String) -> Int64 {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.isLenient = false
        
        guard let dateObj = dateFormatter.date(from: date) else {
            fatalError("Invalid date format or date string: \(date)")
        }
        
        return getHeightFromDate(dateObj)
    }
    
    func getHeightFromDate(_ date: Date) -> Int64 {
        print("getHeight in offline data value \(date)")
        var cal = Calendar.current
        cal.timeZone = TimeZone(identifier: "UTC")!
        var components = cal.dateComponents([.year, .month, .day], from: date)
        components.day! -= 4 // give it some leeway
        
        if cal.component(.year, from: date) < 2019 ||
            (cal.component(.year, from: date) == 2019 && cal.component(.month, from: date) <= 2) {
            // before March 2019
            return 0
        }
                
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        
        let queryDate = formatter.string(from: date)
        
        components.day = 1
        let prevTime = cal.date(from: components)!.timeIntervalSince1970
        let prevDate = formatter.string(from: cal.date(from: components)!)
        
        var arrayDate = prevDate
        
        // Lookup blockheight at the first of the month
        var prevBc = blockheight[prevDate]
        print("Value of restoreHeight in offline prevDate value \(String(describing: prevBc))")
        
        if prevBc == nil {
            // If too recent, go back in time and find the latest one we have
            while prevBc == nil {
                components.month! -= 1
                guard let modifiedDate = cal.date(from: components) else {
                    fatalError("Failed to calculate modified date.")
                }
                
                if cal.component(.year, from: modifiedDate) < 2019 {
                    fatalError("Endless loop looking for blockheight")
                }
                
                let prevDateModified = formatter.string(from: modifiedDate)
                arrayDate = prevDateModified
                
                prevBc = blockheight[prevDateModified]
            }
        }
        
        var height = prevBc!
        
        // Now we have a blockheight & a date ON or BEFORE the restore date requested
        if queryDate == prevDate {
            return Int64(height)
        }
        
        // See if we have a blockheight after this date
        components.month! += 1
        let nextTime = cal.date(from: components)!.timeIntervalSince1970
        let nextDate = formatter.string(from: cal.date(from: components)!)
        
        let nextBc = blockheight[nextDate]
        print("Value of restoreHeight in offline nextBc value \(String(describing: nextBc))")
        
        if let nextBc = nextBc { // We have a range - interpolate the blockheight we are looking for
            let diff = nextBc - height
            let diffDays = nextTime - prevTime
            let days = date.timeIntervalSince1970 - prevTime
            
            height = Int64(Double(height) + Double(diff) * (days / diffDays))
        } else {
            let currentDate = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let previousDateFormated : Date? = dateFormatter.date(from: arrayDate)
            let difference = currentDate.timeIntervalSince(previousDateFormated!)
            let differenceInDays = Int(difference/(60 * 60 * 24 ))
            let finalDiffDays = differenceInDays - 4
            height = Int64(Double(height) + Double(finalDiffDays) * (24.0 * 60 * 60 / Double(RestoreHeight.DIFFICULTY_TARGET)))
        }
        
        return height
    }
}
