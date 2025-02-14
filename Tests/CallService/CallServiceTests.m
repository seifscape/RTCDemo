//
//  CallServiceTests.m
//  RTCDemo
//
//  Created by Anton Sokolchenko on 2/9/16.
//  Copyright © 2016 anton. All rights reserved.
//

#import <OCMock.h>
#import <XCTest/XCTest.h>


#import <RTCIceCandidate.h>
#import <RTCSessionDescription.h>
#import <RTCPeerConnection.h>

#import "CallServiceHelpers.h"

#import "CallServiceDelegate.h"

#import "SVSignalingMessage.h"
#import "SVSignalingMessageSDP.h"
#import "SVSignalingMessageICE.h"
#import "SVSignalingParams.h"

@interface CallServiceTests : XCTestCase

@property (nonatomic, strong) CallService<SVSignalingChannelDelegate, CallServiceProtocol, CallServiceDataChannelAdditionsProtocol> *callService;
@property (nonatomic, strong) id mockOutput;
@property (nonatomic, strong) id mockCallService;

@property (nonatomic, strong) SVUser *user1;
@property (nonatomic, strong) SVUser *user2;
@property (nonatomic, strong) SVUser *user3;
@property (nonatomic, strong) FakeSignalingChannel *signalingChannel;

@end

@implementation CallServiceTests

- (void)setUp {
	self.user1 = [CallServiceHelpers user1];
	self.user2 = [CallServiceHelpers user2];
	self.user3 = [[SVUser alloc] initWithID:@1 login:@"login" password:@""];
	
	self.mockOutput = OCMProtocolMock(@protocol(CallServiceDelegate));
	self.signalingChannel = [FakeSignalingChannel new];
	
	self.callService = [[CallService alloc] initWithSignalingChannel:self.signalingChannel callServiceDelegate:self.mockOutput];
	
	self.mockCallService = OCMPartialMock(self.callService);
}

- (void)tearDown {
	self.callService = nil;
	self.signalingChannel = nil;
	self.mockCallService = nil;
	self.mockOutput = nil;
}

#pragma mark - Expectations
- (XCTestExpectation *)currentSelectorTestExpectation {
	NSInvocation *invocation = self.invocation;
	NSString *selectorName = invocation ? NSStringFromSelector(invocation.selector) : @"testExpectation";
	return [self expectationWithDescription:selectorName];
}

- (void)waitForTestExpectations {
	[self waitForExpectationsWithTimeout:10.0 handler:nil];
}


#pragma mark CallClientDelegate tests

- (void)testCorrectlyCleanupsSessionAfterDisconnectFromChat {
	// given
	OCMExpect([self.mockCallService clearSession]);
	
	// when
	[self.callService connectWithUser:self.user1 completion:nil];
	[self.callService channel:self.callService.signalingChannel didChangeState:SVSignalingChannelState.error];
	
	// then
	XCTAssertEqual(self.callService.state, kClientStateDisconnected);
	OCMVerify([self.mockOutput callService:[OCMArg any] didChangeState:kClientStateDisconnected]);
	OCMVerifyAll(self.mockCallService);
}

- (void)testCorrectlyStopsJustStartedCall_andStopsDialing {
	// given
	OCMReject([self.mockOutput callService:[OCMArg any] didChangeState:kClientStateDisconnected]);
	OCMExpect([self.mockCallService stopDialing]);
	
	// when
	[self.callService connectWithUser:self.user1 completion:nil];
	[self.callService startCallWithOpponent:self.user2];
	[self.callService hangup];

	// then
	OCMVerify([self.mockOutput callService:[OCMArg any] didChangeState:kClientStateConnected]);
	OCMVerifyAll(self.mockCallService);
}

#pragma mark Signaling messages processing

- (void)testDoesntClearSessionAferHangupSignalingMessageFromUndefinedOpponent {
	// given
	[[self.mockCallService reject] peerConnection:[OCMArg any] didSetSessionDescriptionWithError:[OCMArg isNotNil]];
	[[self.mockCallService reject] clearSession];
	[[self.mockCallService reject] processSignalingMessage:[OCMArg any]];
	
	SVSignalingMessage *hangup = [SVSignalingMessage messageWithType:SVSignalingMessageType.hangup params:nil];
	
	hangup.sender = self.user3;
	
	// when
	[self.callService connectWithUser:self.user1 completion:nil];
	[self.callService startCallWithOpponent:self.user2];
	
	[self.callService channel:self.callService.signalingChannel didReceiveMessage:hangup];
	
	// then
	OCMVerify([self.mockCallService drainMessageQueueIfReady]);
}

