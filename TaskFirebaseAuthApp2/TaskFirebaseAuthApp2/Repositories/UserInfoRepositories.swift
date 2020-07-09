//
//  UserInfoRepositories.swift
//  TaskFirebaseAuthApp2
//
//  Created by 福島悠樹 on 2020/06/23.
//  Copyright © 2020 福島悠樹. All rights reserved.
//

import Foundation

/*
//ユーザー情報の記憶用
class UserInfoRepository {
    // UserDefaults に使うキー
    static let userInfoSelectsKey:String = "user_info"

    static func saveUserInfoUserDefaults(userInfo:[UserInfo]){
        //Data型に変換処理
        let encorder = JSONEncoder()
        let data = try! encorder.encode(userInfo)
        
        //UserDefaultsに保存
        UserDefaults.standard.set(data, forKey: userInfoSelectsKey)
        
    }

    static func loadUserInfoUserDefaults()->[UserInfo]{
        let decorder = JSONDecoder()
        
        //UserDefaultsから読み出し
        guard let data = UserDefaults.standard.data(forKey: userInfoSelectsKey)else{ return [] }
        
        //dataから[UserInfo]に変換
        let userInfo = try! decorder.decode([UserInfo].self, from: data)
        
        return userInfo
    }
}

//グループ情報の記憶用
class GroupInfoRepository {
    // UserDefaults に使うキー
    static let groupInfoSelectsKey:String = "group_info"

    static func saveGroupInfoUserDefaults(groupInfo:[GroupInfo]){
        //Data型に変換処理
        let encorder = JSONEncoder()
        let data = try! encorder.encode(groupInfo)
        
        //UserDefaultsに保存
        UserDefaults.standard.set(data, forKey: groupInfoSelectsKey)
        
    }

    static func loadGroupInfoUserDefaults()->[GroupInfo]{
        let decorder = JSONDecoder()
        
        //UserDefaultsから読み出し
        guard let data = UserDefaults.standard.data(forKey: groupInfoSelectsKey)else{ return [] }
        
        //dataから[UserInfo]に変換
        let groupInfo = try! decorder.decode([GroupInfo].self, from: data)
        
        return groupInfo
    }
}
*/

