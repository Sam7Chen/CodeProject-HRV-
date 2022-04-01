//
//  ViewController.swift
//  ReadHeartRate
//
//  Created by Sam Chen on 2022/1/7.
//

import UIKit
import HealthKit
import Charts

class ViewController: UIViewController {
    
    lazy var lineChartView: LineChartView = {
        let chartView = LineChartView()
        chartView.delegate = self
        
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelRotationAngle = 90
        chartView.xAxis.valueFormatter = DateValueFormatter()
        
        // 外觀
        
        chartView.backgroundColor = .systemGray3
        
        return chartView
    }()
    
    
    
    let health = HKHealthStore()
    
    func getPredicate() -> NSPredicate? {
        let startDate = Date().addingTimeInterval(-72*60*60)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: [])
        return predicate
    }
    
    func dataTypesToShare() -> Set<HKSampleType>?{
        var set = Set<HKSampleType>()
        set.insert(HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!)
        return set
    }
     
    func dataTypesToRead() -> Set<HKObjectType>?{
        var set = Set<HKObjectType>()
        set.insert(HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!)
        return set
    }

    
    
    func getHeartRate(completion: @escaping (_ results :[HKSample]?) -> Void){
        let type = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(
            sampleType: type!,
            predicate: getPredicate(),
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sort])
        { (query, results, error) in
            if error == nil{
                completion(results)
            }
        }
        health.execute(query)
     
    }


    func setData() {
        let set = LineChartDataSet(entries: entries)
        let data = LineChartData(dataSet: set)
        lineChartView.data = data
    }
    
   

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubview(lineChartView)
        lineChartView.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = lineChartView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let verticalConstraint = lineChartView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        let widthConstraint = lineChartView.widthAnchor.constraint(equalTo: view.widthAnchor)
        let heightConstraint = lineChartView.heightAnchor.constraint(equalTo: view.widthAnchor)
        NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
        
        setData()
        
        
        
        if HKHealthStore.isHealthDataAvailable(){
            let shareType = self.dataTypesToShare()
            let readType = self.dataTypesToRead()
            
            health.requestAuthorization(toShare: shareType, read: readType, completion: { (success, error) in
                if success{
                    
                    
                    self.getHeartRate(completion :{ (results) in
                      if let results = results {
                          let unit = HKUnit.second()
                          var hrvDataArray = [Double]()
                          var hrvDataDict : [Date:Double] = [:]
                            var value : Double
                            var startDateTime : Date
                            for p in results as! [HKQuantitySample]{
                                value = p.quantity.doubleValue(for: unit)
                                startDateTime = p.startDate
                                hrvDataArray.append(value)
                                // Dict
                                hrvDataDict [startDateTime] = value
                               
                                //print("時間為: \(startDateTime) ")
                                
                            }
                         // for result1 in hrvDataArray{
                         //     print("心率變異為: \(result1*1000) 秒")
                        //    }
                          
                          for items in hrvDataDict{
                              print ("日期時間：\(items.key)，HRV 為 \(items.value*1000)秒")
                          }
                          
                          
                          }
                    })
                    
                    
                    
                } else{
                    print("授權失敗")
                }
                
            })
            
        }
    }
    
   

}



extension ViewController: ChartViewDelegate {
    
}

let entries: [ChartDataEntry] = [
    ChartDataEntry(x: dummyDates[0].timeIntervalSince1970, y: 10),
    ChartDataEntry(x: dummyDates[1].timeIntervalSince1970, y: 11),
    ChartDataEntry(x: dummyDates[2].timeIntervalSince1970, y: 12),
    ChartDataEntry(x: dummyDates[3].timeIntervalSince1970, y: 13),
    ChartDataEntry(x: dummyDates[4].timeIntervalSince1970, y: 14),
    ChartDataEntry(x: dummyDates[5].timeIntervalSince1970, y: 15),
]

let dummyDates: [Date] = [
    Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
    Calendar.current.date(byAdding: .day, value: -4, to: Date())!,
    Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
    Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
    Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
    Calendar.current.date(byAdding: .day, value: 0, to: Date())!,
]
