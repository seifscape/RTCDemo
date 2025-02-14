//
//  ChatUsersStoryInteractorTests.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 06/05/2016.
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

class ChatUsersStoryInteractorTests: XCTestCase {

	var interactor: ChatUsersStoryInteractor!
	var mockOutput: MockPresenter!
	var mockCacheService: FakeCacheService!
	var mockRESTService: MockRESTService!
	var callService: FakeCallService!
	
	var testUser: SVUser!
	let tag = "tag"
	
	override func setUp() {
		super.setUp()
		interactor = ChatUsersStoryInteractor()
		mockOutput = MockPresenter()
		interactor.output = mockOutput

		mockCacheService = FakeCacheService()
		interactor.cacheService = mockCacheService
		callService = FakeCallService()
		callService.signalingChannel = FakeSignalingChannel()
		interactor.callService = callService
		mockRESTService = MockRESTService()
		interactor.restService = mockRESTService
		
		testUser = TestsStorage.svuserTest
	}
	
	// MARK: ChatUsersStoryInteractorInput tests
	func testRetrievesUsersFromCacheAndDownloadsThemFromREST() {
		// given
		let cachedUsers = interactor.cacheService.cachedUsersForRoomWithName(tag)
		interactor.chatRoomName = tag
		
		// when
		interactor.retrieveUsersWithTag()
		
		// then
		XCTAssertTrue(mockOutput.didRetrieveUsersGotCalled)
		XCTAssertNotNil(mockOutput.retrievedUsers)
		XCTAssertEqualOptional(mockOutput.retrievedUsers, cachedUsers)
	}
	
	func testSetsTagIfTagContainMoreThanThreeCharacters() {
		// when
		interactor.setChatRoomName(tag)
		
		// then
		XCTAssertNil(mockOutput.error)
		XCTAssertTrue(mockOutput.didSetChatRoomNameGotCalled)
	}
	
	func testDoesNOTSetTagIfTagContainLessThanThreeCharacters() {
		// given
		let tag = "ta"
		
		// when
		interactor.setChatRoomName(tag)
		
		// then
		XCTAssertEqual(mockOutput.error, ChatUsersStoryInteractorError.tagLengthMustBeGreaterThanThreeCharacters)
		XCTAssertFalse(mockOutput.didSetChatRoomNameGotCalled)
	}
	
	func testDownloadsUsersFromRESTAndCaches() {
		// given
		mockCacheService.cachedUsersArray = nil
		interactor.chatRoomName = tag
		
		// when
		interactor.retrieveUsersWithTag()
		
		// then
		XCTAssertTrue(mockRESTService.downloadUsersWithTagsGotCalled)

		XCTAssertEqualOptional(mockCacheService.cachedUsersForRoomWithName("tag"), mockOutput.retrievedUsers) // users should be cached
		XCTAssertEqualOptional(mockOutput.retrievedUsers, mockRESTService.restUsersArray)
	}
	
	func testApprovesRequestedCallForOpponent_whenChatIsConnected() {
		// given
		callService.shouldBeConnected = true
		
		// when
		interactor.requestCallWithOpponent(testUser)
		
		// then
		XCTAssertTrue(mockOutput.didReceiveApprovedRequestForCallWithOpponentGotCalled)
		XCTAssertFalse(mockOutput.didDeclineRequestForCallWithOpponentGotCalled)
	}
	
	func testDeclinesRequestedCallForOpponent_whenChatIsNOTConnected() {
		// given
		callService.shouldBeConnected = false
		
		// when
		interactor.requestCallWithOpponent(testUser)
		
		// then
		XCTAssertTrue(mockOutput.didDeclineRequestForCallWithOpponentGotCalled)
		XCTAssertFalse(mockOutput.didReceiveApprovedRequestForCallWithOpponentGotCalled)
	}
	
	func testNotifiesPresenterAboutCurrentUserNotifiedOtherUsersInChatRoom() {
		// given
		callService.shouldBeConnected = true
		interactor.chatRoomName = tag
		
		// when
		interactor.notifyUsersAboutCurrentUserEnteredRoom()
		
		// then
		XCTAssertTrue(mockOutput.didNotifyUsersAboutCurrentUserEnteredRoomGotCalled)
	}
	
