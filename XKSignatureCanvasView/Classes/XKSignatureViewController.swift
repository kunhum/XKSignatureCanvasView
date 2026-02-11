//
//  XKSignatureViewController.swift
//  XKSignatureCanvasView
//
//  Created by Kenneth Tse on 2026/2/11.
//

import Foundation

open class XKSignatureViewController: UIViewController {

    private let signatureView = XKSignatureCanvasView()

    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        view.addSubview(signatureView)
        signatureView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            signatureView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            signatureView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            signatureView.topAnchor.constraint(equalTo: view.topAnchor),
            signatureView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - 横屏控制（关键）
    /// 只支持横屏
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    /// 弹出后立刻旋转
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }

    /// 禁止自动旋转回竖屏
    open override var shouldAutorotate: Bool {
        return true
    }
}
