#!/usr/bin/swift

// NOTE: Should be run directly from containing directory.

import Foundation

func scriptDirectory() -> String {
    let script = Process.arguments[0] as NSString
    assert(script.hasSuffix(".swift"), "Unable to find directory of the script.")
    return script.stringByDeletingLastPathComponent
}

extension NSMutableData {
    func appendString(string: String) {
        guard let dataFromString = string.dataUsingEncoding(NSUTF8StringEncoding) else {
            return
        }
        appendData(dataFromString)
    }
}

let locale = NSLocale(localeIdentifier: "en_US")
let regex = "\\W+"

guard let expr = try? NSRegularExpression(pattern: regex, options: []) else {
    preconditionFailure("Couldn't initialize expression with given pattern")
}

let simulatorLanguagesPath = "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk/System/Library/PrivateFrameworks/IntlPreferences.framework/Language.strings"

guard let languagesDictionary = NSDictionary(contentsOfFile: simulatorLanguagesPath) as? [String: String] else {
    preconditionFailure("Couldn't load languages from Simulator")
}

var data = NSMutableData()
data.appendString("// swiftlint:disable type_body_length\n")
data.appendString("\n/// Enumeration describing available languages in the system.\n")
data.appendString("public enum SystemLanguage: String, LaunchArgumentValue {\n")

for identifier in languagesDictionary.keys {
    guard let displayName = locale.displayNameForKey(NSLocaleIdentifier, value: identifier) else {
        continue
    }
    let range = NSRange(location: 0, length: displayName.characters.count)
    var caseName = expr.stringByReplacingMatchesInString(displayName, options: [], range: range, withTemplate: "")
    data.appendString("\n\t/// Automatically generated value for language \(caseName).\n")
    data.appendString("\tcase \(caseName) = \"\(identifier)\"\n")
}

data.appendString("}\n")

let fileManager = NSFileManager()
let path = scriptDirectory() + "/../AutoMate/Models/SystemLanguage.swift"
let created = fileManager.createFileAtPath(path, contents: data, attributes: nil)

print("Created on path: \(path) - \(created)")