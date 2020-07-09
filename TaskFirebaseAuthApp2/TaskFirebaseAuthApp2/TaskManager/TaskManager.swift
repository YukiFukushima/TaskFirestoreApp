//
//  TaskManager.swift
//  TaskFirebaseAuthApp2
//
//  Created by 福島悠樹 on 2020/06/23.
//  Copyright © 2020 福島悠樹. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

//----------------------------------------------------
//  ユーザー管理タスク
//----------------------------------------------------

class UserInfo:Codable{
    var taskId:String
    var userID:String
    var name:String
    
    var createdAt:Timestamp
    var updatedAt:Timestamp
    
    init(taskId:String, userID:String, name:String, createdAt:Timestamp, updatedAt:Timestamp){
        self.taskId = taskId
        self.userID = userID
        self.name = name
        
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

protocol UserInfoDelegate:class{
    /* NoAction */
}

class UserInfoManager{
    static let sharedInstance = UserInfoManager()
    
    var userLists:[UserInfo] = [UserInfo(taskId:"", userID:"", name:"", createdAt:Timestamp(date:Date()), updatedAt:Timestamp(date:Date()))]
    
    weak var delegate:UserInfoDelegate?
    
    /* ユーザーリストの数を取得 */
    func getUserListsCount() -> Int{
        return self.userLists.count
    }
    
    /* ユーザーリストに追加 */
    func appendUserLists(userInfo:UserInfo){
        self.userLists.append(userInfo)
    }
    
    /* 現在のユーザーIDを見つけて名前を入れる */
    func setNameAtCurrentUserID(name:String){
        for i in 0 ..< UserInfoManager.sharedInstance.getUserListsCount() {
            if UserInfoManager.sharedInstance.userLists[i].userID==String(describing:Auth.auth().currentUser?.uid){
                
                UserInfoManager.sharedInstance.userLists[i].name = name
            }
        }
    }
    
    /* 現在のユーザーIDの名前を返す */
    func getNameAtCurrentUserID()->String{
        var currentName:String = ""
        
        for i in 0 ..< UserInfoManager.sharedInstance.getUserListsCount() {
            if UserInfoManager.sharedInstance.userLists[i].userID==String(describing:Auth.auth().currentUser?.uid){
                
                currentName = UserInfoManager.sharedInstance.userLists[i].name
            }
        }
        return currentName
    }
    
    /* 現在のユーザーのTaskIDを返す */
    func getTaskIdAtCurrentUserID()->String{
        var currentTaskId:String = ""
        
        for i in 0 ..< UserInfoManager.sharedInstance.getUserListsCount() {
            if UserInfoManager.sharedInstance.userLists[i].userID==String(describing:Auth.auth().currentUser?.uid){
                
                currentTaskId = UserInfoManager.sharedInstance.userLists[i].taskId
            }
        }
        return currentTaskId
    }
    
    /* 現在のユーザーの生成日(createdAt)を返す */
    func getCreatedAtAtCurrentUserID()->Timestamp{
        var currentCreatedAt:Timestamp = Timestamp(date:Date())
        
        for i in 0 ..< UserInfoManager.sharedInstance.getUserListsCount() {
            if UserInfoManager.sharedInstance.userLists[i].userID==String(describing:Auth.auth().currentUser?.uid){
                
                currentCreatedAt = UserInfoManager.sharedInstance.userLists[i].createdAt
            }
        }
        return currentCreatedAt
    }
    
    /* 現在のユーザーの更新日(updatedAt)を返す */
    func getUpdatedAtAtCurrentUserID()->Timestamp{
        var currentUpdatedAt:Timestamp = Timestamp(date:Date())
        
        for i in 0 ..< UserInfoManager.sharedInstance.getUserListsCount() {
            if UserInfoManager.sharedInstance.userLists[i].userID==String(describing:Auth.auth().currentUser?.uid){
                
                currentUpdatedAt = UserInfoManager.sharedInstance.userLists[i].updatedAt
            }
        }
        return currentUpdatedAt
    }
    
    /* 現在のユーザーのクラスの実体を返す */
    func getUserInfoAtCurrentUserID()->UserInfo{
        var currentListNum:Int = 0
        
        for i in 0 ..< UserInfoManager.sharedInstance.getUserListsCount() {
            if UserInfoManager.sharedInstance.userLists[i].userID==String(describing:Auth.auth().currentUser?.uid){
                currentListNum = i
            }
        }
        return UserInfoManager.sharedInstance.userLists[currentListNum]
    }
    
    /*
    /* ユーザーリストを保存 */
    func saveUserInfo(){
        UserInfoRepository.saveUserInfoUserDefaults(userInfo:userLists)
    }
    
    /* ユーザーリストを読込 */
    func loadUserInfo(){
        self.userLists = UserInfoRepository.loadUserInfoUserDefaults()
    }
    */
}

//----------------------------------------------------
//  グループ管理タスク
//----------------------------------------------------
class GroupInfo:Codable{
    var taskId:String
    var groupName:String
    var groupMemberNames:[String]
    var groupMemberTalks:[String]
    
    var createdAt:Timestamp
    var updatedAt:Timestamp
    
    init(taskId:String, groupName:String, groupMemberNames:[String], groupMemberTalks:[String], createdAt:Timestamp, updatedAt:Timestamp){
        self.taskId = taskId
        self.groupName = groupName
        self.groupMemberNames = groupMemberNames
        self.groupMemberTalks = groupMemberTalks
        
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

protocol GroupInfoDelegate:class{
    /* NoAction */
}

class GroupInfoManager{
    static let sharedInstance = GroupInfoManager()
    
    var groupInfo:[GroupInfo] = [GroupInfo(taskId:"", groupName:"", groupMemberNames:[""], groupMemberTalks:[""], createdAt:Timestamp(date:Date()), updatedAt:Timestamp(date:Date()))]
    weak var delegate:GroupInfoDelegate?
    
    /* グループリストの数を取得 */
    func getGroupInfoCount() -> Int{
        return self.groupInfo.count
    }
    
    /* 指定したグループを取得 */
    func getGroupInfo(num:Int)->GroupInfo{
        return self.groupInfo[num]
    }
    
    /* グループを追加 */
    func appendGroupInfo(groupInfo:GroupInfo){
        self.groupInfo.append(groupInfo)
    }
    
    /* 指定したグループのメッセージを追加 */
    func appendGroupInfoTalks(num:Int, message:String){
        self.groupInfo[num].groupMemberTalks.append(message)
    }
    
    /* グループを削除 */
    func removeGroupInfo(num:Int){
        self.groupInfo.remove(at: num)
    }
    
    /*
    /* グループリストを保存 */
    func saveGroupInfo(){
        GroupInfoRepository.saveGroupInfoUserDefaults(groupInfo:groupInfo)
    }
    
    /* グループリストを読込 */
    func loadGroupInfo(){
        self.groupInfo = GroupInfoRepository.loadGroupInfoUserDefaults()
    }
    */
}
