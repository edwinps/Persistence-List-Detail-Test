//
//  MovieCell.swift
//  CodeTest
//
//  Created by Edwin Peña on 8/10/22.
//

import UIKit
import Combine

class MovieCell: UITableViewCell, NibProvidable, ReusableView  {
    @IBOutlet private var title: UILabel!
    @IBOutlet private var summary: UILabel!
    @IBOutlet private var rating: UILabel!
    @IBOutlet private var imageMovie: UIImageView!
    @IBOutlet private var favorite: UIButton!
    private var isFavorite = false
    var favorites: AnyPublisher<Void, Never> {
        return favoritesSubject.eraseToAnyPublisher()
    }
    private let favoritesSubject = PassthroughSubject<Void, Never>()
    var disposables = Set<AnyCancellable>()
    var cancellable: AnyCancellable?

    override func prepareForReuse() {
        super.prepareForReuse()
        cancelImageLoading()
        disposables.removeAll()
    }

    func bind(to viewModel: MovieViewModel) {
        cancelImageLoading()
        title.text = viewModel.title
        summary.text = viewModel.summary
        rating.text = viewModel.rating
        favorityChange(added: viewModel.favorite)
        cancellable = viewModel.imageData
            .sink { [weak self] data in
                self?.showImage(image: UIImage(data: data ?? Data()))
            }
    }

    @IBAction func favoritesPressed() {
        favoritesSubject.send(())
        favorityChange(added: !isFavorite)
    }
}

// MARK: - Inner methods

private extension MovieCell {
    func showImage(image: UIImage?) {
        cancelImageLoading()
        UIView.transition(with: self.imageMovie,
        duration: 0.3,
        options: [.curveEaseOut, .transitionCrossDissolve],
        animations: {
            self.imageMovie.image = image
        })
    }

    func cancelImageLoading() {
        imageMovie.image = nil
        cancellable?.cancel()
    }

    func favorityChange(added: Bool) {
        isFavorite = added
        let image = isFavorite ? UIImage(named: "star_filled") : UIImage(named: "star_empty")
        favorite.setImage(image, for: .normal)
    }
}
