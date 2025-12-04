package thx.semver;

/**
 * Represents a SemVer identifier segment (numeric or alphanumeric).
 */
enum Identifier {
    Numeric(v:Int);
    Alpha(v:String);
}
