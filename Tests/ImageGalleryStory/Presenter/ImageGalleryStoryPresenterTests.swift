//
//  ImageGalleryStoryPresenterTests.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 15/02/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import XCTest

#if QBRTCDemo_s
	@testable
	import QBRTCDemo_s
#elseif QBRTCDemo
	@testable
	import QBRTCDemo
#endif

class ImageGalleryStoryPresenterTest: XCTestCase {
	var presenter: ImageGalleryStoryPresenter!
	var mockInteractor: MockInteractor!
	var mockRouter: MockRouter!
	var mockView: MockViewController!
	
    override func setUp() {
        super.setUp()
		presenter = ImageGalleryStoryPresenter()
		
		mockInteractor = MockInteractor()
		
		mockRouter = MockRouter()
		mockView = MockViewController()
		
		presenter.interactor = mockInteractor
		presenter.router = mockRouter
		presenter.view = mockView
    }
	
	//
	// MARK: ImageGalleryStoryInteractorInput tests
	//
	
	func testPresenterHandlesViewReadyEvent() {
		// when
		presenter.viewIsReady()
		
		// then
		XCTAssertTrue(mockView.setupInitialStateGotCalled)
		XCTAssertTrue(mockView.collectionViewGotCalled)
		XCTAssertTrue(mockInteractor.configureCollectionViewGotCalled)
	}
	
	func testPresenterHandlesStartButtonTapedEvent() {
		// when
		presenter.didTriggerStartButtonTapped()
		
		// then
		XCTAssertTrue(mockInteractor.startSynchronizationImagesGotCalled)
	}
	
	func testPresenterConfiguresModule() {
		// when
		self.presenter.configureModule()
		
		// then
		XCTAssertTrue(mockInteractor.requestCallerRoleGotCalled)
	}
	
	//
	// MARK: ImageGalleryStoryViewInput tests
	//
	
	func testPresenterConfiguresView_whenReceiver() {
		// when
		presenter.didReceiveRoleReceiver();
		
		// then
		XCTAssertTrue(mockView.configureViewForReceivingGotCalled)
	}
	
	func testPresentedHandlesDidStartSynchronizationImages() {
		// when
		presenter.didStartSynchronizationImages()
		
		// then
		XCTAssertTrue(mockView.showSynchronizationImagesStartedGotCalled)
	}
	
	func testPresentedHandlesDidFinishSynchronizationImages() {
		// when
		presenter.didFinishSynchronizationImages()
		
		// then
		XCTAssertTrue(mockView.showSynchronizationImagesFinishedGotCalled)
	}
	
	// MARK: ImageGalleryStoryCollectionViewInteractorOutput
	
	func testPresenterCallsReloadCollectionView_onDidUpdateImages() {
		// when
		presenter.didUpdateImages();
		
		// then
		XCTAssertTrue(mockView.reloadCollectionViewGotCalled)
	}

    class MockInteractor: ImageGalleryStoryInteractorInput {
		var startSynchronizationImagesGotCalled = false
		
		var configureWithCallServiceGotCalled = false
		var configureCollectionViewGotCalled = false
		var requestCallerRoleGotCalled = false
		
		func startSynchronizationImages() {
			startSynchronizationImagesGotCalled = true
		}
		
		func requestCallerRole() {
			requestCallerRoleGotCalled = true
		}
		
		func configureCollectionView(_ collectionView: ImageGalleryStoryCollectionView) {
			configureCollectionViewGotCalled = true
		}
    }

    class MockRouter: ImageGalleryStoryRouterInput {

    }

    class MockViewController: ImageGalleryStoryViewInput {
		
		var configureViewForReceivingGotCalled = false
		var reloadCollectionViewGotCalled = false
		var collectionViewGotCalled = false
		
		var setupInitialStateGotCalled = false
		var showSynchronizationImagesStartedGotCalled = false
		var showSynchronizationImagesFinishedGotCalled = false
		
        func setupInitialState() {
			setupInitialStateGotCalled = true
        }
		
		func configureViewForReceiving() {
			configureViewForReceivingGotCalled = true
		}
		
		func reloadCollectionView() {
			reloadCollectionViewGotCalled = true
		}
		
		func showSynchronizationImagesStarted() {
			showSynchronizationImagesStartedGotCalled = true
		}
		
		func showSynchronizationImagesFinished() {
			showSynchronizationImagesFinishedGotCalled = true
		}

		func collectionView() -> ImageGalleryStoryCollectionView {
			collectionViewGotCalled = true
			let collection = ImageGalleryStoryCollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
			return collection
		}
    }
}
