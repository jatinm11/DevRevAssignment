//
//  Cast.swift
//  DevRevAssignment
//
//  Created by Jatin Menghani on 13/02/24.
//

import Foundation

struct Cast: Codable {
    let name: String
    let profilePath: String?
}

struct CastResponse: Codable {
    let id: Int
    let cast: [Cast]
}
