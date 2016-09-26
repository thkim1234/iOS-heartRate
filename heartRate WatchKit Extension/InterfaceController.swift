//
//  InterfaceController.swift
//  heartRtae WatchKit Extension
//
//  Created by Tae Hyun Kim on 9/24/16.
//  Copyright © 2016 Tae Hyun Kim. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit

class InterfaceController: WKInterfaceController {

    @IBOutlet weak var label: WKInterfaceLabel!
    @IBOutlet weak var start: WKInterfaceButton!
    let hRType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
    let hRUnit = HKUnit(from: "count/min")
    var hRQuery: HKQuery?
    let hStore = HKHealthStore()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        label.setText("Testing")
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    @IBAction func heartRateController(){
        guard hRQuery == nil
            else { return }
        
        if hRQuery == nil {
            hRQuery = self.createStreamingQuery()
            hStore.execute(self.hRQuery!)
            start.setTitle("Stop")
        }
        else {
            hStore.stop(self.hRQuery!)
            hRQuery = nil
            start.setTitle("Start")
        }
    }
    fileprivate func createStreamingQuery() -> HKQuery {
        let predicate = HKQuery.predicateForSamples(withStart: Date(), end: nil, options: HKQueryOptions())
        
        let query = HKAnchoredObjectQuery(type: hRType, predicate: predicate, anchor: nil, limit: Int(HKObjectQueryNoLimit)) { (query, samples, deletedObjects, anchor, error) -> Void in
            self.addSamples(samples)
        }
        query.updateHandler = { (query, samples, deletedObjects, anchor, error) -> Void in
            self.addSamples(samples)
        }
        
        return query
    }
    fileprivate func addSamples(_ samples: [HKSample]?) {
        guard let samples = samples as? [HKQuantitySample] else { return }
        guard let quantity = samples.last?.quantity else { return }
        label.setText("\(quantity.doubleValue(for: hRUnit))")
    }
}
