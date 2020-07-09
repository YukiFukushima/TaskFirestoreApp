//
//  TaskGroupViewController.swift
//  TaskFirebaseAuthApp2
//
//  Created by 福島悠樹 on 2020/06/23.
//  Copyright © 2020 福島悠樹. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class TaskGroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GroupInfoDelegate {

    @IBOutlet weak var taskGroupTableView: UITableView!
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskGroupTableView.delegate = self
        taskGroupTableView.dataSource = self
        GroupInfoManager.sharedInstance.delegate = self
        configureTableViewCell()
        
        // Do any additional setup after loading the view.
        
        //タイトルを変更
        self.title = "Talk"
    }
    
    /* TableViewCellを読み込む(登録する)関数 */
    func configureTableViewCell(){
        /* nibを作成*/
        let nib = UINib(nibName: "TaskGroupTableViewCell", bundle: nil)
        
        
        /* ID */
        let cellID = "GroupTableViewCell"
        
        /* 登録 */
        taskGroupTableView.register(nib, forCellReuseIdentifier: cellID)
    }
    
    /* cellの個数 */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GroupInfoManager.sharedInstance.getGroupInfoCount()
    }
    
    /* cellの高さ */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    /* cellに表示する内容 */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupTableViewCell", for: indexPath)as!TaskGroupTableViewCell
        
        cell.groupImageView.image = UIImage(named: "SpongeBob")
        cell.groupLabel.text = GroupInfoManager.sharedInstance.getGroupInfo(num: indexPath.row).groupName
        
        return cell
    }
    
    /* 再描画 */
    override func viewWillAppear(_ animated: Bool) {
        restoreDataFromFirestore()  //自デバイスでグループを作って戻ってきた時のため
        //observeRealTimeFirestore()  //他デバイスへの更新のため
    }
    
    /* Firestoreからデータを配列に読み込んで再更新(グループを作って戻ってきた時とグループを削除した時のため) */
    func restoreDataFromFirestore(){
        GroupInfoManager.sharedInstance.groupInfo.removeAll()   //配列を全削除
        readGroupInfoFromFirestore()                            //会話グループ情報の読み込み
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
                
                //再描画
                self.taskGroupTableView.reloadData()
            }
        }
    }
    
    /* Firestoreからの削除関数 */
    func deleteTaskFromFirestore(indexPath:Int){
        db.collection("Groups").document(GroupInfoManager.sharedInstance.getGroupInfo(num: indexPath).taskId).delete()
    }
    
    /* スワイプ処理(削除) */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.deleteTaskFromFirestore(indexPath:indexPath.row)                  //Firebaseから削除
        GroupInfoManager.sharedInstance.removeGroupInfo(num: indexPath.row)     //配列から削除
        
        //再描画
        restoreDataFromFirestore()
    }
    
    /* タップ時処理 */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = TaskGroupDetailViewController()
        vc.groupNumber = indexPath.row
        navigationController?.pushViewController(vc, animated: true)
        //let vc = TaskDetailViewController()
        //vc.selectIndex = indexPath.row
        //vc.tasks = tasks
        //navigationController?.pushViewController(vc, animated: true)
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
