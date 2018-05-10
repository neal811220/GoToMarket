//
//  QuotesStructs.swift
//  GoToMarket
//
//  Created by 許庭瑋 on 2018/4/30.
//  Copyright © 2018年 許庭瑋. All rights reserved.
//

import Foundation

struct CropQuote: Decodable {
    let date: String
    let cropCode: String
    let cropName: String
    let marketName: String
    let averagePrice: Double
    
    private enum CodingKeys: String, CodingKey {
        case date = "交易日期"
        case cropCode = "作物代號"
        case cropName = "作物名稱"
        case marketName = "市場名稱"
        case averagePrice = "平均價"
    }
}

protocol CustomStringGettable {
    func getCustomString() -> String
}

protocol marketEnum: CustomStringGettable, OpenDataQueryItemConvertable {}

protocol enumCaseGetable {

    func getEnumCase() -> enumCaseGetable
}

protocol requestEnum: enumCaseGetable, OpenDataQueryItemConvertable{}

struct CropRequest: OpenDataRequest {
    
    var domainURL: String = CropApiConstant.baseURL
    var market: marketEnum
    var requestType: requestEnum
    
    init (cropRequestType: CropQueryType, cropMarket: CropMarkets) {
        self.requestType = cropRequestType
        self.market = cropMarket
    }
    
}

enum CropMarkets: marketEnum {
    
    case taipei
    case tauyuan
    case taichung
    case nantou
    case kaoshung
    case taidong
    case ilan
    
    func getCustomString() -> String {
        switch self {
        case .taipei:
            return CropApiConstant.taipei
        case .ilan:
            return CropApiConstant.ilan
        case .kaoshung:
            return CropApiConstant.kaoshung
        case .nantou:
            return CropApiConstant.nantou
        case .taichung:
            return CropApiConstant.taichung
        case .taidong:
            return CropApiConstant.taidong
        case .tauyuan:
            return CropApiConstant.tauyuan
        }
    }

    func getNSURLQueryItem() -> [URLQueryItem] {
        let marketTitle = CropApiConstant.fixedSearchMarket
        switch self {
        case .taipei:
            return [URLQueryItem(name: marketTitle, value: CropApiConstant.taipei)]
        case .ilan:
            return [URLQueryItem(name: marketTitle, value: CropApiConstant.ilan)]
        case .kaoshung:
            return [URLQueryItem(name: marketTitle, value: CropApiConstant.kaoshung)]
        case .nantou:
            return [URLQueryItem(name: marketTitle, value: CropApiConstant.nantou)]
        case .taichung:
            return [URLQueryItem(name: marketTitle, value: CropApiConstant.taichung)]
        case .taidong:
            return [URLQueryItem(name: marketTitle, value: CropApiConstant.taidong)]
        case .tauyuan:
            return [URLQueryItem(name: marketTitle, value: CropApiConstant.tauyuan)]
        }
    }
}


enum CropQueryType: requestEnum {
    
    func getEnumCase() -> enumCaseGetable {
        return self
    }
    
    case updateQuote
    case getInitailQuotes
    case getHistoryQutoes(CropCode: String)
    
    func getNSURLQueryItem() -> [URLQueryItem] {
        let searchCodeTitle = CropApiConstant.searchCropCode
        let fromDateTitle = CropApiConstant.searchFromDate
        let endDateTitle = CropApiConstant.searchEndDate
        switch self {
        case .updateQuote:
            let fromDateItem =
                URLQueryItem(name: fromDateTitle, value: TwDateProvider.getTodayString())
            return [fromDateItem]
        case .getInitailQuotes:
            let fromDateItem =
                URLQueryItem(name: fromDateTitle, value: TwDateProvider.getTodayString())
            let toDateItem =
                URLQueryItem(name: endDateTitle, value: TwDateProvider.getLastWeekString())
            return [fromDateItem,toDateItem]
        case .getHistoryQutoes(CropCode: let code):
            let fromDateItem =
                URLQueryItem(name: fromDateTitle, value: TwDateProvider.getTodayString())
            let toDateItem =
                URLQueryItem(name: endDateTitle, value: TwDateProvider.getLastMonthString())
            let cropCodeItem =
                URLQueryItem(name: searchCodeTitle, value: code)
            return [fromDateItem,toDateItem,cropCodeItem]
        }
    }
}