	func testNotifiesPresenterAboutCurrentUserFailedToNotifyOtherUsersInChatRoom() {
		// given
		callService.shouldBeConnected = true
		interactor.chatRoomName = tag
		
		// when
		interactor.notifyUsersAboutCurrentUserEnteredRoom()
		
		// then
		XCTAssertTrue(mockOutput.didNotifyUsersAboutCurrentUserEnteredRoomGotCalled)
	}
	
	// MARK: ChatUsersStoryInteractor CallServiceDelegate tests
	
	func testNotifiesPresenterAboutIncomingCall() {
		// given
		let tag = "tag"
		let opponentUser = TestsStorage.svuserRealUser1
		
		let fakeCallService = FakeCallService()
		ServicesConfigurator().configureCallService(fakeCallService)
		fakeCallService.signalingChannel = FakeSignalingChannel()
		
		// when
		interactor.setChatRoomName(tag)
		
		interactor.callService(fakeCallService, didReceiveCallRequestFromOpponent: opponentUser)
		
		// then
		XCTAssertTrue(mockOutput.didReceiveCallRequestFromOpponentGotCalled)
		XCTAssertEqual(mockOutput.opponent, opponentUser)
	}
	
	func testNotifiesPresenterWhenReceivedNewUser_forCurrentChatRoomName() {
		// given
		let tag = "tag"
		let opponentUser = TestsStorage.svuserRealUser1
		// when
		interactor.setChatRoomName(tag)
		
		interactor.callService(interactor.callService, didReceiveUser: opponentUser, forChatRoomName: tag)
		
		// then
		XCTAssertTrue(mockOutput.didRetrieveUsersGotCalled)
	}
	
	func testDoesntNotifyPresenterWhenReceivedNewUser_forUndefinedChatRoomName() {
		// given
		let tag = "tag"
		let opponentUser = TestsStorage.svuserRealUser1
		// when
		interactor.setChatRoomName(tag)
		
		interactor.callService(interactor.callService, didReceiveUser: opponentUser, forChatRoomName: "blah blah")
		
		// then
		XCTAssertFalse(mockOutput.didRetrieveUsersGotCalled)
	}
	
    class MockPresenter: ChatUsersStoryInteractorOutput {
		var retrievedUsers: [SVUser]?
		var didRetrieveUsersGotCalled = false
		
		var didReceiveCallRequestFromOpponentGotCalled = false
		var opponent: SVUser?
		
		var error: ChatUsersStoryInteractorError?
		var didSetChatRoomNameGotCalled = false
		
		var didReceiveApprovedRequestForCallWithOpponentGotCalled = false
		var didDeclineRequestForCallWithOpponentGotCalled = false
		
		var didNotifyUsersAboutCurrentUserEnteredRoomGotCalled = false
		var didFailToNotifyUsersAboutCurrentUserEnteredRoomGotCalled = false
		
		func didRetrieveUsers(_ users: [SVUser]) {
			didRetrieveUsersGotCalled = true
			retrievedUsers = users
		}
		
		func didError(_ error: ChatUsersStoryInteractorError) {
			self.error = error
		}
		
		func didSetChatRoomName(_ chatRoomName: String) {
			didSetChatRoomNameGotCalled = true
		}
		
		func didReceiveCallRequestFromOpponent(_ opponent: SVUser) {
			self.opponent = opponent
			didReceiveCallRequestFromOpponentGotCalled = true
		}
		
		func didReceiveApprovedRequestForCallWithOpponent(_ opponent: SVUser) {
			didReceiveApprovedRequestForCallWithOpponentGotCalled = true
		}
		
		func didDeclineRequestForCallWithOpponent(_ opponent: SVUser, reason: String) {
			didDeclineRequestForCallWithOpponentGotCalled = true
		}
		
		func didNotifyUsersAboutCurrentUserEnteredRoom() {
			didNotifyUsersAboutCurrentUserEnteredRoomGotCalled = true
		}
		
		func didFailToNotifyUsersAboutCurrentUserEnteredRoom() {
			didFailToNotifyUsersAboutCurrentUserEnteredRoomGotCalled = true
		}
    }
	
	class MockRESTService: FakeQBRESTService {
		var downloadUsersWithTagsGotCalled = false
		var restUsersArray: [SVUser] = [TestsStorage.svuserTest]
		
		override func downloadUsersWithTags(_ tags: [String], successBlock: @escaping (_ users: [SVUser]) -> Void, errorBlock: @escaping (_ error: Error?) -> Void) {
			downloadUsersWithTagsGotCalled = true
			successBlock(restUsersArray)
		}
	}
}
