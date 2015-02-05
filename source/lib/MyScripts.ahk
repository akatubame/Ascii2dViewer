
; 複数の文字列をハイフン"-"で連結してメッセージボックスに表示
_MsgBox(params*){
	Msg := ""
	For key, value in params
		Msg .= value . " - "
	Msg := StringTrimRight(Msg, 3)
	MsgBox, % Msg
}
; 指定ウィンドウを閉じる
_WinClose(twnd="A"){
	WinClose, %twnd%
}
; 指定ウィンドウがアクティブでなければアクティブにする
_WinActivate(twnd="A"){
	IfWinNotActive, %twnd%
		WinActivate, %twnd%
}
; 指定ウィンドウを最小化(タスクトレイに収納可)
_WinMinimize(twnd="A"){
	PostMessage, 0x112, 0xF020,,, %twnd%
}
; 指定ウィンドウを最大化
_WinMaximize(twnd="A"){
	WinMaximize, %twnd%
}
; 指定ウィンドウの最大化・最小化を解除
_WinRestore(twnd="A"){
	WinRestore, %twnd%
}

; 指定コマンドを実行
_Run(runapp, option="", runcmd=""){
	Run, %runapp% %option%,, %runcmd%
}
; 指定コマンドを作業フォルダを指定して実行
_RunIn(runapp, option="", runcmd="", dir=""){
	If (dir="")
		dir := _FileGetDir(runapp)
	Run, %runapp% %option%, %dir%, %runcmd%
}
; 指定ウィンドウが存在しなければ指定コマンドを実行、存在すればアクティブに
_RunOrActive(twnd, runapp, option="", runcmd=""){
	IfWinNotExist, %twnd%
	{
		_RunIn(runapp, option, runcmd)
		return 1
	}
	else
	{
		_WinActivate(twnd)
		return 0
	}
}
; IMEのオンオフ状態を取得 (戻り値 1=on 0=off)
_IME_GET(WinTitle="A"){
	VarSetCapacity(stGTI, 48, 0)
	NumPut(48, stGTI,  0, "UInt")   ;	DWORD   cbSize;
	hwndFocus := DllCall("GetGUIThreadInfo", Uint,0, Uint,&stGTI)
				 ? NumGet(stGTI,12,"UInt") : WinExist(WinTitle)

	return DllCall("SendMessage"
		, UInt, DllCall("imm32\ImmGetDefaultIMEWnd", Uint,hwndFocus)
		, UInt, 0x0283  ;Message : WM_IME_CONTROL
		,  Int, 0x0005  ;wParam  : IMC_GETOPENSTATUS
		,  Int, 0)      ;lParam  : 0
}
; IMEのオンオフ切替 (SetSTsの値 1=on 0=off)
_IME_SET(SetSts, WinTitle="A"){
	VarSetCapacity(stGTI, 48, 0)
	NumPut(48, stGTI,  0, "UInt")   ;	DWORD   cbSize;
	hwndFocus := DllCall("GetGUIThreadInfo", Uint,0, Uint,&stGTI)
					? NumGet(stGTI,12,"UInt") : WinExist(WinTitle)
	return DllCall("SendMessage"
		, UInt, DllCall("imm32\ImmGetDefaultIMEWnd", Uint,hwndFocus)
		, UInt, 0x0283  ;Message : WM_IME_CONTROL
		,  Int, 0x006   ;wParam  : IMC_SETOPENSTATUS
		,  Int, SetSts) ;lParam  : 0 or 1
}
; IMEの入力状態を取得 (戻り値 1=入力中 2=変換中 0=入力なし)
_IME_GetConverting(WinTitle="A",ConvCls="",CandCls=""){

	;IME毎の 入力窓/候補窓Class一覧 ("|" 区切りで適当に足してけばOK)
	ConvCls .= (ConvCls ? "|" : "")                 ;--- 入力窓 ---
		.  "ATOK\d+CompStr\d*"                  ; ATOK系
		.  "|imejpstcnv\d+"                     ; MS-IME系
		.  "|WXGIMEConv"                        ; WXG
		.  "|SKKIME\d+\.*\d+UCompStr"           ; SKKIME Unicode
		.  "|MSCTFIME Composition"              ; Google日本語入力

	CandCls .= (CandCls ? "|" : "")                 ;--- 候補窓 ---
		.  "ATOK\d+Cand"                        ; ATOK系
		.  "|imejpstCandList\d+|imejpstcand\d+" ; MS-IME 2002(8.1)XP付属
		.  "|mscandui\d+\.candidate"            ; MS Office IME-2007
		.  "|WXGIMECand"                        ; WXG
		.  "|SKKIME\d+\.*\d+UCand"              ; SKKIME Unicode
   CandGCls := "GoogleJapaneseInputCandidateWindow" ;Google日本語入力

	VarSetCapacity(stGTI, 48, 0)
	NumPut(48, stGTI,  0, "UInt")   ;	DWORD   cbSize;
	hwndFocus := DllCall("GetGUIThreadInfo", Uint,0, Uint,&stGTI)
				? NumGet(stGTI,12,"UInt") : WinExist(WinTitle)

	WinGet, pid, PID,% "ahk_id " hwndFocus
	tmm:=A_TitleMatchMode
	SetTitleMatchMode, RegEx
	ret := WinExist("ahk_class " . CandCls . " ahk_pid " pid) ? 2
		:  WinExist("ahk_class " . CandGCls                 ) ? 2
		:  WinExist("ahk_class " . ConvCls . " ahk_pid " pid) ? 1
		:  0
	SetTitleMatchMode, %tmm%
	return ret
}
; モニタの電源をOFFにする
_MonitorOff(){
	SendMessage, 0x112, 0xF170, 2,, ahk_id 0xFFFF
}
; システムのシャットダウンを実行
_ShutDown(){
	Shutdown, 1
}
; システムの再起動を実行
_Reboot(){
	Shutdown, 2
}
; システムをスリープ・休止状態へ移行
_Hybernate(){
	DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0)
}

