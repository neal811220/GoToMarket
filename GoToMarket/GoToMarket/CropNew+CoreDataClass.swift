//
//  CropNew+CoreDataClass.swift
//  GoToMarket
//
//  Created by 許庭瑋 on 2018/5/1.
//  Copyright © 2018年 許庭瑋. All rights reserved.
//
//

import Foundation
import CoreData


public class CropNew: NSManagedObject
{
    class func findOrCreateQuote(matching quoteInfo:CropNewQuote, in context: NSManagedObjectContext) -> CropNew
    {
        let request: NSFetchRequest<CropNew> = CropNew.fetchRequest()
        request.predicate = NSPredicate(format: "(cropCode = %@) AND (marketName = %@)", quoteInfo.cropCode, quoteInfo.marketName)
        do {
            let maches = try context.fetch(request)
            if maches.count > 0 {
                if maches.count > 1 {
                    maches.forEach {
                        print($0)
                    }
                }
                context.delete(maches[0])
            }
        } catch {
            print(error)
        }
        let newCrop = CropNew(context: context)
        newCrop.cropCode = quoteInfo.cropCode
        newCrop.cropName = quoteInfo.cropName
        newCrop.averagePrice = quoteInfo.averagePrice
        newCrop.date = quoteInfo.date
        newCrop.marketName = quoteInfo.marketName
        return newCrop
    }

}
