import Foundation

extension Bundle {
    static var framework: Bundle {
#if SWIFT_PACKAGE
        return Bundle.module
#else
        class Class {}
        return Bundle(for: Class.self)
#endif
    }

    static var frameworkVersion: String {
        let semVerPattern = #"^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$"#
        let regex = try! NSRegularExpression(pattern: semVerPattern)
        let matches = regex.matches(
            in: yooteam_lib_version,
            range: NSRange(location: 0, length: (yooteam_lib_version as NSString).length)
        )
        if matches.count == 0 {
            fatalError(#"Unable to parse version string "# + yooteam_lib_version)
        }

        return yooteam_lib_version
    }
}
