//
//  HRVManager.swift
//  HRVApp
//
//  Created by Sam Chen on 2022/4/5.
//

import Foundation
import HealthKit

enum DisplayType {
    case monthly
    case weekly
    case daily
}

protocol HRVManagerDelegate: NSObjectProtocol {
    func dataComplate(_ data: [(date: Date, value: Double)])
}

class HRVManager: NSObject {
    var delegate: HRVManagerDelegate? = nil

    let health = HKHealthStore()
    var data: [(date: Date, value: Double)] = []
    var newdata: [(date: Date, average: Int)] = []
    private var displayType: DisplayType!
    
    override init() {
        super.init()
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }
        
        let shareType = dataTypesToShare()
        let readType = dataTypesToRead()
        Task {
            try? await health.requestAuthorization(toShare: shareType! , read: readType! )
        }
        
    }
    
    private func dataTypesToShare() -> Set<HKSampleType>?{
        var set = Set<HKSampleType>()
        set.insert(HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!)
        return set
    }
     
    private func dataTypesToRead() -> Set<HKObjectType>?{
        var set = Set<HKObjectType>()
        set.insert(HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!)
        return set
    }
    
    private func getPredicateForMonth() -> NSPredicate? {
        let startDate = Date().addingTimeInterval(-24 * 60 * 60 * 30)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: [])
        return predicate
    }
    
    private func getPredicateForWeek() -> NSPredicate? {
        let startDate = Date().addingTimeInterval(-24 * 60 * 60 * 7)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: [])
        return predicate
    }

    private func getPredicateForDay() -> NSPredicate? {
        let startDate = Date().addingTimeInterval(-24 * 60 * 60 * 1)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: [])
        return predicate
    }

    
    func getHRV(displayType: DisplayType) {
        let type = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        self.displayType = displayType
        
        var predicate: NSPredicate
        switch displayType {
        case .monthly:
            predicate = getPredicateForMonth()!
            
        case .weekly:
            predicate = getPredicateForWeek()!
            
        case .daily:
            predicate = getPredicateForDay()!
        }
        
        let query = HKSampleQuery(
            sampleType: type!,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sort])
        { (query, results, error) in
            guard error == nil else {
                return
            }
            
            let unit = HKUnit.second()
            self.data = []
            for p in results as! [HKQuantitySample]{
                let value = p.quantity.doubleValue(for: unit)
                self.data.append((date: p.startDate + 8 * 60 * 60, value: value * 1000))
//                print("\(p.startDate.description): SDNN為 ：\(value)")
            }
            
            self.newDataInit()
            self.delegate?.dataComplate(self.data)
        }

        health.execute(query)
    }
    
    func newDataInit() {
        let component = Calendar.current.dateComponents([.year, .month, .day], from: Date.now + 8 * 60 * 60)
        var count = 0
        
        switch displayType {
        case .monthly:
            count = 30
            
        case .weekly:
            count = 7
            
        case .daily:
            count = 1
            
        default:
            count = 0
        }
        
        var tmp: [(date: Date, value: Set<Double>)] = []
        for i in 0..<count {
            let date = DateComponents(
                calendar: Calendar.current,
                year: component.year,
                month: component.month,
                day: component.day
            ).date! - Double(24 * 60 * 60 * i)
            let set: Set<Double> = [0]
            tmp.append((date, set))
        }
        
        data.forEach { body in
            let component = Calendar.current.dateComponents([.year, .month, .day], from: body.date + 8 * 60 * 60)
            let date = DateComponents(
                calendar: Calendar.current,
                year: component.year,
                month: component.month,
                day: component.day
            ).date!
            
            let index = tmp.firstIndex { body in
                body.date == date
            }

            tmp[index!].value = []
            tmp[index!].value.insert(body.value)
        }
        
        newdata = []
        tmp.forEach { body in
            let average = body.value.reduce(0, +) / Double(body.value.count)
            newdata.append((date: body.date, average: Int(round(average))))
        }
        
        // for debug
        newdata.forEach { body in
            print("\(body.date.description): \(body.average)")
        }
    }
    
}
