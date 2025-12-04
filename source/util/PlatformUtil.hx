package util;

import flixel.FlxG;

/**
 * Cross-platform helper utilities for Engine forks.
 *
 * Linux   → xdg-open + notify-send
 * Windows → Inline C++ code (requires Windows SDK)
 * macOS   → FlxG.openURL
 */
class PlatformUtil {
    // ---------------------------------------------------------
    // OPEN URL (Cross-platform)
    // ---------------------------------------------------------
    public static function openURL(link:String):Void {
        #if linux
        Sys.command("/usr/bin/xdg-open", [link]);
        #else
        FlxG.openURL(link);
        #end
    }

    // ---------------------------------------------------------
    // WINDOWS INLINE C++ SUPPORT
    // ---------------------------------------------------------
    #if windows
    @:cppFileCode('
        #include <stdlib.h>
        #include <stdio.h>
        #include <windows.h>
        #include <winuser.h>
        #include <dwmapi.h>
        #include <shellapi.h>
        #include <string>
        #include <iostream>

        #pragma comment(lib, "Dwmapi")
        #pragma comment(lib, "Shell32.lib")
    ')
    #end


    // ---------------------------------------------------------
    // TRANSPARENT WINDOW
    // ---------------------------------------------------------
    #if windows
    @:functionCode('
        HWND hWnd = GetActiveWindow();
        if (hWnd) {
            LONG style = GetWindowLong(hWnd, GWL_EXSTYLE);
            SetWindowLong(hWnd, GWL_EXSTYLE, style | WS_EX_LAYERED);
            SetLayeredWindowAttributes(hWnd, RGB(1,1,1), 0, LWA_COLORKEY);
        }
    ')
    public static function getWindowsTransparent(res:Int = 0):Int {
        return res;
    }
    #else
    public static function getWindowsTransparent(res:Int = 0):Int {
        return 0;
    }
    #end


    // ---------------------------------------------------------
    // WINDOWS NOTIFICATION → Shell_NotifyIcon
    // Linux fallback → notify-send
    // ---------------------------------------------------------
    #if windows
    @:functionCode('
        NOTIFYICONDATAA nid;
        memset(&nid, 0, sizeof(nid));
        nid.cbSize = sizeof(nid);
        nid.hWnd = GetForegroundWindow();
        nid.uFlags = NIF_INFO;
        nid.dwInfoFlags = NIIF_WARNING;

        StringCchCopyA(nid.szInfoTitle, ARRAYSIZE(nid.szInfoTitle), title.c_str());
        StringCchCopyA(nid.szInfo, ARRAYSIZE(nid.szInfo), desc.c_str());

        Shell_NotifyIconA(NIM_ADD, &nid);
    ')
    public static function sendWindowsNotification(title:String = "", desc:String = "", res:Int = 0):Int {
        return res;
    }
    #else
    public static function sendWindowsNotification(title:String = "", desc:String = "", res:Int = 0):Int {
        Sys.command("notify-send", [title, desc]);
        return 0;
    }
    #end


    // ---------------------------------------------------------
    // WINDOWS MESSAGE BOX
    // ---------------------------------------------------------
    #if windows
    @:functionCode('
        MessageBoxA(NULL, desc.c_str(), "Message", MB_OK);
    ')
    public static function sendFakeMsgBox(desc:String = "", res:Int = 0):Int {
        return res;
    }
    #else
    public static function sendFakeMsgBox(desc:String = "", res:Int = 0):Int {
        return 0;
    }
    #end


    // ---------------------------------------------------------
    // REMOVE TRANSPARENCY (WINDOW BACKWARD)
    // ---------------------------------------------------------
    #if windows
    @:functionCode('
        HWND hWnd = GetActiveWindow();
        if (hWnd) {
            LONG style = GetWindowLong(hWnd, GWL_EXSTYLE);
            SetWindowLong(hWnd, GWL_EXSTYLE, style & ~WS_EX_LAYERED);
            SetLayeredWindowAttributes(hWnd, RGB(1,1,1), 1, LWA_COLORKEY);
        }
    ')
    public static function getWindowsBackward(res:Int = 0):Int {
        return res;
    }
    #else
    public static function getWindowsBackward(res:Int = 0):Int {
        return 0;
    }
    #end


    // ---------------------------------------------------------
    // RESTORE DESKTOP WALLPAPER (Windows)
    // ---------------------------------------------------------
    #if windows
    @:functionCode('
        std::string p(getenv("APPDATA"));
        p.append("\\\\Microsoft\\\\Windows\\\\Themes\\\\TranscodedWallpaper");
        SystemParametersInfoA(SPI_SETDESKWALLPAPER, 0, (PVOID)p.c_str(), SPIF_UPDATEINIFILE);
    ')
    public static function updateWallpaper():Void {}
    #else
    public static function updateWallpaper():Void {}
    #end


    // ---------------------------------------------------------
    // SET DARK MODE TITLE BAR (Windows 10+)
    // ---------------------------------------------------------
    #if windows
    @:functionCode('
        BOOL darkMode = enable;
        HWND window = FindWindowA(NULL, title.c_str());
        if (!window) window = GetActiveWindow();
        if (!window) return;

        DwmSetWindowAttribute(window, 20 /* DWMWA_USE_IMMERSIVE_DARK_MODE */, &darkMode, sizeof(darkMode));
        UpdateWindow(window);
    ')
    public static function setDarkMode(title:String, enable:Bool):Void {}
    #else
    public static function setDarkMode(title:String, enable:Bool):Void {}
    #end
}
