//
//  AuthStoryConfiguratorTests.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 27/03/2016.
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

class AuthStoryModuleConfiguratorTests: XCTestCase {

    func testConfigureModuleForViewController() {

        //given
        let viewController = AuthStoryViewControllerMock()
        let configurator = AuthStoryModuleConfigurator()

        //when
        configurator.configureModuleForViewInput(viewController)

        //then
        XCTAssertNotNil(viewController.output, "AuthStoryViewController is nil after configuration")
        XCTAssertTrue(viewController.output is AuthStoryPresenter, "output is not AuthStoryPresenter")
		XCTAssertNotNil(viewController.alertControl, "alertControl in AuthStoryViewController is nil after configuration")
		
        let presenter: AuthStoryPresenter = viewController.output as! AuthStoryPresenter
        XCTAssertNotNil(presenter.view, "view in AuthStoryPresenter is nil after configuration")
        XCTAssertNotNil(presenter.router, "router in AuthStoryPresenter is nil after configuration")
        XCTAssertTrue(presenter.router is AuthStoryRouter, "router is not AuthStoryRouter")
		XCTAssertNotNil((presenter.router as! AuthStoryRouter).transitionHandler, "router transitionHandler is nil after configuration")
		
        let interactor: AuthStoryInteractor = presenter.interactor as! AuthStoryInteractor
        XCTAssertNotNil(interactor.output, "output in AuthStoryInteractor is nil after configuration")
		XCTAssertNotNil(interactor.restService, "restService in AuthStoryInteractor is nil after configuration")
		XCTAssertNotNil(interactor.callService, "callService in AuthStoryInteractor is nil after configuration")
    }

    class AuthStoryViewControllerMock: AuthStoryViewController {

        var setupInitialStateDidCall = false

        override func setupInitialState() {
            setupInitialStateDidCall = true
        }
    }
}
