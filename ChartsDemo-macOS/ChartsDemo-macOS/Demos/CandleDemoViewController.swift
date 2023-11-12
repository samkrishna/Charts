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

let ITEM_COUNT  = 20

open class CandleDemoViewController: NSViewController
{
    @IBOutlet var candleChartView: CandleStickChartView!

    func randomFloatBetween(from: Float, to: Float)->Float
    {
        return Float(arc4random_uniform( UInt32(to - from ))) + Float(from)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        // x-axis
        let xAxis                           = candleChartView.xAxis
        xAxis.labelPosition                 = .bothSided
        xAxis.axisMinimum                   = 0.0
        xAxis.granularity                   = 1.0

        // left axis
        let leftAxis                        = candleChartView.leftAxis
        leftAxis.drawGridLinesEnabled       = true
        leftAxis.axisMinimum                = 0.0

        // right axis
        let rightAxis                       = candleChartView.rightAxis
        rightAxis.drawGridLinesEnabled      = true
        rightAxis.axisMinimum               = 0.0

        // legend
        let legend                          = candleChartView.legend
        legend.wordWrapEnabled              = true
        legend.horizontalAlignment          = .center
        legend.verticalAlignment            = .bottom
        legend.orientation                  = .horizontal
        legend.drawInside                   = false

        candleChartView.chartDescription.enabled = false

        let set = loadDataSet()
        let data = CandleChartData(dataSets: [set])
        candleChartView.data = data
    }

    override open func viewWillAppear()
    {
        self.candleChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
    }

    open func loadDataEntries() -> [CandleChartDataEntry] {
        var entries = [CandleChartDataEntry]()

        for i in 0..<ITEM_COUNT
        {
            let mult: Float = 50
            let val = randomFloatBetween(from: mult, to: mult + 40)
            let high = randomFloatBetween(from: 8, to: 17)
            let low: Float = randomFloatBetween(from: 8, to: 17)
            let open: Float = randomFloatBetween(from: 1, to: 7)
            let close: Float = randomFloatBetween(from: 1, to: 7)
            let even: Bool = i % 2 == 0

            entries.append(CandleChartDataEntry(x: Double(i), shadowH: Double(val + high), shadowL: Double(val - low), open: Double(even ? val + open : val - open), close: Double(even ? val - close : val + close)))
        }

        return entries
    }

    open func loadDataSet() -> CandleChartDataSet {
        let entries = loadDataEntries()
        let set = CandleChartDataSet(entries: entries, label: "Candle DataSet")

        set.increasingColor = NSUIColor.green
        set.increasingFilled = true

        set.decreasingColor = NSUIColor.red
        set.decreasingFilled = true

        set.shadowColor = NSUIColor.white
        set.valueFont = NSUIFont.systemFont(ofSize: CGFloat(10.0))
        set.drawValuesEnabled = true
        set.shadowWidth = 0.7
        return set
    }

    open func loadData() {
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
            var bars = [CandleChartDataEntry]()

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
