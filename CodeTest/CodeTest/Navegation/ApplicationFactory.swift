//
//  ApplicationFactory.swift
//  CodeTest
//
//  Created by Edwin Peña on 8/10/22.
//

import UIKit

/// The ApplicationComponentsFactory takes responsibity of
/// creating application components and establishing dependencies between them.
class ApplicationFactory {    
    lazy var loadImageUseCase: LoadImageUseCaseProtocol = LoadImageUseCase(
        imageLoaderService: dataSourceProvider.imageLoader
    )

    lazy var moviesUseCase: MoviesUseCaseProtocol = MoviesUseCase(
        repository: moviesRepository
    )

    lazy var moviesRepository: MoviesRespositoryProtocol = MoviesRespository(
        networkService: dataSourceProvider.network,
        localDataSource: dataSourceProvider.coreDataManager
    )

    private let dataSourceProvider: DataSourceProvider

    init(dataSourceProvider: DataSourceProvider = DataSourceProvider.defaultProvider()) {
        self.dataSourceProvider = dataSourceProvider
    }
}
