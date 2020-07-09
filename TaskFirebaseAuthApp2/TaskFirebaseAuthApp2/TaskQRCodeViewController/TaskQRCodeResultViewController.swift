//
//  TaskQRCodeResultViewController.swift
//  TaskFirebaseAuthApp2
//
//  Created by 福島悠樹 on 2020/06/28.
//  Copyright © 2020 福島悠樹. All rights reserved.
//

import UIKit

class TaskQRCodeResultViewController: UIViewController, UserInfoDelegate {

    @IBOutlet weak var resultQRCodelabel: UILabel!
    var passResultQRCode:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        UserInfoManager.sharedInstance.delegate = self      //己をセット
        setupNavigationBar()                                //ナビゲーションバーの設定
        //UserInfoManager.sharedInstance.loadUserInfo()       //ユーザーリストを読み込み
                                                                //ユーザーリストをFirebaseから読み込み
        analizeQRCodeResult(QRCodeResult:passResultQRCode)  //QRコードの結果を表示
    }
    
    //QRCodeからの結果を判定し表示する
    func analizeQRCodeResult(QRCodeResult:String){
        //resultQRCodelabel.text = passResultQRCode
        
        for i in 0 ..< UserInfoManager.sharedInstance.getUserListsCount() {
            var idName:String = ""
            var idUserName:String = ""
            idName = UserInfoManager.sharedInstance.userLists[i].userID
            idUserName = UserInfoManager.sharedInstance.userLists[i].name
            if idName==passResultQRCode{
                resultQRCodelabel.text = idUserName
                break
            }else{
                resultQRCodelabel.text = "不明なユーザーです"
            }
        }
    }
    
    // navigation barの設定
    private func setupNavigationBar() {
        //画面上部のナビゲーションバーの左側にログアウトボタンを設置し、押されたらログアウト関数がcallされるようにする
        let leftButtonItem = UIBarButtonItem(title: "HOME", style: .done, target: self, action: #selector(homeBtn))
        navigationItem.leftBarButtonItem = leftButtonItem
    }

    // ログアウトボタンをタップしたときの動作
    @objc func homeBtn() {
        self.navigationController?.popToRootViewController(animated: true)
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
