//
//  PurchaseDelegate.swift
//  HideSeek
//
//  Created by apple on 8/2/16.
//  Copyright © 2016 mj. All rights reserved.
//

protocol PurchaseDelegate {
    func purchase(_ product: Product, orderId: Int64)
    
    func purchase()
}
