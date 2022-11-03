//
//  DetailViewController.swift
//  CodeTest
//
//  Created by Edwin Peña on 8/10/22.
//

import UIKit
import Combine

final class DetailViewController: UIViewController {
    @IBOutlet private var movieImage: UIImageView!
    @IBOutlet private var movieTitle: UILabel!
    @IBOutlet private var rating: UILabel!
    @IBOutlet private var type: UILabel!
    @IBOutlet private var content: UILabel!
    private var viewModel: DetailViewModel
    private var disposables = Set<AnyCancellable>()
    private let appear = PassthroughSubject<Void, Never>()

    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appear.send(())
    }
}

// MARK: - Inner methods

private extension DetailViewController {
    func bindViewModel() {
        let input = DetailViewModel
            .Input(willAppear: appear.eraseToAnyPublisher())
        let output = viewModel.transform(input: input)

        output.detailState
            .sink(receiveValue: { [weak self] state in
                self?.render(state)
            }).store(in: &disposables)
    }

    func render(_ state: DetailState) {
        switch state {
        case .failure:
            break
        case .success(let movie):
            movieTitle.text = movie.title
            content.text = movie.summary
            rating.text = movie.rating
            type.text = movie.type
            title = movie.title
            movie.imageData
                .map { UIImage(data: $0 ?? Data()) }
                .assign(to: \.image, on: self.movieImage)
                .store(in: &disposables)
        }
    }
}
