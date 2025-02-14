//
//  IncomingCallStoryConfigurator.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 15/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import UIKit

class IncomingCallStoryModuleConfigurator {

	func configureModuleForViewInput(_ viewInput: IncomingCallStoryViewController) {
		configure(viewInput)
	}

    fileprivate func configure(_ viewController: IncomingCallStoryViewController) {

        let router = IncomingCallStoryRouter()
		router.transitionHandler = viewController
		
        let presenter = IncomingCallStoryPresenter()
        presenter.view = viewController
        presenter.router = router

        let interactor = IncomingCallStoryInteractor()
        interactor.output = presenter
		interactor.callService = ServicesProvider.currentProvider.callService
		
		ServicesProvider.currentProvider.callService.addObserver(interactor)
		
        presenter.interactor = interactor
        viewController.output = presenter
    }

}