; Google検索実行
_Google(word=""){
	If (word)
		_UE( "google", _WQ(word) )
}
; 対象ワード(複数可)でぐぐる
_SearchText(target){
	Loop, parse, target, `n, `r
		If (A_LoopField != "")
			_Google(A_LoopField)
}
; 指定パス(複数可)を適切なアプリで開く
_OpenPath(target){
	Loop, parse, target, `n, `r
	{
		If (A_LoopField = "")
			continue
		
		Path  := _RemoveSpace( _DeWQ(A_LoopField) )
		drive := _FileGetDrive(Path)
		pos   := InStr(drive, "ttp")
		If pos between 1 and 2
		{
			URLs := % (pos == 1) ? ("h" . Path) : Path
			_Run("..\..\cpt\FirefoxPortable\FirefoxPortable.exe", URLs)
		}
		Else IfExist, %Path%
		{
			Path := _RelToAbs(Path)
			ext  := _FileGetExt(Path)
			If (RegExMatch(ext, "^(txt)$"))
				_Run("..\X-Finder\XF.exe", _WQ(Path) " ..")
			Else
				_Run("..\X-Finder\XF.exe", _WQ(Path) )
		}
		Else
		{
			pos2 := InStr(Path, "HKEY_")
			If (pos2 = 1)
				_Run("..\GekiOreRegEdit\GekiOreRegEdit.exe", Path)
			Else If ( RegExMatch(Path, "^(\d|[01]?\d\d|2[0-4]\d|25[0-5])\.(\d|[01]?\d\d|2[0-4]\d|25[0-5])\.(\d|[01]?\d\d|2[0-4]\d|25[0-5])\.(\d|[01]?\d\d|2[0-4]\d|25[0-5])$") )
			{
				_Run("..\..\cpt\FirefoxPortable\FirefoxPortable.exe", "http://www.iphiroba.jp/index.php")
				Sleep, 4000
				MouseClick, Left, 750, 397, 1, 0
				Sleep 100
				SendInput, %Path%
				Sleep 100
				Send, {Enter}
			}
		}
	}
}
; 指定サイト＆指定ワードでWEB検索
_UE(SearchE, target, encoded=""){
	url := _UE_Get(SearchE, target, encoded)
	_OpenPath(url)
	_LogText(A_Log_SearchLog, target, 100) ; 検索履歴に追記
}
; 指定サイト＆指定ワードでWEB検索URLを生成
_UE_Get(SearchE, target, encoded=""){
	obj := A_Init_Object["UE"][SearchE]
	str := IsObject(encoded) ? encoded[obj["encode"]] : _URLEncode(target, obj["encode"])
	
	url := (obj["urlsuf"] != "") ? obj["urlpre"] . str . obj["urlsuf"] : obj["urlpre"] . str
	return url
}

; Google検索バー
_SearchBox(){
	_AHK_SA("_SearchBox_Main")
}
; SearchBox実行
_SearchBox_Main(){
	Input := _Inputbox("Search for Google",,, 60, "Repeat",, 230, 100)
	_Google(Input)
	_RunWaitClose("Google ahk_class #32770")
}
; 指定時間経過後にアラートを表示
_StopAlert(time, unit, sound=""){
	If (unit = "H")
		u := "時間", sleeptime := time * 1000 * 60 * 60
	Else If (unit = "M")
		u := "分",   sleeptime := time * 1000 * 60
	Else
		u := "秒",   sleeptime := time * 1000
	
	_Notify("=== STOP ALERT ===", time u "後にアラート", 3)
	Sleep, %sleeptime%
	_Notify("=== STOP ALERT ===", time u "が経過しました",,,, sound)
}
; 指定文字列で付箋を作り画面に貼る
_Notify(Title="!!!",Message="",Duration=3,Options="",Image="",Sound=""){
	_AHK("Notify",, Title, Message, Duration, Options, Image, Sound)
}
; AHKスクリプト実行
_AHK(fname, wait="", params*){
	IfNotInString, fname, \
		script := "util\" fname ".ahk"
	Else
		script := _RelToAbs(fname)
	
	option := _OptionCombine(params*)
	If (wait)
		_RunWait("AutoHotKey.exe", script " " option)
	Else
		_Run("AutoHotKey.exe", script " " option)
}
; スタンドアロンでAHK関数を実行
_AHK_SA(function, params*){
	_AHK("AHK_StandAlone",, function, params*)
}
