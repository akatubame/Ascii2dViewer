#Persistent
#SingleInstance, Force
;#NoTrayIcon

#Include *i <CommonHeader>
#Include *i <PersistentHeader>
#Include *i <SpeechRecognition>

; このアプリ専用のグローバル変数の格納オブジェクト生成
global A_Init_Object
global io := A_Init_Object["SpeechRecognizer"] := Object()

;-------------------------------------------
; 初期設定
;-------------------------------------------

; 関連ファイルのパスを指定
io.IniFile       := A_ScriptDir "\" "SpeechRecognizer.ini"
io.HotkeyFile    := A_ScriptDir "\" "Hotkey.ini"
Menu, Tray, Icon, % A_ScriptDir "\" "SpeechRecognizer.ico"

; 各種グローバル変数の設定
io.tbl := Object()             ; 音声認識対応表
io.s   := new SpeechRecognizer ; 音声認識スクリプトの呼出し

; 動作順序の定義
Gosub, Init
SetTimer, MainTimer, 100
OnExit, ExitSub
return

; 必ず後で読み込む
#Include *i <GUIFunctions>

;-------------------------------------------
; プログラム開始処理
;-------------------------------------------

; 初期動作
Init:
	io.Gui     := _ObjFromFile(io.IniFile)
	io.HK      := _ObjFromFile(io.HotkeyFile)
	io.ctr     := GetCtrAll()
	io.ThisGui := ""
	
	Gosub, Hotkey_Build
	For key in io.Gui {
		io.ThisGui := io.Gui[key]
		GoSub, GUI_Build
	}
	
	io.tbl := io.ctr.SpeechList.ItemObj.ItemList ; 音声認識対応表の同期
return

;-------------------------------------------
; 制御ルーチン
;-------------------------------------------

; 音声認識処理（タイマー）
MainTimer:
	Main()
return
Main(){
	; 挙動選択のGUI窓アクティブ時
	IfWinActive, ahk_group GuiGroup
	{
		return
	}
	; それ以外
	Else
	{
		; GUI消去
		For key in io.Gui
			GUI_Hide(io.Gui[key])
		
		; 音声認識
		io.s.Recognize(True)
		io.text := io.s.Prompt()
		
		; 誤作動を無視
		If ( StrLen(io.text) = 1 or SubStr(io.text, 1, 1) = "っ" )
			return
		
		; 認識ワードで指定動作を実行
		flag := 0
		For i in io.tbl {
			For k,v in io.tbl[i]["keyword"] {
				If ( io.text = v ) {
					Func(io.tbl[i]["func"]).(io.tbl[i]["option"]*)
					flag := 1
					Break
				}
			}
			If (flag)
				Break
		}
		
		; 見つからない場合、該当する挙動を選択
		If (!flag) {
			io.ThisGui.Title := "挙動の選択 - 「" io.text "」"
			For key in io.Gui {
				GUI_Show(io.Gui[key])
			}
			;_RunWaitClose("挙動の選択 ahk_class AutoHotkeyGUI")
		}
		SoundPlay, *64
	}
}

; イベント振分け処理
Event:
	Gosub, SetUp
	; 項目をクリックした時のイベント
	If (A_GuiEvent = "Normal") {
		ID := GetFocusItem(io.ThisCtr, 1)
		_AddToObj(io.tbl[ID].keyword, io.text)
		GUI_Hide(io.ThisGui)
	}
return

; 単純終了サブルーチン
Exit:
ExitApp

; 終了時の処理
ExitSub:
	io.Exit := 1
	Gosub, GUI_Save
ExitApp

; セーブ処理
Save:
	io.Exit := 0
	Gosub, GUI_Save
	GoSub, GUI_Load
return

; ウィンドウのサイズ変更時のイベント
GuiSize:
	; 最小化
	If (A_EventInfo = 1) {
		return
	}
	;; それ以外
	Else {
		ctr := GetCtrFromOption("CtrName", A_GuiControl)
		For key in ctr
			CTL_Size(ctr)
	}
return

; ウィンドウを閉じた時のイベント
GuiClose:
GuiEscape:
	GUI_Hide(io.ThisGui)
return

; 右クリックメニュー時のイベント
GuiContextMenu:
	; ツリービューの場合は項目を前もって選択
	ctr := GetCtrFromOption("CtrName", A_GuiControl)
	If (ctr.CtrType = "TreeView")
		Send, {LButton}
	
	;; 各種コンテキストメニュー表示
	;If (A_GuiControl = "Tags") {
	;	Menu, TagsContextMenu, Show
	;}
	;Else {
	;	Menu, MyContextMenu, Show
	;}
return

;-------------------------------------------
; 関数
;-------------------------------------------

