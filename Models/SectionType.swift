//  SectionType.swift
//  Hookline
//  Created by Pulkit Jain on 15/4/2025.
import Foundation

enum SectionType: String, CaseIterable, Identifiable, Codable {
    case verse, chorus, bridge, intro, outro
    var id: String { rawValue }
}
