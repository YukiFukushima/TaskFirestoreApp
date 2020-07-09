//
//  TaskEditUserInfoViewController.swift
//  TaskFirebaseAuthApp2
//
//  Created by 福島悠樹 on 2020/06/24.
//  Copyright © 2020 福島悠樹. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class TaskEditUserInfoViewController: UIViewController, UserInfoDelegate, UITextFieldDelegate {

    @IBOutlet weak var renameTextView: UITextField!
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserInfoManager.sharedInstance.delegate = self
        renameTextView.delegate = self
        // Do any additional setup after loading the view.
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
    
    @IBAction func backToSaveBtn(_ sender: Any) {
        //名前を保存
        guard let reName = renameTextView.text else{ return }
        
        if reName.isEmpty{
            showAlert( title:"エラー", message:"名前を入力して下さい" )
        }else{
            //名前を保存
            UserInfoManager.sharedInstance.setNameAtCurrentUserID(name: reName)
            
            //Firestoreに保存
            do{
                //Firestoreに保存出来るように変換する
                let encodeUserInfo:[String:Any] = try Firestore.Encoder().encode(UserInfoManager.sharedInstance.getUserInfoAtCurrentUserID())
                
                //Firestoreに書き込み
                db.collection("Users").document(UserInfoManager.sharedInstance.getTaskIdAtCurrentUserID()).setData(encodeUserInfo)
                
            }catch let error as NSError{
                print("エラー\(error)")
            }
            
            
            //HOME画面に遷移
            navigationController?.popViewController(animated: true)
            //self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    /* textに答えを入力した時にキーボードを消す(textFieldのprotocolに用意されているメソッド) */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    /* タッチした時にキーボードを消す(UIViewControllerに用意されているメソッド) */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
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
