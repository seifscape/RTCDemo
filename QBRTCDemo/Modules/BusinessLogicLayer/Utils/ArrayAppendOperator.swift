//
//  ArrayAppendOperator.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 09.12.16.
//  Copyright © 2016 anton. All rights reserved.
//

import Foundation

extension Array {
	
}

func += <V> (left: inout [V], right: V) {
	left.append(right)
}
