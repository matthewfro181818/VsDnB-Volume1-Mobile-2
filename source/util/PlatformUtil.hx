package util;

import flixel.FlxG;

/**
 * Cross-platform helper utilities for Engine forks.
 *
 * Linux   → xdg-open + notify-send
 * Windows → Inline C++ code (requires Windows SDK)
 * macOS   → FlxG.openURL
 */
class PlatformUtil
{
	// ---------------------------------------------------------
	// OPEN URL (Cross-platform)
	// ---------------------------------------------------------
	public static function openURL(link:String):Void
	{
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
	@:cppFileCode("
		#include <stdlib.h>
		#include <stdio.h>
		#include <windows.h>
		#include <winuser.h>
		#include <dwmapi.h>
		#include <shellapi.h>
		#include <strsafe.h>
		#include <Shlobj.h>
		#include <string>

		#pragma comment(lib, \"Dwmapi\")
		#pragma comment(lib, \"Shell32.lib\")
	")
	#end


	// ---------------------------------------------------------
	// TRANSPARENT WINDOW
	// ---------------------------------------------------------
	#if windows
	@:functionCode("
		HWND hWnd = GetActiveWindow();
		if (hWnd) {
			LONG style = GetWindowLong(hWnd, GWL_EXSTYLE);
			SetWindowLong(hWnd, GWL_EXSTYLE, style | WS_EX_LAYERED);
			SetLayeredWindowAttributes(hWnd, RGB(1,1,1), 0, LWA_COLORKEY);
		}
	")
	public static function getWindowsTransparent(res:Int = 0):Int return res;
	#else
	public static function getWindowsTransparent(res:Int = 0):Int return 0;
	#end


	// ---------------------------------------------------------
	// WINDOWS NOTIFICATION → Shell_NotifyIcon
	// Linux → notify-send
	// ---------------------------------------------------------
	#if windows
	@:functionCode("
		std::string titleStr = std::string(title.c_str());
		std::string descStr  = std::string(desc.c_str());

		NOTIFYICONDATAA nid;
		memset(&nid, 0, sizeof(nid));
		nid.cbSize = sizeof(nid);
		nid.hWnd = GetForegroundWindow();
		nid.uFlags = NIF_INFO;
		nid.dwInfoFlags = NIIF_INFO;

		StringCchCopyA(nid.szInfoTitle, ARRAYSIZE(nid.szInfoTitle), titleStr.c_str());
		StringCchCopyA(nid.szInfo, ARRAYSIZE(nid.szInfo), descStr.c_str());

		Shell_NotifyIconA(NIM_ADD, &nid);
		Shell_NotifyIconA(NIM_DELETE, &nid);
	")
	public static function sendWindowsNotification(title:String = "", desc:String = "", res:Int = 0):Int return res;
	#else
	public static function sendWindowsNotification(title:String = "", desc:String = "", res:Int = 0):Int
	{
		try Sys.command("notify-send", [title, desc]) catch(e:Dynamic) {};
		return 0;
	}
	#end


	// ---------------------------------------------------------
	// WINDOWS MESSAGE BOX
	// ---------------------------------------------------------
	#if windows
	@:functionCode("
		std::string s = std::string(desc.c_str());
		MessageBoxA(NULL, s.c_str(), \"Message\", MB_OK);
	")
	public static function sendFakeMsgBox(desc:String = "", res:Int = 0):Int return res;
	#else
	public static function sendFakeMsgBox(desc:String = "", res:Int = 0):Int return 0;
	#end


	// ---------------------------------------------------------
	// REMOVE WINDOW TRANSPARENCY
	// ---------------------------------------------------------
	#if windows
	@:functionCode("
		HWND hWnd = GetActiveWindow();
		if (hWnd) {
			LONG style = GetWindowLong(hWnd, GWL_EXSTYLE);
			SetWindowLong(hWnd, GWL_EXSTYLE, style & ~WS_EX_LAYERED);
			SetLayeredWindowAttributes(hWnd, RGB(1,1,1), 1, LWA_COLORKEY);
		}
	")
	public static function getWindowsBackward(res:Int = 0):Int return res;
	#else
	public static function getWindowsBackward(res:Int = 0):Int return 0;
	#end


	// ---------------------------------------------------------
	// RESTORE DESKTOP WALLPAPER
	// ---------------------------------------------------------
	#if windows
	@:functionCode("
		char path[MAX_PATH];
		if (SUCCEEDED(SHGetFolderPathA(NULL, CSIDL_APPDATA, NULL, 0, path))) {
			std::string s(path);
			s.append(\"\\\\Microsoft\\\\Windows\\\\Themes\\\\TranscodedWallpaper\");
			SystemParametersInfoA(SPI_SETDESKWALLPAPER, 0, (PVOID)s.c_str(), SPIF_UPDATEINIFILE);
		}
	")
	public static function updateWallpaper():Void {}
	#else
	public static function updateWallpaper():Void {}
	#end


	// ---------------------------------------------------------
	// DARK MODE TITLE BAR
	// ---------------------------------------------------------
	#if windows
	@:functionCode("
		BOOL dark = enable;
		std::string t = std::string(title.c_str());
		HWND w = FindWindowA(NULL, t.c_str());
		if (!w) w = GetActiveWindow();
		if (w) {
			DwmSetWindowAttribute(w, 20 /* DWMWA_USE_IMMERSIVE_DARK_MODE */, &dark, sizeof(dark));
			UpdateWindow(w);
		}
	")
	public static function setDarkMode(title:String, enable:Bool):Void {}
	#else
	public static function setDarkMode(title:String, enable:Bool):Void {}
	#end
}
