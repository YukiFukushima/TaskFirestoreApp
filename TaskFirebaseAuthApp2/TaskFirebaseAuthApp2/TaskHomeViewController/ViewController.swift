//
//  ViewController.swift
//  TaskFirebaseAuthApp2
//
//  Created by 福島悠樹 on 2020/06/23.
//  Copyright © 2020 福島悠樹. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class ViewController: UIViewController, UserInfoDelegate {
    
    @IBOutlet weak var nameTextField: UITextView!
    @IBOutlet weak var nameImageView: UIImageView!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        UserInfoManager.sharedInstance.delegate = self      //己をセット
        setupNavigationBar()                                //ナビゲーションバーの設定
        
        //ログインチェック
        if self.isLogin() == false{
            // ログインビューコントローラを表示
            self.presentLoginViewController()
        }
        
        //配列を全削除
        UserInfoManager.sharedInstance.userLists.removeAll()
        GroupInfoManager.sharedInstance.groupInfo.removeAll()
        
        //dataをFirestoreから読み込み
        self.loadFromFirestore()
    }
    
    // 名前の表示関数
    func viewName(){
        let currentUserName = UserInfoManager.sharedInstance.getNameAtCurrentUserID()
        print("!!!")
        print(currentUserName)
        if currentUserName==""{
            self.nameTextField.text = "名前"
        }else{
            self.nameTextField.text = currentUserName
        }
    }
    
    // //名前画像の表示関数
    func viewNameImage(){
        nameImageView.image = UIImage(named: "SpongeBob")
    }
    
    //Firestoreから全データを読み込み(最初だけ)
    func loadFromFirestore(){
        readUserInfoFromFirestore()     //ユーザー情報の読み込み
        readGroupInfoFromFirestore()    //会話グループ情報の読み込み
    }
    
    //Firestoreからのデータ(会話グループ情報)の読み込み
    func readGroupInfoFromFirestore(){
        
        db.collection("Groups").order(by: "taskId", descending: true).getDocuments { (querySnapShot, err) in
            if let err = err{
                print("エラー:\(err)")
            }else{
                //取得したDocument群の1つ1つのDocumentについて処理をする
                for document in querySnapShot!.documents{
                    //各DocumentからはDocumentIDとその中身のdataを取得できる
                    print("\(document.documentID) => \(document.data())")
                    //型をUserInfo型に変換([String:Any]型で記録する為、変換が必要)
                    do {
                        let decodedTask = try Firestore.Decoder().decode(GroupInfo.self, from: document.data())
                        //変換に成功
                        GroupInfoManager.sharedInstance.appendGroupInfo(groupInfo: decodedTask)
                    } catch let error as NSError{
                        print("エラー:\(error)")
                    }
                }
            }
        }
    }
    
    //Firestoreからのデータ(ユーザー情報)の読み込み
    func readUserInfoFromFirestore(){
        db.collection("Users").order(by: "taskId", descending: true).getDocuments { (querySnapShot, err) in
            if let err = err{
                print("エラー:\(err)")
            }else{
                //取得したDocument群の1つ1つのDocumentについて処理をする
                for document in querySnapShot!.documents{
                    //各DocumentからはDocumentIDとその中身のdataを取得できる
                    print("\(document.documentID) => \(document.data())")
                    //型をUserInfo型に変換
                    do {
                        let decodedTask = try Firestore.Decoder().decode(UserInfo.self, from: document.data())
                        //変換に成功
                        UserInfoManager.sharedInstance.appendUserLists(userInfo: decodedTask)
                    } catch let error as NSError{
                        print("エラー:\(error)")
                    }
                }
                
                //名前の表示
                self.viewName()
                
                //名前画像の表示
                self.viewNameImage()
            }
        }
    }
    
    //再描画時処理
    override func viewWillAppear(_ animated: Bool) {
        //名前の表示
        self.viewName()
        
        //名前画像の表示
        self.viewNameImage()
    }
    
    //ログイン画面の表示関数
    func presentLoginViewController(){
        let loginVC = TaskLoginViewController()
        
        //モーダルスタイルを指定
        loginVC.modalPresentationStyle = .fullScreen
        
        //表示
        self.present(loginVC, animated: true, completion: nil)
    }
    
    //ログイン認証されているかどうかの判定関数
    func isLogin() -> Bool{
        //ログインしているユーザーがいるかどうかを判別
        if Auth.auth().currentUser != nil{
            return true
        }else{
            return false
        }
    }
    
    // navigation barの設定
    private func setupNavigationBar() {
        //右に+ボタンを配置
        let rightButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showMakeGroupView))
        navigationItem.rightBarButtonItem = rightButtonItem
        
        //画面上部のナビゲーションバーの左側にログアウトボタンを設置し、押されたらログアウト関数がcallされるようにする
        let leftButtonItem = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(logout))
        navigationItem.leftBarButtonItem = leftButtonItem
        
        //タイトルを変更
        self.title = "HOME"
    }
    
    // +ボタンをタップしたときの動作
    @objc func showMakeGroupView() {
        let vc = TaskMakeTableViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // ログアウトボタンをタップしたときの動作
    @objc func logout() {
        do{
            try Auth.auth().signOut()
            
            //ログアウトに成功したら、ログイン画面を表示
            self.presentLoginViewController()
            
        }catch let signOutError as NSError{
            print("サインアウトエラー:\(signOutError)")
        }
    }
    
    //名前の編集を押下時の処理を記載
    @IBAction func tappedRenameBtn(_ sender: Any) {
        let vc = TaskEditUserInfoViewController()
        navigationController?.pushViewController(vc, animated: true)
        //self.present(vc, animated: true, completion: nil)
    }
    
    //QRCodeボタン押下時関数
    @IBAction func tappedQRCodeBtn(_ sender: Any) {
        /* ForDebug*
        // UserDefaultsのオールクリア
        let appDomain = Bundle.main.bundleIdentifier
        UserDefaults.standard.removePersistentDomain(forName: appDomain!)
        GroupInfoManager.sharedInstance.saveGroupInfo()
        * EndForDebug */
        
        /* ForDebug *
        // Firestoreのオールクリア
        print("deleteCount : ")
        print(UserInfoManager.sharedInstance.getUserListsCount())
        for i in 0 ..< UserInfoManager.sharedInstance.getUserListsCount() {
            let taskId = UserInfoManager.sharedInstance.userLists[i].taskId
            let userId = UserInfoManager.sharedInstance.userLists[i].userID
            
            print("delete : ")
            print(taskId)
            print("delete2 : ")
            print(userId)
            
            db.collection("Users").document(taskId).delete()
        }
        * EndForDebug */
        
        let vc = TaskQRCodeViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //QRCode読み取りボタン押下時関数
    @IBAction func tappedReadQRCodeBtn(_ sender: Any) {
        let vc = ReadQRCodeViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

