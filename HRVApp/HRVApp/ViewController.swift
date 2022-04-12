//
//  ViewController.swift
//  HRVApp
//
//  Created by Sam Chen on 2022/4/5.
//

import UIKit

class ViewController: UIViewController, HRVManagerDelegate , UITableViewDataSource, UITableViewDelegate {
    let hm = HRVManager.current

    @IBOutlet weak var tableView: UITableView!
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hm.newdata.count
     
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
//        var config = cell.defaultContentConfiguration()
        let data = hm.newdata[indexPath.row]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
//        config.text = formatter.string(from: data.date)
//        config.secondaryText = String(data.average)
//        cell.contentConfiguration = config
        
        (cell.viewWithTag(10) as! UILabel).text = formatter.string(from: data.date)
        (cell.viewWithTag(20) as! UILabel).text = String(data.average)

        return cell
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        hm.delegate = self
        
//        let path = UIBezierPath()
//        path.move(to: CGPoint(x: 50, y: 800))
//        // 數據帶入
//        path.addLine(to: CGPoint(x: 70, y: 700))
//        path.addLine(to: CGPoint(x: 200, y: 600))
//
//        let shapeLayer = CAShapeLayer()
//        shapeLayer.strokeColor = UIColor.blue.cgColor
//        shapeLayer.fillColor = UIColor.clear.cgColor
//        shapeLayer.lineWidth = 3
//
//        shapeLayer.path = path.cgPath
//        view.layer.addSublayer(shapeLayer)
        
    }

    @IBAction func segValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            hm.getHRV(displayType: .monthly)
        }
        
        else if sender.selectedSegmentIndex == 1 {
            hm.getHRV(displayType: .weekly)
        }
        
        else if sender.selectedSegmentIndex == 2 {
            hm.getHRV(displayType: .daily)
        }
    }
    
    func dataComplate(_ data: [(date: Date, value: Double)]) {
//        data.forEach{ body in
//            let component = Calendar.current.dateComponents(
//                [.year, .month, .day],
//                from: body.date
//            )
//
//            print("\(component.year!)年\(component.month!)月\(component.day!)日: \(body.value)")
//        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
        
}

