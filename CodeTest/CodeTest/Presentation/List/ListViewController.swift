//
//  ListViewController.swift
//  CodeTest
//
//  Created by Edwin Peña on 8/10/22.
//

import UIKit
import Combine

final class ListViewController: UIViewController {
    @IBOutlet private var loading: UIActivityIndicatorView!
    @IBOutlet private var tableView: UITableView!
    private var disposables = Set<AnyCancellable>()
    private lazy var dataSource = makeDataSource()
    private let didLoad = PassthroughSubject<Void, Never>()
    private let selection = PassthroughSubject<MovieViewModel, Never>()
    private var viewModel: ListViewModel
    private lazy var alertViewController = AlertViewController(nibName: nil, bundle: nil)
    private let searchController = UISearchController(searchResultsController: nil)
    private var addOrRemoveFavorites = PassthroughSubject<MovieViewModel, Never>()

    init(viewModel: ListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        bindViewModel()
        didLoad.send(())
    }
}

// MARK: - Inner methods

private extension ListViewController {
    enum Section: CaseIterable {
        case movies
    }

    func setupLayout() {
        tableView.tableFooterView = UIView()
        tableView.registerNib(cellClass: MovieCell.self)
        tableView.dataSource = dataSource
        alertViewController.view.isHidden = true
        add(alertViewController)
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        navigationController?
            .navigationBar
            .accessibilityIdentifier = "ListViewController"
    }

    func bindViewModel() {
        let input = ListViewModel
            .Input(didLoad: didLoad.eraseToAnyPublisher(),
                   selection: selection.eraseToAnyPublisher(),
                   search: searchController.textPublisher,
                   addFavorites: addOrRemoveFavorites.eraseToAnyPublisher())
        let output = viewModel.transform(input: input)

        output.addOrRemoveFavorites
            .sink(receiveValue: { [weak self] success in
                if !success { self?.failureAlert() }
            }).store(in: &disposables)

        output.listState
            .sink(receiveValue: { [weak self] state in
                self?.render(state)
            }).store(in: &disposables)

        output.isLoading
            .sink(receiveValue: { [weak self] isLoading in
                if isLoading {
                    self?.loading.startAnimating()
                } else {
                    self?.loading.stopAnimating()
                }
            }).store(in: &disposables)
    }

    func render(_ state: ListState) {
        switch state {
        case .noResults:
            alertViewController.view.isHidden = false
            alertViewController.showNoResults()
            loading.stopAnimating()
            update(with: [], animate: true)
        case .failure:
            failureAlert()
        case .success(let movies):
            alertViewController.view.isHidden = true
            loading.stopAnimating()
            update(with: movies, animate: true)
        }
    }

    func failureAlert() {
        alertViewController.view.isHidden = false
        alertViewController.showDataLoadingError()
        loading.stopAnimating()
        update(with: [], animate: true)
    }

    func makeDataSource() -> UITableViewDiffableDataSource<Section, MovieViewModel> {
        return UITableViewDiffableDataSource(
            tableView: tableView,
            cellProvider: { tableView, indexPath, viewModel in
                guard let cell = tableView.dequeueReusableCell(withClass: MovieCell.self) else {
                    assertionFailure("Failed to dequeue \(MovieCell.self)!")
                    return UITableViewCell()
                }
                cell.bind(to: viewModel)
                cell.favorites
                    .sink(receiveValue: { [weak self]  _ in
                        self?.addOrRemoveFavorites.send(viewModel)
                    }).store(in: &cell.disposables)
                return cell
            }
        )
    }

    func update(with movies: [MovieViewModel], animate: Bool = true) {
        DispatchQueue.main.async {
            var snapshot = NSDiffableDataSourceSnapshot<Section, MovieViewModel>()
            snapshot.appendSections(Section.allCases)
            snapshot.appendItems(movies, toSection: .movies)
            self.dataSource.apply(snapshot, animatingDifferences: animate)
        }
    }
}

extension ListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let snapshot = dataSource.snapshot()
        selection.send(snapshot.itemIdentifiers[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
