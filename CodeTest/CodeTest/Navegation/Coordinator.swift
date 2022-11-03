//
//  Coordinator.swift
//  CodeTest
//
//  Created by Edwin Peña on 6/10/22.
//

import UIKit

protocol Coordinator: AnyObject {
    func start()
    func showDetails(for movie: MovieViewModel)
}

final class MainCoordinator: Coordinator {
    private let window: UIWindow
    private var navigationController: UINavigationController?
    private let dependencyProvider: ApplicationFactory

    init(window: UIWindow,
         navigationController: UINavigationController = UINavigationController(),
         dependencyProvider: ApplicationFactory = ApplicationFactory()) {
        self.window = window
        self.navigationController = navigationController
        self.dependencyProvider = dependencyProvider
    }

    func start() {
        let viewModel = ListViewModel(coordinator: self,
                                      loadImageUseCase: dependencyProvider.loadImageUseCase,
                                      moviesUseCase: dependencyProvider.moviesUseCase)
        let viewController = ListViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        self.navigationController = navigationController
        setupListNavegation(vc: viewController)
        window.rootViewController = navigationController
    }

    func showDetails(for movie: MovieViewModel) {
        let viewModel = DetailViewModel(coordinator: self,
                                      loadImageUseCase: dependencyProvider.loadImageUseCase,
                                        moviesUseCase: dependencyProvider.moviesUseCase,
                                        movie: movie)
        let viewController = DetailViewController(viewModel: viewModel)
        setupDetailNavegation(vc: viewController)
        self.navigationController?.pushViewController(viewController,
                                                     animated: true)
    }

    private func setupListNavegation(vc: ListViewController) {
        vc.title = "Movies"
    }

    func setupDetailNavegation(vc: DetailViewController) {
        vc.title = ""
    }
}
