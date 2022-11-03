//
//  CoreDataManager.swift
//  CodeTest
//
//  Created by Edwin Peña on 1/11/22.
//

import Foundation
import Combine
import CoreData

protocol CoreDataManagerProtocol {
    func fetchAllMovies() -> AnyPublisher<[CDMovie], Never>
    func addOrRemove(_ movie: Movie) -> AnyPublisher<Result<Void, Error>, Never>
    var container: NSPersistentContainer { get set }
}

class CoreDataManager: CoreDataManagerProtocol {
    var container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Model")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            print("CoreData \(String(describing: storeDescription.url))")
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        )
    }

    func fetchAllMovies() -> AnyPublisher<[CDMovie], Never> {
        let fetchRequest: NSFetchRequest<CDMovie> = CDMovie.fetchRequest()
        let result = (try? container.viewContext.fetch(fetchRequest)) ?? []
        return .just(result)
    }

    func addOrRemove(_ movie: Movie) -> AnyPublisher<Result<Void, Error>, Never> {
        let context = container.viewContext

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CDMovie")
        let predicate = NSPredicate(format: "%K == %@", "id", movie.id)
        fetchRequest.predicate = predicate

        let result = try? context.fetch(fetchRequest)
        if let items = result, !items.isEmpty {
            // remove movie from core data
            for object in items {
                context.delete(object)
            }
        } else {
            // Add new movie to core data
            let cdMovie = CDMovie(context: context)
            cdMovie.set(from: movie)
        }
        do {
            try context.save()
            print("movie saved!!")
            return .just(.success(()))
        } catch {
            print("Error saving!!")
            return .just(.failure(MoviesError.errorSaving))
        }
    }
}
