//
//  Subject+Populate.swift
//  App
//
//  Created by laijihua on 2018/10/17.
//

import Vapor
import FluentPostgreSQL

final class PopulateSubjectForms: Migration {
    typealias Database = PostgreSQLDatabase
    static let subjects = [
        "全部": [
            "公告",
            "Swift",
            "iOS",
            "其它"
        ]
    ]

    static func getHeadId(on connection: PostgreSQLConnection, title: String) -> Future<Subject.ID> {
        let subject = Subject(parentId: 0, name: title, path: "0")
        return subject.create(on: connection).map { subj in
            return subj.id!
        }
    }

    static func createSubSubject(headId: Subject.ID, title: String, conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        let subs = subjects[title] ?? []
        let subfutures = subs.compactMap{ item in
            return Subject(parentId: headId, name: item, path: "\(headId)").create(on: conn).map(to: Void.self, {_ in return})
        }
        return Future<Void>.andAll(subfutures, eventLoop: conn.eventLoop)
    }

    static func searchSubjectId(title: String, conn: PostgreSQLConnection) -> Future<Subject.ID> {
        return Subject.query(on: conn)
            .filter(\Subject.name == title)
            .first()
            .unwrap(or: FluentError(identifier: "PopulateSubjectForms_noSuchHeat", reason: "PopulateSubjectForms_noSuchHeat"))
            .map {return $0.id!}
    }

    static func deleteSubjects(on conn: PostgreSQLConnection, name: String, subSubjects:[String]) -> EventLoopFuture<Void> {
        return searchSubjectId(title: name, conn: conn).flatMap(to: Void.self, { headid  in
            let futures = subSubjects.map { name in
                return Subject.query(on: conn).filter(\Subject.name == name).delete()
            }
            return Future<Void>.andAll(futures, eventLoop: conn.eventLoop)
        })
    }

    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        let keys = subjects.keys
        let futrues = keys.map { title -> EventLoopFuture<Void> in
            let future = getHeadId(on: conn, title: title)
                .flatMap { headId -> EventLoopFuture<Void> in
                    return createSubSubject(headId: headId, title: title, conn: conn)
            }
            return future
        }
        return Future<Void>.andAll(futrues, eventLoop: conn.eventLoop)
    }

    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        let futures = subjects.map { arg -> EventLoopFuture<Void> in
            let (name, touples) = arg
            let allFut = deleteSubjects(on: conn, name: name, subSubjects: touples).always {
                _ = Subject.query(on: conn).filter(\Subject.name == name).delete()
            }
            return allFut
        }
        return Future<Void>.andAll(futures, eventLoop: conn.eventLoop)
    }

}
