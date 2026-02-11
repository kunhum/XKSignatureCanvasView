//
//  XKSignatureCanvasView.swift
//  XKSignatureCanvasView
//
//  Created by Kenneth Tse on 2026/2/11.
//

import UIKit

/// 一个自包含的签名组件：
/// - 内部包含画板 + 左侧「重写/确认」按钮
/// - 支持手写、清空、导出签名 UIImage
open class XKSignatureCanvasView: UIView {

    // MARK: - Public callbacks
    /// 点击「确认」时回调导出的签名图
    public var onConfirm: ((UIImage) -> Void)?
    /// 点击「重写」时回调（可选）
    public var onRewrite: (() -> Void)?
    /// 如果用户点确认但没写字
    public var onEmptyConfirm: (() -> Void)?

    // MARK: - Public config
    public var strokeColor: UIColor = .systemRed {
        didSet {
            drawingView.setNeedsDisplay()
        }
    }
    public var strokeWidth: CGFloat = 2 {
        didSet {
            drawingView.setNeedsDisplay()
        }
    }

    /// 导出是否透明背景（默认 true，更适合盖到合同/图片上）
    public var exportTransparentBackground: Bool = true

    /// 按钮文案
    public var rewriteTitle: String = "重写" {
        didSet {
            rewriteButton.setTitle(rewriteTitle, for: .normal)
        }
    }
    public var confirmTitle: String = "确认" {
        didSet {
            confirmButton.setTitle(confirmTitle, for: .normal)
        }
    }

    // MARK: - UI
    public let rewriteButton = UIButton(type: .system)
    public let confirmButton = UIButton(type: .system)
    public let buttonStack = UIStackView()
    private let drawingView = SignatureDrawingView()
    
    // MARK: - Init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bindActions()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        bindActions()
    }

    // MARK: - Public API
    func clear() {
        drawingView.clear()
    }

    func isEmpty() -> Bool {
        drawingView.isEmpty()
    }

    /// 主动导出当前签名图（不触发回调）
    func exportImage(scale: CGFloat = UIScreen.main.scale) -> UIImage {
        drawingView.exportTransparentBackground = exportTransparentBackground
        drawingView.strokeColor = strokeColor
        drawingView.strokeWidth = strokeWidth
        return drawingView.exportImage(scale: scale)
    }

    // MARK: - Private
    private func setupUI() {
        backgroundColor = .white

        // 按钮样式（贴近你截图）
        rewriteButton.setTitle(rewriteTitle, for: .normal)
        rewriteButton.setTitleColor(.systemRed, for: .normal)
        rewriteButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        rewriteButton.layer.borderWidth = 1
        rewriteButton.layer.borderColor = UIColor.systemRed.cgColor
        rewriteButton.layer.cornerRadius = 8
        rewriteButton.backgroundColor = .clear

        confirmButton.setTitle(confirmTitle, for: .normal)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        confirmButton.layer.cornerRadius = 8
        confirmButton.backgroundColor = .systemRed

        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.alignment = .fill
        buttonStack.distribution = .fillEqually
        buttonStack.addArrangedSubview(rewriteButton)
        buttonStack.addArrangedSubview(confirmButton)

        addSubview(drawingView)
        addSubview(buttonStack)

        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        drawingView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            buttonStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1),
            buttonStack.widthAnchor.constraint(equalToConstant: 180),
            buttonStack.heightAnchor.constraint(equalToConstant: 40),

            drawingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            drawingView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            drawingView.topAnchor.constraint(equalTo: topAnchor),
            drawingView.bottomAnchor.constraint(equalTo: buttonStack.topAnchor)
        ])

        // 画板默认配置
        drawingView.backgroundColor = .white
        drawingView.layer.cornerRadius = 14
        drawingView.layer.masksToBounds = true
        drawingView.strokeColor = strokeColor
        drawingView.strokeWidth = strokeWidth
        drawingView.exportTransparentBackground = exportTransparentBackground
    }

    private func bindActions() {
        rewriteButton.addTarget(self, action: #selector(tapRewrite), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(tapConfirm), for: .touchUpInside)
    }

    @objc private func tapRewrite() {
        clear()
        onRewrite?()
    }

    @objc private func tapConfirm() {
        guard isEmpty() == false else {
            onEmptyConfirm?()
            return
        }
        let image = exportImage()
        onConfirm?(image)
    }
}

// MARK: - 内部画板（仅负责绘制与导出）
open class SignatureDrawingView: UIView {

    public var strokeColor: UIColor = .systemRed
    public var strokeWidth: CGFloat = 2
    public var exportTransparentBackground: Bool = true

    private var path = UIBezierPath()
    private var lastPoint: CGPoint?
    private var hasStrokes = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        isMultipleTouchEnabled = false
        backgroundColor = .white
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
    }

    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        strokeColor.setStroke()
        path.lineWidth = strokeWidth
        path.stroke()
    }

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let p = touches.first?.location(in: self) else { return }
        lastPoint = p
        hasStrokes = true
        path.move(to: p)
        setNeedsDisplay()
    }

    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let p = touches.first?.location(in: self) else { return }
        guard let last = lastPoint else {
            lastPoint = p
            path.addLine(to: p)
            setNeedsDisplay()
            return
        }

        // 二次贝塞尔让笔迹更顺滑
        let mid = CGPoint(x: (last.x + p.x) * 0.5, y: (last.y + p.y) * 0.5)
        path.addQuadCurve(to: mid, controlPoint: last)

        lastPoint = p
        setNeedsDisplay()
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastPoint = nil
    }

    open func clear() {
        path.removeAllPoints()
        hasStrokes = false
        setNeedsDisplay()
    }

    open func isEmpty() -> Bool {
        !hasStrokes
    }

    open func exportImage(scale: CGFloat = UIScreen.main.scale) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = !exportTransparentBackground

        let renderer = UIGraphicsImageRenderer(bounds: bounds, format: format)
        return renderer.image { ctx in
            if exportTransparentBackground == false {
                UIColor.white.setFill()
                ctx.fill(bounds)
            }
            layer.render(in: ctx.cgContext)
        }
    }
}
