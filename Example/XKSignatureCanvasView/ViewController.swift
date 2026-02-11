//
//  ViewController.swift
//  XKSignatureCanvasView
//
//  Created by kunhum on 02/11/2026.
//  Copyright (c) 2026 kunhum. All rights reserved.
//

import UIKit
import XKSignatureCanvasView

class ViewController: UIViewController {
    
    let sigView = XKSignatureCanvasView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        sigView.onConfirm = { image in
//            // image = 签名图（默认透明背景）
//            print(image.size)
//        }
//        sigView.onEmptyConfirm = { [weak self] in
//            let alert = UIAlertController(title: nil, message: "请先签名", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "知道了", style: .default))
//            self?.present(alert, animated: true)
//        }
//        view.addSubview(sigView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let vc = XKSignatureViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

}

