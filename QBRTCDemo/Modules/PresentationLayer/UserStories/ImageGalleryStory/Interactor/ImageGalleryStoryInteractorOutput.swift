//
//  ImageGalleryStoryInteractorOutput.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 15/02/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation

protocol ImageGalleryStoryInteractorOutput: class {

	func didStartSynchronizationImages()
	func didFinishSynchronizationImages()
	
	func didReceiveRoleSender()
	func didReceiveRoleReceiver()
	
}
