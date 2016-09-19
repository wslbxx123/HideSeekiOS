//
//  RaceGroup.swift
//  HideSeek
//
//  Created by apple on 7/4/16.
//  Copyright © 2016 mj. All rights reserved.
//

class RaceGroup {
    var recordId: Int64
    var nickname: String
    var photoUrl: String?
    var smallPhotoUrl: String?
    var remark: String?
    var recordItem: RecordItem
    
    init(recordId: Int64, nickname: String, photoUrl: String?, smallPhotoUrl: String?,
         remark: String?, recordItem: RecordItem) {
        self.recordId = recordId
        self.nickname = nickname
        self.photoUrl = photoUrl
        self.smallPhotoUrl = smallPhotoUrl
        self.remark = remark
        self.recordItem = recordItem
    }
}
