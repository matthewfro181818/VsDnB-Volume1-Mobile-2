package util;

import haxe.Json;
import thx.semver.Version;
import thx.semver.VersionRule;
import thx.semver.Identifier; // <-- CORRECT FIX

/**
 * Utility functions for semantic version parsing, validation, and repair.
 * Corrected so it compiles under Haxe 4.3+ and thx.semver.
 */
class VersionUtil
{
    /**
     * Check that a version satisfies a version rule.
     */
    public static function validateVersion(version:Version, versionRule:VersionRule):Bool
    {
        try {
            return version.satisfies(versionRule);
        } catch (e) {
            trace('[VERSIONUTIL] Invalid semantic version: $version');
            return false;
        }
    }

    /**
     * Repairs broken semantic version objects (common when JSON loads arrays as objects).
     */
    public static function repairVersion(version:Version):Version
    {
        var data = version.toSemVer();

        // Fix "version" array
        if (thx.Types.isAnonymousObject(data.version))
        {
            trace('[SAVE] Version data repair required! (got ${data.version})');

            data.version = [
                data.version[0],
                data.version[1],
                data.version[2]
            ];

            // Fix build identifiers
            var buildArr:Array<Dynamic> = thx.Dynamics.DynamicsT.values(data.build);
            data.build = buildArr.map(d -> Identifier.Alpha(d.toString()));

            // Fix pre-release identifiers
            var preArr:Array<Dynamic> = thx.Dynamics.DynamicsT.values(data.pre);
            data.pre = preArr.map(d -> Identifier.Alpha(d.toString()));

            var fixed = Version.fromSemVer(data);
            trace('[SAVE] Fixed version: $fixed');
            return fixed;
        }

        trace('[SAVE] Version data repair not required (got ${version})');
        return version;
    }

    /**
     * Check version against a string rule.
     */
    public static function validateVersionStr(version:String, versionRule:String):Bool
    {
        try {
            var v:Version = Version.fromString(version);
            var rule:VersionRule = VersionRule.fromString(versionRule);
            return v.satisfies(rule);
        }
        catch (e) {
            trace('[VERSIONUTIL] Invalid semantic version: $version');
            return false;
        }
    }

    /**
     * Extract semantic version number from JSON string.
     */
    public static function getVersionFromJSON(input:Null<String>):Null<Version>
    {
        if (input == null) return null;
        var parsed:Dynamic = Json.parse(input);
        if (parsed == null || parsed.version == null) return null;

        return Version.fromString(parsed.version);
    }

    /**
     * Parse a semantic version from either a string or a SemVer object.
     */
    public static function parseVersion(input:Null<Dynamic>):Null<Version>
    {
        if (input == null)
            return null;

        if (Std.isOfType(input, String))
            return Version.fromString(cast input);

        // Assume input is a SemVer structure from thx.semver
        return Version.fromSemVer(cast input);
    }
}
