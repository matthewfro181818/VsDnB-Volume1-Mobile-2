package thx.semver;

using thx.semver.Version;
using StringTools;

import thx.semver.Identifier;

abstract VersionRule(VersionComparator) from VersionComparator to VersionComparator {

    @:from
    public static function fromString(s:String):VersionRule {
        var parts = s.split("||").map(p -> p.trim());
        var rules:Array<VersionComparator> = [];

        for (segment in parts) {
            var rule = parseRange(segment);
            rules.push(rule);
        }

        // Collapse into OR structure
        var result:VersionComparator = rules.shift();
        for (r in rules)
            result = OrRule(result, r);

        return result;
    }

    // -----------------------------------------------------
    // RANGE PARSER
    // -----------------------------------------------------

    static function parseRange(s:String):VersionComparator {
        // Hyphen range: "1.0.0 - 2.0.0"
        var hy = s.split(" - ");
        if (hy.length == 2)
            return hyphenRange(hy[0], hy[1]);

        // Space-separated comparators: ">=1.0.0 <2.0.0"
        var tokens = s.split(" ").filter(t -> t.trim() != "");
        if (tokens.length > 1)
            return multiComparator(tokens);

        // Single comparator
        return singleComparator(s);
    }

    static function hyphenRange(a:String, b:String):VersionComparator {
        var v1 = parseVersionOrWildcard(a);
        var v2 = parseVersionOrWildcard(b);

        return AndRule(
            GreaterThanOrEqualVersion(v1),
            LessThanOrEqualVersion(v2)
        );
    }

    static function multiComparator(tokens:Array<String>):VersionComparator {
        var cmp:VersionComparator = null;

        for (t in tokens) {
            var r = singleComparator(t);
            if (cmp == null) cmp = r else cmp = AndRule(cmp, r);
        }

        return cmp;
    }

    // -----------------------------------------------------
    // SINGLE COMPARATOR
    // -----------------------------------------------------

    static function singleComparator(s:String):VersionComparator {
        s = s.trim();

        if (s.startsWith(">="))
            return GreaterThanOrEqualVersion(parseVersionOrWildcard(s.substr(2)));
        if (s.startsWith("<="))
            return LessThanOrEqualVersion(parseVersionOrWildcard(s.substr(2)));
        if (s.startsWith(">"))
            return GreaterThanVersion(parseVersionOrWildcard(s.substr(1)));
        if (s.startsWith("<"))
            return LessThanVersion(parseVersionOrWildcard(s.substr(1)));
        if (s.startsWith("="))
            return EqualVersion(parseVersionOrWildcard(s.substr(1)));

        if (s.startsWith("^"))
            return caretRange(parseVersionOrWildcard(s.substr(1)));

        if (s.startsWith("~"))
            return tildeRange(parseVersionOrWildcard(s.substr(1)));

        return wildcardOrExact(s);
    }

    // -----------------------------------------------------
    // WILDCARD / EXACT
    // -----------------------------------------------------

    static function wildcardOrExact(s:String):VersionComparator {
        var parts = s.split(".");
        while (parts.length < 3) parts.push("0");

        if (parts.contains("x") || parts.contains("*"))
            return wildcardRange(parts);

        // Exact match
        return EqualVersion(Version.fromString(s));
    }

    static function wildcardRange(parts:Array<String>):VersionComparator {
        var major = parts[0];
        var minor = parts[1];

        if (major == "x" || major == "*")
            return GreaterThanOrEqualVersion(Version.fromArray([0,0,0]));

        var majorNum = Std.parseInt(major);

        if (minor == "x" || minor == "*")
            return AndRule(
                GreaterThanOrEqualVersion(Version.fromArray([majorNum,0,0])),
                LessThanVersion(Version.fromArray([majorNum+1,0,0]))
            );

        var minorNum = Std.parseInt(minor);

        return AndRule(
            GreaterThanOrEqualVersion(Version.fromArray([majorNum,minorNum,0])),
            LessThanVersion(Version.fromArray([majorNum,minorNum+1,0]))
        );
    }

    // -----------------------------------------------------
    // SPECIAL RANGES
    // -----------------------------------------------------

    static function caretRange(v:Version):VersionComparator {
        if (v.major > 0)
            return AndRule(GreaterThanOrEqualVersion(v), LessThanVersion(v.nextMajor()));

        if (v.minor > 0)
            return AndRule(GreaterThanOrEqualVersion(v), LessThanVersion(v.nextMinor()));

        return AndRule(GreaterThanOrEqualVersion(v), LessThanVersion(v.nextPatch()));
    }

    static function tildeRange(v:Version):VersionComparator {
        return AndRule(GreaterThanOrEqualVersion(v), LessThanVersion(v.nextMinor()));
    }

    // -----------------------------------------------------
    // HELPERS
    // -----------------------------------------------------

    static function parseVersionOrWildcard(s:String):Version {
        s = s.trim();
        if (s == "" || s == "*" || s == "x")
            return Version.fromArray([0,0,0]);
        return Version.fromString(s);
    }

    // -----------------------------------------------------
    // RUNTIME EVALUATION
    // -----------------------------------------------------

    public function isSatisfiedBy(ver:Version):Bool {
        switch (this:VersionComparator) {
            case EqualVersion(v): return ver == v;
            case GreaterThanVersion(v): return ver > v;
            case GreaterThanOrEqualVersion(v): return ver >= v;
            case LessThanVersion(v): return ver < v;
            case LessThanOrEqualVersion(v): return ver <= v;
            case AndRule(a,b): return (a:VersionRule).isSatisfiedBy(ver) && (b:VersionRule).isSatisfiedBy(ver);
            case OrRule(a,b): return (a:VersionRule).isSatisfiedBy(ver) || (b:VersionRule).isSatisfiedBy(ver);
        }
    }

    // -----------------------------------------------------
    // STRING OUTPUT
    // -----------------------------------------------------

    @:to public function toString():String {
        return switch (this:VersionComparator) {
            case EqualVersion(v): '$v';
            case GreaterThanVersion(v): '>$v';
            case GreaterThanOrEqualVersion(v): '>=$v';
            case LessThanVersion(v): '<$v';
            case LessThanOrEqualVersion(v): '<=$v';
            case AndRule(a,b): '${(a:VersionRule)} ${(b:VersionRule)}';
            case OrRule(a,b): '${(a:VersionRule)} || ${(b:VersionRule)}';
        };
    }
}

enum VersionComparator {
    EqualVersion(ver:Version);
    GreaterThanVersion(ver:Version);
    GreaterThanOrEqualVersion(ver:Version);
    LessThanVersion(ver:Version);
    LessThanOrEqualVersion(ver:Version);
    AndRule(a:VersionComparator, b:VersionComparator);
    OrRule(a:VersionComparator, b:VersionComparator);
}
