//
//  ReadQRCodeViewController.swift
//  TaskFirebaseAuthApp2
//
//  Created by 福島悠樹 on 2020/06/28.
//  Copyright © 2020 福島悠樹. All rights reserved.
//

import UIKit
import AVFoundation

class ReadQRCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    // カメラやマイクの入出力を管理するオブジェクトを生成
    let session = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // カメラやマイクのデバイスオブジェクトを生成
        let devices:[AVCaptureDevice] = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices
        
        //　該当するデバイスのうち最初に取得したもの(背面カメラ)を利用する
        if let backCamera = devices.first {
            do {
                // QRコードの読み取りに背面カメラの映像を利用するための設定
                let deviceInput = try AVCaptureDeviceInput(device: backCamera)
                
                let myBoundSize: CGSize = UIScreen.self.main.bounds.size
                let width = myBoundSize.width
                let height = myBoundSize.height
                
                if self.session.canAddInput(deviceInput) {
                    self.session.addInput(deviceInput)

                    // 背面カメラの映像からQRコードを検出するための設定
                    let metadataOutput = AVCaptureMetadataOutput()

                    if self.session.canAddOutput(metadataOutput) {
                        self.session.addOutput(metadataOutput)

                        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                        metadataOutput.metadataObjectTypes = [.qr]

                        // 背面カメラの映像を画面に表示するためのレイヤーを生成
                        let previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
                        
                        previewLayer.frame = self.view.bounds
                        previewLayer.videoGravity = .resizeAspectFill
                        previewLayer.position = CGPoint(x: width/2, y: height/2)
                        self.view.layer.addSublayer(previewLayer)

                        // 読み取り開始
                        self.session.startRunning()
                    }
                }
            } catch {
                print("Error occured while creating video device input: \(error)")
            }
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        for metadata in metadataObjects as! [AVMetadataMachineReadableCodeObject] {
            // QRコードのデータかどうかの確認
            if metadata.type != .qr {
                continue
            }

            // QRコードの内容が空かどうかの確認
            if metadata.stringValue == nil {
                continue
            }

            // ここでQRコードから取得したデータで何らかの処理を行う
            // 取得したデータは「metadata.stringValue」で使用できる
            print("結果：")
            print("metadata.stringValue")
            
            guard let result=metadata.stringValue else{ return }
            let vc = TaskQRCodeResultViewController()
            vc.passResultQRCode = result
            navigationController?.pushViewController(vc, animated: true)
            //self.present(vc, animated: true, completion: nil)
            self.session.stopRunning()
            break
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
