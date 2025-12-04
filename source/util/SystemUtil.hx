package util;

// crazy system shit!!!!!
// lordryan wrote this :) (erizur added cross platform env vars)

import sys.io.File;

class SystemUtil {

    /**
     * Gets the user's platform username.
     * @return The platform username.
     */
    public static function getUsername():String {
        #if windows
        return Sys.getEnv("USERNAME");
        #else
        return Sys.getEnv("USER");
        #end
    }

    /**
     * Gets the path to the user's home directory.
     * @return A string representing the path to the user's home folder.
     */
    public static function getUserPath():String {
        #if windows
        return Sys.getEnv("USERPROFILE");
        #else
        return Sys.getEnv("HOME");
        #end
    }

    /**
     * Gets the location of the TEMP folder.
     * @return A string containing the path to the TEMP folder.
     */
    public static function getTempPath():String {
        #if windows
        return Sys.getEnv("TEMP");
        #else
        // Non-Windows systems may not have TEMP, fallback to HOME
        return Sys.getEnv("TMPDIR") ?? Sys.getEnv("HOME");
        #end
    }

    /**
     * Gets the file name of the executable.
     * @return The name of the executable.
     */
    public static function executableFileName():String {
        #if windows
        var programPath = Sys.programPath().split("\\");
        #else
        var programPath = Sys.programPath().split("/");
        #end
        return programPath[programPath.length - 1];
    }

    /**
     * Generates a text file in the TEMP folder and opens it.
     * @param fileContent The content of the file.
     * @param fileName The name of the file (no extension needed).
     */
    public static function generateTextFile(fileContent:String, fileName:String):Void {
        var fullPath = getTempPath() + "/" + fileName + ".txt";

        #if desktop
        File.saveContent(fullPath, fileContent);
        #else
        SUtil.saveContent(fileName, ".txt", fileContent);
        #end

        FileUtil.openFile(fullPath);
    }
}
