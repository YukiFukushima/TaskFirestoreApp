//
//  TaskLoginViewController.swift
//  TaskFirebaseAuthApp2
//
//  Created by 福島悠樹 on 2020/06/23.
//  Copyright © 2020 福島悠樹. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class TaskLoginViewController: UIViewController, UserInfoDelegate, UITextFieldDelegate {

    @IBOutlet weak var emailTextView: UITextField!
    @IBOutlet weak var passwordTextView: UITextField!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        UserInfoManager.sharedInstance.delegate = self  //己にセット
        emailTextView.delegate = self
        passwordTextView.delegate = self
        passwordTextView.isSecureTextEntry = true       //pw非表示
        
        /* ForDebug *
        print("deleteCount2 : ")
        print(UserInfoManager.sharedInstance.getUserListsCount())
        * ForDebugEnd */
    }
    
    //View再表示時のアクション関数
    override func viewWillAppear(_ animated: Bool) {
        //readUserInfoFromFirestore()
    }
    
    //成功時の画面遷移処理
    func presentTaskHomeViewController(){
        self.dismiss(animated: true, completion: nil)
    }
    
    //アラート表示関数
    func showAlert( title:String, message:String? ){
        //UIAlertControllerを関数の引数であるとtitleとmessageを使ってインスタンス化
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        //UIAlertActionを追加
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        //表示
        self.present(alertVC, animated: true, completion: nil)
    }
    
    //Firestoreからのデータの読み込み
    func readUserInfoFromFirestore(){
        db.collection("Users").order(by: "createdAt", descending: true).getDocuments { (querySnapShot, err) in
            if let err = err{
                print("エラー:\(err)")
                self.showAlert(title: "読み込みに失敗しました", message: "アプリを立ち上げ直してください")
            }else{
                /* ForDebug
                var i:Int = 0
                * ForDebugEnd */
                
                //取得したDocument群の1つ1つのDocumentについて処理をする
                for document in querySnapShot!.documents{
                    //各DocumentからはDocumentIDとその中身のdataを取得できる
                    print("\(document.documentID) => \(document.data())")
                    //型をUserInfo型に変換
                    do {
                        let decodedTask = try Firestore.Decoder().decode(UserInfo.self, from: document.data())
                        //変換に成功
                        UserInfoManager.sharedInstance.appendUserLists(userInfo: decodedTask)
                        
                        /* ForDebug
                        print("taskId:")
                        print(UserInfoManager.sharedInstance.userLists[i].taskId)
                        print("userID:")
                        print(UserInfoManager.sharedInstance.userLists[i].userID)
                        print("name:")
                        print(UserInfoManager.sharedInstance.userLists[i].name)
                        print("createdAt:")
                        print(UserInfoManager.sharedInstance.userLists[i].createdAt)
                        print("updatedAt:")
                        print(UserInfoManager.sharedInstance.userLists[i].updatedAt)
                        i += 1
                        * ForDebugEnd */
                        
                    } catch let error as NSError{
                        print("エラー:\(error)")
                        self.showAlert(title: "読み込みに失敗しました", message: "アプリを立ち上げ直してください")
                    }
                }
                //Firestoreから読み出し後、新規ユーザーか既存ユーザーかをチェック
                self.checkExistingUser()
            }
        }
    }
    
    //新規登録の際のエラー表示
    func newRegisterErrAlert(error:NSError){
        //引数errorのもつコードを使って、EnumであるAuthErrorCodeを読み出し
        if let errCode = AuthErrorCode(rawValue: error.code){
            var message = ""
            
            switch errCode {
            case .invalidEmail:
                message = "有効なメッセージを入力して下さい"
            case .emailAlreadyInUse:
                message = "既に登録されているEmailアドレスです"
            case .weakPassword:
                message = "パスワードは6文字以上で入力してください"
                
            default:
                message = "エラー：\(error.localizedDescription)"
            }
            
            //アラート表示
            self.showAlert(title: "登録できませんでした", message: message)
        }
    }
    
    //ログインの際のエラー表示
    func logInErrAlert(error:NSError){
        //引数errorのもつコードを使って、EnumであるAuthErrorCodeを読み出し
        if let errCode = AuthErrorCode(rawValue: error.code){
            var message = ""
            
            switch errCode {
            case .userNotFound:
                message = "アカウントが見つかりませんでした"
            case .wrongPassword:
                message = "パスワードを確認してください"
            case .userDisabled:
                message = "アカウントが無効になっています"
            case .invalidEmail:
                message = "Emailが無効な形式です"
            default:
                message = "エラー：\(error.localizedDescription)"
            }
            
            //アラート表示
            self.showAlert(title: "ログインできませんでした", message: message)
        }
    }
    
    //新規登録処理
    func emailNewRegister(email:String, password:String){
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error as NSError?{
                //エラー時の処理
                self.newRegisterErrAlert(error:error)
            }
            else{
                //成功時の処理
                self.actSuccessLogin()
            }
        }
    }
    
    //ログイン処理
    func emailLogin(email:String, password:String){
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error as NSError?{
                //エラー時の処理
                self.logInErrAlert(error:error)
            }
            else{
                //成功時の処理
                self.actSuccessLogin()
            }
        }
    }
    
    //ログイン時の警告表示共通関数
    func commonAlert(email:String, password:String)->Bool{
        var result:Bool = false
        
        if email.isEmpty && password.isEmpty{
            self.showAlert(title:"エラー", message: "メールアドレスとパスワードを入力してください")
        }
        else if email.isEmpty{
            self.showAlert(title:"エラー", message: "メールアドレスを入力してください")
        }
        else if password.isEmpty{
            self.showAlert(title:"エラー", message: "パスワードを入力してください")
        }
        else{
            result = true
        }
        
        return result
    }
    
    //リストへの追加処理関数
    func addUserInfo(){
        //新しくタスクIDを取得
        let taskId = db.collection("Users").document().documentID
        
        //新しい情報(taskId, userID, ..)で、クラスを実体化
        let userInfo = UserInfo(taskId:taskId,userID:String(describing:Auth.auth().currentUser?.uid), name:"", createdAt:Timestamp(), updatedAt:Timestamp())
        
        //Firestoreに保存
        do{
            //Firestoreに保存出来るように変換する
            let encodeUserInfo:[String:Any] = try Firestore.Encoder().encode(userInfo)
            
            //保存
            db.collection("Users").document(taskId).setData(encodeUserInfo)
            
            //リスト(配列)に追加
            UserInfoManager.sharedInstance.appendUserLists(userInfo:userInfo)
            
        }catch let error as NSError{
            print("エラー\(error)")
            self.showAlert(title:"エラー", message: "データの読み込みに失敗しました")
        }
    }
    
    //既存ユーザーチェック関数
    func checkExistingUser(){
        if UserInfoManager.sharedInstance.getUserListsCount()==0{               //ユーザーリストが空なら追加
            //リストに追加
            addUserInfo()
        }else{                                                                  //ユーザーリストに何かあるなら
            var isExistUser:Bool = false                                        //ユーザー判定フラグ(最初、ユーザーは未登録から開始)
            for i in 0 ..< UserInfoManager.sharedInstance.getUserListsCount() { //ユーザーリストをチェック
                /* ForDebug *
                print("UserInfoUserID:")
                print(UserInfoManager.sharedInstance.userLists[i].userID)
                print("FirebaseUserID:")
                print(String(describing:Auth.auth().currentUser?.uid))
                * ForDebugEnd */
                
                if UserInfoManager.sharedInstance.userLists[i].userID==String(describing:Auth.auth().currentUser?.uid){
                    isExistUser = true  //ユーザーは登録済み
                    break
                }
            }
            
            if isExistUser==false{      //ユーザーが未登録なら
                //リストに追加
                addUserInfo()
            }
        }
        
        //Home画面表示
        self.presentTaskHomeViewController()
    }
    
    //成功時の処理
    func actSuccessLogin(){
        UserInfoManager.sharedInstance.userLists.removeAll()                    //配列をクリア
        readUserInfoFromFirestore()                                             //Firebaseから読み込み
        
        /*
        if UserInfoManager.sharedInstance.getUserListsCount()==0{               //ユーザーリストが空なら追加
            //リストに追加
            addUserInfo()
        }else{                                                                  //ユーザーリストに何かあるなら
            var isExistUser:Bool = false                                        //ユーザー判定フラグ(最初、ユーザーは未登録から開始)
            for i in 0 ..< UserInfoManager.sharedInstance.getUserListsCount() { //ユーザーリストをチェック
                /* ForDebug *
                print("UserInfoUserID:")
                print(UserInfoManager.sharedInstance.userLists[i].userID)
                print("FirebaseUserID:")
                print(String(describing:Auth.auth().currentUser?.uid))
                * ForDebugEnd */
                
                if UserInfoManager.sharedInstance.userLists[i].userID==String(describing:Auth.auth().currentUser?.uid){
                    isExistUser = true  //ユーザーは登録済み
                    break
                }
            }
            
            if isExistUser==false{      //ユーザーが未登録なら
                //リストに追加
                addUserInfo()
            }
        }
        
        //Home画面表示
        self.presentTaskHomeViewController()
        */
    }
    
    /* textに答えを入力した時にキーボードを消す(textFieldのprotocolに用意されているメソッド) */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    /* タッチした時にキーボードを消す(UIViewControllerに用意されているメソッド) */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //ログインボタン押下時関数
    @IBAction func tappedLoginBtn(_ sender: Any) {
        guard let email = emailTextView.text, let password = passwordTextView.text else{return}
        
        if commonAlert(email:email, password:password)==true {
            //ログイン処理
            self.emailLogin(email: email, password: password)
        }
    }
    
    //新規登録ボタン押下時関数
    @IBAction func tappedNewRegisterBtn(_ sender: Any) {
        guard let email = emailTextView.text, let password = passwordTextView.text else{return}
        
        if commonAlert(email:email, password:password)==true {
            //新規登録処理
            self.emailNewRegister(email: email, password: password)
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
