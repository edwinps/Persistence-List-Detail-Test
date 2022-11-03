//
//  UISearchTextField+Publisher.swift
//  CodeTest
//
//  Created by Edwin Peña on 1/11/22.
//


import UIKit
import Combine

extension UISearchController {
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(
            for: UISearchTextField.textDidChangeNotification,
            object: self.searchBar.searchTextField
        )
        .compactMap { ($0.object as? UITextField)?.text }
        .eraseToAnyPublisher()
    }
}
