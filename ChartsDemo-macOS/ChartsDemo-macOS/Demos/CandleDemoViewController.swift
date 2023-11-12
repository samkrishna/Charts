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
        super.viewDidLoad()
        
        do {
            let path = "/Users/achilles/Documents/SingularityOne/Databases/timebars.sqlite"
            let db = try Connection(path, readonly: true)
            
            let statement = "select * from time_bars where (currency_pair = \"EURAUD\" and close_date > 1699221600 and close_date <= 1699653600 and time_size_key = \"1h\");"
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd HH:mm:ss ZZ"

            let openIdx = 4
            let highIdx = 5
            let lowIdx = 6
            let closeIdx = 7
            var bars = Array<CandleChartDataEntry>()

            for row in try db.prepare(statement) {
                let open = row[openIdx] as! Double
                let high = row[highIdx] as! Double
                let low = row[lowIdx] as! Double
                let close = row[closeIdx] as! Double

                let bar = CandleChartDataEntry(x: 1.0, shadowH: high, shadowL: low, open: open, close: close)
                bars.append(bar)
            }

            assert(bars.count == 120)
        } catch {
            print (error)
        }
    }
}