- (void)testCorrectlyProcessesSignalingMessageIceWithAudioAndVideoFromOpponent {
	// given
	[[self.mockCallService reject] peerConnection:[OCMArg any] didSetSessionDescriptionWithError:[OCMArg isNotNil]];
	
	RTCIceCandidate *rtcIceCandidateAudio = [[RTCIceCandidate alloc] initWithMid:@"audio" index:0 sdp:@"candidate:1009584571 1 udp 2122260223 192.168.8.197 58130 typ host generation 0 ufrag 0+C/nsdLdjk3x5eG"];
	
	RTCIceCandidate *rtcIceCandidateVideo = [[RTCIceCandidate alloc] initWithMid:@"video" index:1 sdp:@"candidate:1009584571 1 udp 2122260223 192.168.8.197 62216 typ host generation 0 ufrag 0+C/nsdLdjk3x5eG"];
	
	SVSignalingMessage *iceAudio = [[SVSignalingMessageICE alloc] initWithICECandidate:rtcIceCandidateAudio];
	SVSignalingMessage *iceVideo = [[SVSignalingMessageICE alloc] initWithICECandidate:rtcIceCandidateVideo];
	
	iceAudio.sender = self.user2;
	iceVideo.sender = self.user2;
	
	OCMExpect([self.mockCallService drainMessageQueueIfReady]);
	
	// when
	[self.callService connectWithUser:self.user1 completion:nil];
	[self.callService startCallWithOpponent:self.user2];
	
	[self.callService channel:self.callService.signalingChannel didReceiveMessage:iceAudio];
	[self.callService channel:self.callService.signalingChannel didReceiveMessage:iceVideo];
	
	// then
	OCMVerifyAll(self.mockCallService);
}

- (void)testCorrectlyProcessesSignalingMessageOfferFromOpponent_andThenHisIceCandidates {
	// given
	[[self.mockCallService reject] peerConnection:[OCMArg any] didSetSessionDescriptionWithError:[OCMArg isNotNil]];
	
	RTCSessionDescription *rtcofferSDP = [[RTCSessionDescription alloc] initWithType:SVSignalingMessageType.offer sdp:[CallServiceHelpers offerSDP]];
	
	SVSignalingMessage *offerSDP = [[SVSignalingMessageSDP alloc] initWithSessionDescription:rtcofferSDP];
	
	offerSDP.sender = self.user2;
	
	RTCIceCandidate *rtcIceCandidateAudio = [[RTCIceCandidate alloc] initWithMid:@"audio" index:0 sdp:@"candidate:1009584571 1 udp 2122260223 192.168.8.197 58130 typ host generation 0 ufrag 0+C/nsdLdjk3x5eG"];
	
	RTCIceCandidate *rtcIceCandidateVideo = [[RTCIceCandidate alloc] initWithMid:@"video" index:1 sdp:@"candidate:1009584571 1 udp 2122260223 192.168.8.197 62216 typ host generation 0 ufrag 0+C/nsdLdjk3x5eG"];
	
	SVSignalingMessage *iceAudio = [[SVSignalingMessageICE alloc] initWithICECandidate:rtcIceCandidateAudio];
	SVSignalingMessage *iceVideo = [[SVSignalingMessageICE alloc] initWithICECandidate:rtcIceCandidateVideo];
	
	iceAudio.sender = self.user2;
	iceVideo.sender = self.user2;
	
	OCMExpect([[self.mockCallService peerConnection] createAnswerWithDelegate:[OCMArg any] constraints:[OCMArg any]]);
	
	// when
	[self.callService connectWithUser:self.user1 completion:nil];
	
	[self.callService channel:self.callService.signalingChannel didReceiveMessage:offerSDP];
	
	[self.callService acceptCallFromOpponent:offerSDP.sender];
	
	[self.callService channel:self.callService.signalingChannel didReceiveMessage:iceAudio];
	[self.callService channel:self.callService.signalingChannel didReceiveMessage:iceVideo];
	
	// then
	OCMVerify([self.mockCallService processSignalingMessage:offerSDP]);
	OCMVerify([self.mockCallService processSignalingMessage:iceAudio]);
	OCMVerify([self.mockCallService processSignalingMessage:iceVideo]);
	
	OCMVerifyAll(self.mockCallService);
}

- (void)testCallsDidError_onFailedSignalingMessage {
	// given
	self.signalingChannel.shouldSendMessagesSuccessfully = NO;
	
	// when
	[self.callService sendSignalingMessage:[SVSignalingMessage messageWithType:SVSignalingMessageType.offer params:nil]];
	
	// then
	OCMVerify([self.mockOutput callService:self.callService didError:[OCMArg any]]);
}

@end
