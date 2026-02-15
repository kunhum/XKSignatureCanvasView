//
//  XKSignatureViewController.swift
//  XKSignatureCanvasView
//
//  Created by Kenneth Tse on 2026/2/11.
//

import Foundation

open class XKSignatureViewController: UIViewController {
    
    /// 点击「确认」时回调导出的签名图
    public var onConfirm: ((UIImage) -> Void)?
    /// 点击「重写」时回调（可选）
    public var onRewrite: (() -> Void)?
    /// 如果用户点确认但没写字
    public var onEmptyConfirm: (() -> Void)?
    
    public let signatureView = XKSignatureCanvasView()

    // MARK: - 横屏控制
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
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindData()
    }
    
    func setupUI() {
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
    
    func bindData() {
        signatureView
            .onConfirm = {
                [weak self] image in
                self?.onConfirm?(image)
            }
        
        signatureView
            .onRewrite = {
                [weak self] in
                self?.onRewrite?()
            }
        
        signatureView
            .onEmptyConfirm = {
                [weak self] in
                self?.onEmptyConfirm?()
            }
    }
}
