//
//  CandleDemoViewController.swift
//  ChartsDemo-macOS
//
//  Created by Sam Krishna on 11/2/23.
//  Copyright © 2023 dcg. All rights reserved.
//

import Foundation
import Cocoa
import DGCharts
import SQLite

open class CandleDemoViewController: NSViewController
{
    @IBOutlet var candleChartView: CandleStickChartView!

    override open func viewDidLoad() {
        do {
            let path = "/Users/achilles/Documents/SingularityOne/Databases/timebars.sqlite"
            let db = try Connection(path, readonly: true)
            
            let statement = "select * from time_bars where (currency_pair = \"EURAUD\" and close_date > 1699221600 and close_date <= 1699653600 and time_size_key = \"1h\");"
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd HH:mm:ss ZZ"

            let close_dateIdx = 2
            let openIdx = 4
            let highIdx = 5
            let lowIdx = 6
            let closeIdx = 7
            let askIdx = 8
            let bidIdx = 9

            for bar in try db.prepare(statement) {
                let moment = bar[2] as! Double
                let close_date = Date(timeIntervalSince1970: moment)
                let date_string = df.string(from: close_date)
                print("the close date: \(date_string)")
            }

        } catch {
            print (error)
        }
    }
}
