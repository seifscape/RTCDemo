//
//  VideoCallStoryViewTests.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 01/12/2016.
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

class VideoCallStoryViewTests: XCTestCase {

	var controller: VideoCallStoryViewController!
	var mockOutput: MockViewControllerOutput!
	let emptySender = UIButton()
	
	let testUser2 = TestsStorage.svuserRealUser2
	
    override func setUp() {
        super.setUp()
		controller = UIStoryboard(name: "VideoCallStory", bundle: nil).instantiateViewController(withIdentifier: String(describing: VideoCallStoryViewController.self)) as! VideoCallStoryViewController
		
		mockOutput = MockViewControllerOutput()
		controller.output = mockOutput
		controller.alertControl = FakeAlertControl()
    }

    override func tearDown() {
        controller = nil
		mockOutput = nil
        super.tearDown()
    }
	
	// MARK: - Testing life cycle
	
	func testViewNotifiesPresenterOnDidLoad() {
		// when
		controller.viewDidLoad()
		
		// then
		XCTAssertTrue(mockOutput.viewIsReadyGotCalled)
	}
	
	// MARK: Testing IBActions
	
	func testHangupButtonTriggersAction() {
		// when
		controller.didTapButtonHangup(emptySender)
		
		// then
		XCTAssertTrue(mockOutput.hangupButtonTapped)
	}
	
	func testSwitchCameraButtonTriggersAction() {
		// when
		controller.didTapButtonSwitchCamera(emptySender)
		
		// then
		XCTAssertTrue(mockOutput.switchCameraButtonTapped)
	}
	
	func testSwitchAudioRouteButtonTriggersAction() {
		// when
		controller.didTapButtonSwitchAudioRoute(emptySender)
		
		// then
		XCTAssertTrue(mockOutput.switchAudioRouteButtonTapped)
	}
	
	func testSwitchLocalVideoTrackButtonTriggersAction() {
		// when
		controller.didTapButtonSwitchLocalVideoTrack(emptySender)
		
		// then
		XCTAssertTrue(mockOutput.switchLocalVideoTrackButtonTapped)
	}
	
	func testMuteButtonTriggersAction() {
		// when
		controller.didTapButtonMicrophone(emptySender)
		
		// then
		XCTAssertTrue(mockOutput.microphoneButtonTapped)
	}
	
	func testSuccessDataChannelButton_ImageGalleryTriggersAction() {
		// when
		controller.didTapButtonDataChannelImageGallery(emptySender)
		
		// then
		XCTAssertTrue(mockOutput.dataChannelButtonTapped)
	}
	
	func testShowHangupEventuallyCallsCloseAction() {
		// when
		controller.showHangup()
		
		// then
		XCTAssertTrue(mockOutput.closeButtonTapped)
	}
	
	func testShowOpponentHangupEventuallyCallsCloseAction() {
		// when
		controller.showOpponentHangup()
		
		// then
		XCTAssertTrue(mockOutput.closeButtonTapped)
	}
	
	func testShowOpponentRejectEventuallyCallsCloseAction() {
		// when
		controller.showOpponentReject()
		
		// then
		XCTAssertTrue(mockOutput.closeButtonTapped)
	}
	
	func testShowOpponentAnswerTimeoutEventuallyCallsCloseAction() {
		// when
		controller.showOpponentAnswerTimeout()
		
		// then
		XCTAssertTrue(mockOutput.closeButtonTapped)
	}
	
	func testShowCallServiceFailureEventuallyCallsCloseAction() {
		// when
		controller.showErrorCallServiceDisconnected()
		
		// then
		XCTAssertTrue(mockOutput.closeButtonTapped)
	}
	
	// MARK: Testing methods of VideoCallStoryViewInput

	func testShowsDialingInformation() {
		// when
		controller.showStartDialingOpponent(testUser2)
		
		// then
		XCTAssertEqual(controller.navigationItem.title, "Dialing \(testUser2.fullName)...")
	}
	
	func testShowsConnectedCallInformation() {
		// when
		controller.showReceivedAnswerFromOpponent(testUser2)
		
		// then
		XCTAssertEqual(controller.navigationItem.title, "Call with \(testUser2.fullName)")
	}
	
	class MockViewControllerOutput: NSObject, VideoCallStoryViewOutput {
		var viewIsReadyGotCalled = false
		var hangupButtonTapped = false
		var dataChannelButtonTapped = false
		var closeButtonTapped = false
		var switchCameraButtonTapped = false
		var switchAudioRouteButtonTapped = false
		var switchLocalVideoTrackButtonTapped = false
		var microphoneButtonTapped = false
		
		func viewIsReady() {
			viewIsReadyGotCalled = true
		}
		
		func didTriggerHangupButtonTapped() {
			hangupButtonTapped = true
		}
		
		func didTriggerDataChannelButtonTapped() {
			dataChannelButtonTapped = true
		}
		
		func didTriggerCloseButtonTapped() {
			closeButtonTapped = true
		}
		
		func didTriggerSwitchCameraButtonTapped() {
			switchCameraButtonTapped = true
		}
		
		func didTriggerSwitchAudioRouteButtonTapped() {
			switchAudioRouteButtonTapped = true
		}
		
		func didTriggerSwitchLocalVideoTrackStateButtonTapped() {
			switchLocalVideoTrackButtonTapped = true
		}
		
		func didTriggerMicrophoneButtonTapped() {
			microphoneButtonTapped = true
		}
	}
}

