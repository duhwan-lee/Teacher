//
//  TeacherModel.swift
//  Teacher
//
//  Created by doohwan Lee on 2017. 2. 6..
//  Copyright © 2017년 doohwan Lee. All rights reserved.
//

import Foundation


class Teacher {
    var name : String?
    var mail : String?
    var photoUrl : String?
    var uid : String?
}

class Question : NSObject{
    var answerCount : Int?
    var readCount : Int?
    var questionPic : String?
    var questionText : String?
    var writerUid : String?
    var writerName : String?
    var contentNumber : String?
}
class Message: NSObject{
    var text : String?
    var time : Int?
    var toUid : String?
    var fromUiD : String?
}
class Channel : NSObject {
    var channel_name : String?
    var uid : String?
    var name : String?
    var text : String?
    var time : String?
    var image : String?
}
class Answer : NSObject {
    var text : String?
    var type : String?
}
class sendValue {
    let text = "text"
    let time = "timeStamp"
    let toUid = "toUid"
    let fromUid = "fromUid"
}

struct Section {
    var count: Int!
    var items: [String]!
    var collapsed: Bool!
    
    init(count: Int, items: [String], collapsed: Bool = false) {
        self.count = count
        self.items = items
        self.collapsed = collapsed
    }
}

let tc_category_dic = ["tc_all" : "전체", "tc_h1_m" : "고1 수학", "tc_h2_m": "고2 수학", "tc_h3_m" : "고3 수학"," tc_h_e": "수능영어"]
let tc_category = ["전체", "고1 수학", "고2 수학", "고3 수학","수능영어"]
