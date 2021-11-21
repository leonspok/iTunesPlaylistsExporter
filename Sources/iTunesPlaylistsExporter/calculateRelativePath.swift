//
//  File.swift
//  
//
//  Created by Igor Savelev on 21.11.2021.
//

import Foundation

func calculateRelativePath(targetURL: URL, baseURL: URL) -> String {
    let targetAbsoluteURL = targetURL.absoluteURL.standardizedFileURL
    let targetComponents = targetAbsoluteURL.pathComponents

    let baseAbsoluteURL = baseURL.absoluteURL.standardizedFileURL
    let baseComponents = baseAbsoluteURL.pathComponents

    let commonPathComponentsCount = targetComponents.enumerated().first(where: { index, pathComponent in
        guard index < baseComponents.count else { return true }
        return baseComponents[index] != pathComponent
    })?.offset ?? targetComponents.count

    if commonPathComponentsCount == targetComponents.count {
        return "."
    }

    let components = Array(repeating: "..", count: baseComponents.count - commonPathComponentsCount) +
        targetComponents[commonPathComponentsCount...]
    return components.joined(separator: "/")
}
