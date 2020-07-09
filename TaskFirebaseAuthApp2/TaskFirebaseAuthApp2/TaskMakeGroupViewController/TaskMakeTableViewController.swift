//
//  TaskMakeTableViewController.swift
//  TaskFirebaseAuthApp2
//
//  Created by 福島悠樹 on 2020/06/24.
//  Copyright © 2020 福島悠樹. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class TaskMakeTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, GroupInfoDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var groupNameLabel: UITextField!
    @IBOutlet weak var makeGroupTableView: UITableView!
    let db = Firestore.firestore()
    var groupMemberCandidate:[String] = [
        "お父さん", /* 0 */
        "お母さん", /* 1 */
        "遼太朗",  /* 2 */
        "おじいちゃん",  /* 3 */
        "おばあちゃん",  /* 4 */
        "義理のおじいちゃん",  /* 5 */
        "義理のおばあちゃん",  /* 6 */
    ]
    var groupCandidate = GroupInfo(taskId:"", groupName:"", groupMemberNames:[], groupMemberTalks:[], createdAt:Timestamp(date:Date()), updatedAt:Timestamp(date:Date()))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        makeGroupTableView.delegate = self
        makeGroupTableView.dataSource = self
        GroupInfoManager.sharedInstance.delegate = self
        groupNameLabel.delegate = self
        configureTableViewCell()
        
        /* ForDebug *
        for i in 0 ..< GroupInfoManager.sharedInstance.getGroupInfoCount() {
            let groupDebug:GroupInfo = GroupInfoManager.sharedInstance.getGroupInfo(num: i)
            let groupNameDebug:String = groupDebug.groupName
            let groupMemberDebug:[String] = groupDebug.groupMemberNames
            
            print("グループ名"+groupNameDebug)
            for j in 0 ..< groupMemberDebug.count {
                let groupMemberDetail = groupMemberDebug[j]
                print(groupMemberDetail)
            }
        }
        * EndForDebug */
        
        //タイトルを変更
        self.title = "グループ作成"
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    /* TableViewCellを読み込む(登録する)関数 */
    func configureTableViewCell(){
        /* nibを作成*/
        let nib = UINib(nibName: "MakeGroupTableViewCell", bundle: nil)
        
        
        /* ID */
        let cellID = "MakeGroupTableView"
        
        /* 登録 */
        makeGroupTableView.register(nib, forCellReuseIdentifier: cellID)
    }
    
    /* cellの個数 */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupMemberCandidate.count
    }
    
    /* cellに表示する内容 */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MakeGroupTableView", for: indexPath)as!MakeGroupTableViewCell
        
        /* タップした時にハイライトを消す */
        cell.selectionStyle = .none
        
        /* タップ検知のためisUserInteractionEnabledをtrueに */
        cell.checkImage.isUserInteractionEnabled = true
        
        /* タップ時処理で使用するためrowをtagに持たせておく */
        cell.checkImage.tag = indexPath.row
        
        /* タップ時イベント設定 */
        cell.checkImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(checkBoxIconViewTapped)))
        
        /* Viewの名前を表示 */
        cell.memberCandidateName.text = groupMemberCandidate[indexPath.row]
        
        /* グループメンバーの候補者だけ文字をグリーンにする */
        cell.memberCandidateName.textColor = .darkGray
        //cell.checkImage.image = UIImage(named: "BeforeCheckBox")
        cell.checkImage.image = UIImage(named: "NoCheckBox")
        for i in 0 ..< groupCandidate.groupMemberNames.count {
            if groupCandidate.groupMemberNames[i]==groupMemberCandidate[indexPath.row]{
                cell.memberCandidateName.textColor = .green
                cell.checkImage.image = UIImage(named: "CheckBox")
            }
        }
        
        return cell
    }
    
    /* チェックボックスアイコンがクリックされた時にCallされる関数 */
    @objc func checkBoxIconViewTapped(sender:UITapGestureRecognizer){
        guard let inputRow=sender.view?.tag else {return}
        
        if groupCandidate.groupMemberNames.count==0{                                        // リストが空なら
            groupCandidate.groupMemberNames.append(groupMemberCandidate[inputRow])
        }else{
            for i in 0 ..< groupCandidate.groupMemberNames.count {
                if groupMemberCandidate[inputRow]==groupCandidate.groupMemberNames[i]{      // 既にリストにある場合
                    groupCandidate.groupMemberNames.remove(at: i)
                    break
                }else if i==groupCandidate.groupMemberNames.count-1{                        // リストの最後までなかった場合
                    groupCandidate.groupMemberNames.append(groupMemberCandidate[inputRow])
                }
            }
        }
        
        //再描画
        makeGroupTableView.reloadData()
        
        /* ForDebug *
        for i in 0 ..< groupCandidate.groupMemberNames.count {
            let nameDebug:String = groupCandidate.groupMemberNames[i]
           print(nameDebug)
        }
        * EndForDebug */
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
    
    /* textに答えを入力した時にキーボードを消す(textFieldのprotocolに用意されているメソッド) */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    /* タッチした時にキーボードを消す(UIViewControllerに用意されているメソッド) */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //Firestoreに保存する関数
    func saveGroupToFirestore(groupName:String){
        //新しくタスクIDを取得
        let taskId = db.collection("Groups").document().documentID
        
        groupCandidate.taskId = taskId              //taskID格納
        groupCandidate.createdAt = Timestamp()      //作成日格納
        groupCandidate.updatedAt = Timestamp()      //更新日格納
        groupCandidate.groupName = groupName        //名前格納
        
        //Firestoreに保存
        do{
            //Firestoreに保存出来るように変換する
            let encodeGroupInfo:[String:Any] = try Firestore.Encoder().encode(groupCandidate)
            
            //Firestore保存
            db.collection("Groups").document(taskId).setData(encodeGroupInfo)
            
            //グループを追加
            GroupInfoManager.sharedInstance.appendGroupInfo(groupInfo: groupCandidate)
            
            //HOME画面に遷移
            navigationController?.popViewController(animated: true)
            
        }catch let error as NSError{
            print("エラー\(error)")
            self.showAlert(title:"エラー", message: "データの読み込みに失敗しました")
        }
    }
    
    //グループ作成ボタン
    @IBAction func makeGroupBtn(_ sender: Any) {
        guard let groupName=groupNameLabel.text else{ return }
        
        if groupName.isEmpty{
            self.showAlert(title:"エラー", message: "グループ名を入力してください")
        }else if groupCandidate.groupMemberNames.count==0{
            self.showAlert(title:"エラー", message: "メンバーを選んでください")
        }else{
            //グループをFirebaseに保存
            self.saveGroupToFirestore(groupName:groupName)
        }
        
        /* ForDebug *
        for i in 0 ..< GroupInfoManager.sharedInstance.getGroupInfoCount() {
            let groupDebug:GroupInfo = GroupInfoManager.sharedInstance.getGroupInfo(num: i)
            let groupNameDebug:String = groupDebug.groupName
            let groupMemberDebug:[String] = groupDebug.groupMemberNames
            
            print("グループ名"+groupNameDebug)
            for j in 0 ..< groupMemberDebug.count {
                let groupMemberDetail = groupMemberDebug[j]
                print(groupMemberDetail)
            }
        }
        * EndForDebug */
    }
}
