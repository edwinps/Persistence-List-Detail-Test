//
//  ApplicationFactoryTest.swift
//  CodeTestTests
//
//  Created by Edwin Peña on 9/10/22.
//

import Foundation
@testable import CodeTest

class ApplicationFactoryMock: ApplicationFactory {
    override var loadImageUseCase: LoadImageUseCaseProtocol {
       get { return LoadImageUseCaseMock() }
       set { super.loadImageUseCase = newValue }
   }

    override var moviesUseCase: MoviesUseCaseProtocol {
       get { return moviesUseCaseMock() }
       set { super.moviesUseCase = newValue }
   }

    override var moviesRepository: MoviesRespositoryProtocol {
       get { return RepositoryMock() }
       set { super.moviesRepository = newValue }
   }
}
