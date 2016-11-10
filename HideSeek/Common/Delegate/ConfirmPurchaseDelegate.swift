//
//  ConfirmPurchaseDelegate.swift
//  HideSeek
//
//  Created by apple on 8/3/16.
//  Copyright © 2016 mj. All rights reserved.
//

protocol ConfirmPurchaseDelegate {
    func confirmPurchase(_ product: Product, count: Int, orderId: Int64)
}
