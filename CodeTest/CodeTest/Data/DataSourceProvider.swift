//
//  DataSourceProvider.swift
//  CodeTest
//
//  Created by Edwin Peña on 1/11/22.
//

import Foundation

class DataSourceProvider {
    let network: NetworkServiceProtocol
    let coreDataManager: CoreDataManager
    let imageLoader: ImageLoaderServiceProtocol

    static func defaultProvider() -> DataSourceProvider {
        let network = NetworkService()
        let coreDataManager = CoreDataManager()
        let imageLoader = ImageLoaderService()
        return DataSourceProvider(network: network,
                                  coreDataManager: coreDataManager,
                                  imageLoader: imageLoader)
    }

    init(network: NetworkServiceProtocol,
         coreDataManager: CoreDataManager,
         imageLoader: ImageLoaderServiceProtocol) {
        self.network = network
        self.coreDataManager = coreDataManager
        self.imageLoader = imageLoader
    }
}
