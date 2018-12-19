//
//  Tag.swift
//  App
//
//  Created by laijihua on 2018/12/18.
//

import Vapor
import FluentPostgreSQL

struct Tag:Content {
    var id: Int?
    var name: String
}

extension Tag: PostgreSQLModel {}
extension Tag: Migration {}
