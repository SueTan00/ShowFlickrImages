//
//  Result.swift
//  ShowFlickrImg
//
//  Created by Sue Tan on 6/3/19.
//  Copyright © 2019 Sue Tan. All rights reserved.
//

import Foundation
enum Result<ResultType> {
    case results(ResultType)
    case error(Error)
}
