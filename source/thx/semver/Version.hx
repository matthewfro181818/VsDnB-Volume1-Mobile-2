package thx.semver;

using StringTools;

import thx.semver.VersionRule;
typedef SemVer = {
    version:Array<Int>,
    pre:Array<Identifier>,
    build:Array<Identifier>
};

abstract Version(SemVer) from SemVer to SemVer {

    static var VERSION = ~/^(\d+)\.(\d+)\.(\d+)(?:-([A-Za-z0-9.-]+))?(?:\+([A-Za-z0-9.-]+))?$/;

    // --------------------------------------------------
    // CONSTRUCTORS
    // --------------------------------------------------

    @:from
    public static function fromString(s:String):Version {
        if (!VERSION.match(s))
            throw 'Invalid SemVer format: "$s"';

        var major = Std.parseInt(VERSION.matched(1));
        var minor = Std.parseInt(VERSION.matched(2));
        var patch = Std.parseInt(VERSION.matched(3));
        var pre   = parseIdentifiers(VERSION.matched(4));
        var build = parseIdentifiers(VERSION.matched(5));

        return new Version(major, minor, patch, pre, build);
    }

    @:from
    public static function fromArray(a:Array<Int>):Version {
        if (a == null) a = [];
        a = a.map(v -> v < 0 ? -v : v);
        while (a.length < 3) a.push(0);
        return new Version(a[0], a[1], a[2], [], []);
    }

    inline function new(major:Int, minor:Int, patch:Int, pre:Array<Identifier>, build:Array<Identifier>) {
        this = {
            version: [major, minor, patch],
            pre: pre,
            build: build
        };
    }

    // --------------------------------------------------
    // PROPERTIES
    // --------------------------------------------------

    public var major(get, never):Int;
    inline function get_major() return this.version[0];

    public var minor(get, never):Int;
    inline function get_minor() return this.version[1];

    public var patch(get, never):Int;
    inline function get_patch() return this.version[2];

    public var pre(get, never):String;
    inline function get_pre() return identifiersToString(this.pre);

    public var hasPre(get, never):Bool;
    inline function get_hasPre() return this.pre.length > 0;

    public var build(get, never):String;
    inline function get_build() return identifiersToString(this.build);

    public var hasBuild(get, never):Bool;
    inline function get_hasBuild() return this.build.length > 0;

    // --------------------------------------------------
    // COMPARISON API
    // --------------------------------------------------

    @:op(A == B)
    public function equals(other:Version):Bool {
        if (major != other.major) return false;
        if (minor != other.minor) return false;
        if (patch != other.patch) return false;
        return equalsIdentifiers(this.pre, (other:SemVer).pre);
    }

    @:op(A != B)
    public function notEquals(other:Version):Bool {
        return !equals(other);
    }

    @:op(A > B)
    public function greaterThan(other:Version):Bool {
        if (major != other.major) return major > other.major;
        if (minor != other.minor) return minor > other.minor;
        if (patch != other.patch) return patch > other.patch;

        // Both have pre-release tags → compare them
        return greaterThanIdentifiers(this.pre, (other:SemVer).pre);
    }

    @:op(A >= B)
    public function greaterThanOrEqual(other:Version):Bool {
        return equals(other) || greaterThan(other);
    }

    @:op(A < B)
    public function lessThan(other:Version):Bool {
        return !greaterThanOrEqual(other);
    }

    @:op(A <= B)
    public function lessThanOrEqual(other:Version):Bool {
        return equals(other) || lessThan(other);
    }

    // --------------------------------------------------
    // NEXT VERSIONS
    // --------------------------------------------------

    public function nextMajor():Version
        return new Version(major + 1, 0, 0, [], []);

    public function nextMinor():Version
        return new Version(major, minor + 1, 0, [], []);

    public function nextPatch():Version
        return new Version(major, minor, patch + 1, [], []);

    // --------------------------------------------------
    // TEXT
    // --------------------------------------------------

    @:to
    public function toString():String {
        var v = this.version.join(".");
        if (this.pre.length > 0)
            v += "-" + identifiersToString(this.pre);
        if (this.build.length > 0)
            v += "+" + identifiersToString(this.build);
        return v;
    }

    // --------------------------------------------------
    // IDENTIFIER UTILITIES
    // --------------------------------------------------

    static function identifiersToString(ids:Array<Identifier>):String {
        return ids.map(id -> switch(id) {
            case StringId(s): s;
            case IntId(i): '$i';
        }).join(".");
    }

    static function parseIdentifiers(raw:String):Array<Identifier> {
        if (raw == null || raw.length == 0) return [];
        return raw.split(".")
            .map(sanitize)
            .filter(s -> s.length > 0)
            .map(parseIdentifier);
    }

    static function sanitize(s:String):String {
        var reg = ~/[^0-9A-Za-z-]/g;
        return reg.replace(s, "");
    }

    static function parseIdentifier(s:String):Identifier {
        var i = Std.parseInt(s);
        return (i == null) ? StringId(s) : IntId(i);
    }

    static function equalsIdentifiers(a:Array<Identifier>, b:Array<Identifier>):Bool {
        if (a.length != b.length) return false;
        for (i in 0...a.length)
            switch [a[i], b[i]] {
                case [StringId(x), StringId(y)] if (x != y): return false;
                case [IntId(x), IntId(y)] if (x != y): return false;
                default:
            }
        return true;
    }

    static function greaterThanIdentifiers(a:Array<Identifier>, b:Array<Identifier>):Bool {
        var len = Math.min(a.length, b.length);
        for (i in 0...len)
            switch [a[i], b[i]] {
                case [IntId(x), IntId(y)]:
                    if (x != y) return x > y;
                case [StringId(x), StringId(y)]:
                    if (x != y) return x > y;
                case [IntId(_), StringId(_)]: return true;
                case [StringId(_), IntId(_)]: return false;
                default:
            }
        return a.length > b.length;
    }
}
