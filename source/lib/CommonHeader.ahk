;-------------------------------------------
; システムの設定
;-------------------------------------------

; ホイールによる連続ホットキーを防止
#MaxHotkeysPerInterval 500

; 環境変数を使用しない
;#NoEnv

; 各処理の待機時間をなしに指定
SetBatchLines, -1 ; コマンド実行
;SetKeyDelay,   -1 ; キーストロークの送信 (Sendコマンド不実行のためOFF)
;SetWinDelay,    0 ; ウィンドウ判定

; 各種キーロックを無効に
SetCapsLockState, Off
SetNumLockState, Off
SetScrollLockState, Off

; 処理履歴をOFFに
ListLines Off

; 相対パスの開始場所をAHKの配置ディレクトリに設定
SplitPath, A_ScriptDir, name
If (name = "AutoHotKey")
	SetWorkingDir, %A_ScriptDir%\
Else
	SetWorkingDir, %A_AhkPath%\..\

; 自前の環境変数を組み込む
EnvSet, A_Quote, """"

; AHKの一時フォルダを作成
FileCreateDir, %A_TempFolder%
;_FileCopy(A_NovelFolder, A_NovelFolder)

; 非表示のウィンドウを処理対象に含める
DetectHiddenWindows, On

; ウィンドウ指定法を正規表現に変更
SetTitleMatchMode, RegEx

; 共通ライブラリの読込み定義
#Include *i <MyScripts>
#Include *i <Functions>
#Include *i <COM>

; グローバル変数の格納オブジェクトを生成
global A_Init_Object := Object()

; コマンドライン引数を読みこみ
A_Init_Object["CmdParams"] := Object() ; 引数の格納オブジェクト
Loop, %0% {
	A_Init_Object["CmdParams"][A_Index] := %A_Index%
	If (A_Init_Object["CmdParams"][A_Index] = "%Blank%")
		A_Init_Object["CmdParams"][A_Index] := "" ; 空白値を一つの引数としてカウント
}
