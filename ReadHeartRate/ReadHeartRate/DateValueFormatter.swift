//
//  DateValueFormatter.swift
//  ReadHeartRate
//
//  Created by Sam Chen on 2022/4/1.
//

import Foundation
import Charts

public class DateValueFormatter: DefaultAxisValueFormatter {
    private let dateFormatter = DateFormatter()
    
    override init() {
        super.init()
        dateFormatter.dateFormat = "dd MMM HH:mm"
    }
    
    public override func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}
