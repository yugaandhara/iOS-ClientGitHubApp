//
//  Repository.swift
//  ClientGitHubApp
//
//  Created by Yugandhara Bodhekar on 12/04/23.
//

import Foundation

struct Repository: Decodable {
    let id: Int
    let name: String
    let description: String?
    let isPrivate: Bool
    let createdAt: Date
    let updatedAt: Date
    let language: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, isPrivate = "private", createdAt = "created_at", updatedAt = "updated_at", language
    }
}
