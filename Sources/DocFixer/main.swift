//
//  main.swift
//  DocFixer
//
//  Created by Galen Rhodes on 7/23/21.
//

import Foundation
import PGDocFixer

DispatchQueue.main.async {
    let mAndR: [RegexRepl] = []
    exit(Int32(doDocFixer(args: CommandLine.arguments, replacements: mAndR)))
}
dispatchMain()
