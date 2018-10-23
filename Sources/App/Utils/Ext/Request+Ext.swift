//
//  Request+Ext.swift
//  App
//
//  Created by laijihua on 2018/10/23.
//

import Foundation
import Vapor
import Fluent
import Pagination

extension Request {
    // 每页的大小
    var per: Int {
        guard let aPer = try? query.get(Int?.self, at: Pagination.defaultPerPageKey) else {
            return 10
        }
        return aPer ?? 10
    }

    // 页码
    var page: Int {
        guard let aPage = try? query.get(Int?.self, at: Pagination.defaultPageKey) else {
            return 1
        }
        return aPage ?? 1
    }

    ///
    var pageRange: Range<Int> {
        let aPage = page < 1 ? 1 : page
        let start = (aPage - 1) * per
        let end = start + per
        return start..<end
    }

    func paginated<M: Content>(data:[M], total: Int) -> Paginated<M> {
        let size = self.per
        let number = self.page
        let count = Int(ceil(Double(total) / Double(size)))
        let position = Position(
            current: number,
            next: number < count ? number + 1 : nil,
            previous: number > 1 ? number - 1 : nil,
            max: count
        )
        let pageData = PageData(
            per: size,
            total: total
        )
        let pageInfo = PageInfo(
            position: position,
            data: pageData
        )
        return Paginated(
            page: pageInfo,
            data: data
        )
    }
}
