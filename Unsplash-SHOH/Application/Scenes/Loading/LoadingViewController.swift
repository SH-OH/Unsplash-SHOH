//
//  LoadingViewController.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/24.
//

import Foundation
import UIKit

final class LoadingViewController: BaseViewController {
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator: UIActivityIndicatorView = .init(style: .whiteLarge)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(activityIndicator)
        layout()
    }
    
    private func layout() {
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func control(show: Bool, useLoading: Bool) {
        guard useLoading else { return }
        DispatchQueue.main.async {
            if self.activityIndicator.isAnimating != show {
                self.view.isHidden = !show
                UIApplication.shared.isNetworkActivityIndicatorVisible = show
                show
                    ? self.activityIndicator.startAnimating()
                    : self.activityIndicator.stopAnimating()
            }
        }
    }
    
}
