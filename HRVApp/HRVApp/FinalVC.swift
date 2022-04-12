//
//  FinalVC.swift
//  HRVApp
//
//  Created by Sam Chen on 2022/4/11.
//

import UIKit

class FinalVC: UIViewController {
    private let lineWidth = 5.0
    let hm = HRVManager.current
    
    @IBOutlet weak var stackView: UIStackView!

    lazy var data = hm.newdata
    
    /*
    let data: [(date: Date, average: Int)] = [
        (Date.now - 24*60*60*7 , 50),
        (Date.now - 24*60*60*6 , 60),
        (Date.now - 24*60*60*5 , 70),
        (Date.now - 24*60*60*4 , 80),
        (Date.now - 24*60*60*3 , 0),
        (Date.now - 24*60*60*2 , 150),
        (Date.now - 24*60*60*1 , 70),
        (Date.now - 24*60*60*0 , 100)
    ]
    */

    override func viewDidLoad() {
        super.viewDidLoad()

        drawLineChart()
    }
    
    @IBAction func exitButtonClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func drawLineChart() {
        let stackViewHeight = stackView.frame.height
        
        let width = stackView.frame.width / CGFloat(data.count)
        let maxValue = 150.0
        let path = UIBezierPath()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMdd"

        for (index, el ) in data.enumerated() {
            let x = width * CGFloat(index) + width / 2.0
            var y = Double(el.average) / maxValue * stackViewHeight

            if el.average == 150 {
                y = (Double(el.average) - lineWidth) / maxValue * stackViewHeight
            }
            if el.average == 0 {
                y = (Double(el.average) + lineWidth) / maxValue * stackViewHeight
            }
            
            if index == 0 {
                path.move(to: CGPoint(x: x, y: stackViewHeight - y))
            } else {
                path.addLine(to: CGPoint(x: x, y: stackViewHeight - y))
            }
            
            let myview = UIView()
            stackView.addArrangedSubview(myview)
            
            // 設定x軸標籤
            let label = UILabel()
            label.text = formatter.string(from: el.date)
            label.font = UIFont.systemFont(ofSize: 12)
            label.sizeToFit()
            myview.addSubview(label)
            
            label.translatesAutoresizingMaskIntoConstraints = false
            label.topAnchor.constraint(equalTo: myview.bottomAnchor).isActive = true
        }
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.systemIndigo.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = lineWidth
        
        shapeLayer.path = path.cgPath
        stackView.layer.addSublayer(shapeLayer)
        

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
