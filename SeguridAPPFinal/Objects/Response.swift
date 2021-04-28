//
//  Response.swift
//  SeguridAPPFinal
//
//  Created by Marcos Amaury Rodríguez Ruiz on 14/04/21.
//

import Foundation

struct Response: Decodable {
    let status: Bool
    let data: User
}
