//
//  FetchTimeAPI.swift
//  Havas
//
//  Created by boqian cheng on 2018-05-30.
//  Copyright © 2018 boqiancheng. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import Moya

public enum FetchTimeAPI {
    case fetch(paras: [String:Any])
}

extension FetchTimeAPI: TargetType {
    
    public var baseURL: URL {
        return URL(string: "https://ezcmd.com/apps/api_eztime/time_by_address/GUEST_USER")!
    }
    
    public var path: String {
        return "/-1"
    }
    
    public var method: Moya.Method {
        return .get
    }
    
    public var task: Task {
        switch self {
        case .fetch(let paras):
            return .requestParameters(parameters: paras, encoding: URLEncoding.default)
        }
    }
    
    public var validate: Bool {
        return false
    }
    
    public var sampleData: Data {
        return "Havas test.".data(using: String.Encoding.utf8)!
    }
    
    public var headers: [String: String]? {
        return nil
    }
}


