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
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        view.addSubview(activityIndicator)
        layout()
    }
    
    private func layout() {
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func control(parentViewController: UIViewController?,
                 show: Bool,
                 useLoading: Bool) {
        guard let parentViewController = parentViewController else {
            return
        }
        DispatchQueue.main.async {
            show
                ? self.attach(parentViewController)
                : self.dettach(parentViewController)
            if self.activityIndicator.isAnimating != show {
                self.view.isHidden = !show
                UIApplication.shared.isNetworkActivityIndicatorVisible = show
                show
                    ? self.activityIndicator.startAnimating()
                    : self.activityIndicator.stopAnimating()
            }
        }
    }
    
    private func attach(_ parentViewController: UIViewController) {
        if !parentViewController.children.contains(self) {
            parentViewController.addChild(self)
            parentViewController.view.addSubview(self.view)
            NSLayoutConstraint.activate([
                self.view.topAnchor.constraint(equalTo: parentViewController.view.topAnchor),
                self.view.leadingAnchor.constraint(equalTo: parentViewController.view.leadingAnchor),
                self.view.trailingAnchor.constraint(equalTo: parentViewController.view.trailingAnchor),
                self.view.bottomAnchor.constraint(equalTo: parentViewController.view.bottomAnchor)
            ])
        }
    }
    
    private func dettach(_ parentViewController: UIViewController) {
        if parentViewController.children.contains(self) {
            parentViewController.willMove(toParent: nil)
            parentViewController.removeFromParent()
        }
    }
}
