;-------------------------------------------
; その他自作関数ライブラリ
; by akatubame
;-------------------------------------------
;
;-------------------------------------------
;
;-------------------------------------------
; 汎用関数
;-------------------------------------------

; 複数の文字列をハイフン"-"で連結してメッセージボックスに表示
_MsgBox(args*){
	Msg := ""
	For key, value in args
		Msg .= value . " - "
	Msg := StringTrimRight(Msg, 3)
	MsgBox, % Msg
}
; 文字列を入力して変数に取得
_Inputbox(Title="", Prompt="", Default="", Timeout="", Repeat="", HIDE="", Width="", Height="", X="", Y="", Font=""){
	
	; ダイアログの自動調整（ウィンドウのXY座標、縦横サイズ）
	W      := ( Strlen(Default) > StrLen(Prompt) ) ? 150 + 10 * Strlen(Default) : 150 + 10 * StrLen(Prompt)
	H      := 140 + 20 * ( (StrLen(Prompt) / 30) - 1 )
	Width  := Width  ? Width  : (W > 400) ? 400 : (W < 200) ? 200 : W
	Height := Height ? Height : (StringGetPos(Prompt, "`n") != -1) ? H + 10 : H
	X      := X      ? X      : (A_ScreenWidth  - Width)  / 2
	Y      := Y      ? Y      : (A_ScreenHeight - Height) / 2
	
	InputBox, OutputVar, %Title%, %Prompt%, %HIDE%, %Width%, %Height%, %X%, %Y%,, %Timeout%, %Default%
	
	; 入力をキャンセルした場合
	If (ErrorLevel)
		Exit
	
	; 空文字列を入力した場合、指定スイッチがあればリピート
	While (OutputVar = "" && Repeat!="") {
		InputBox, OutputVar, %Title%, %Prompt%, %HIDE%, %Width%, %Height%, %X%, %Y%,, %Timeout%, %Default%
		If (ErrorLevel)
			Exit
	}
	return OutputVar
}
; 指定URLのHTTPレスポンスを取得(GETメソッド)
_HttpGet(url){
	WinHttpReq := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	WinHttpReq.Open("GET", url)
	WinHttpReq.Send()
	return WinHttpReq.ResponseText
}
; 指定URLのHTTPレスポンスを取得(POSTメソッド)
_HttpPost(url, postdata){
	WinHttpReq := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	WinHttpReq.Open("POST", url)
	;WinHttpReq.SetRequestHeader("Content-type", "multipart/form-data;")
	WinHttpReq.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
	WinHttpReq.Send(postdata)
	return WinHttpReq.ResponseText
}
; 指定文字列 or ファイルから各種ハッシュ文字列を取得
_HashGet(target, Hashname){
	If (target="")
		return
	
	If ( IfExist(target) )
		FileHashCMS(target, CRC, MD5, SHA)
	Else
		StrHashCMS(target, CRC, MD5, SHA)
	
	return Hashname="CRC" ? CRC : Hashname="MD5" ? MD5 : Hashname="SHA" ? SHA : ""
}
; 指定文字列 or ファイルからMD5ハッシュを取得
_HashGetMD5(target){
	return _HashGet(target, "MD5")
}
; 指定ファイルが存在すればリネームしてフラグを返す
_FileRename(fname, newName="", flag=0, PassExt=0){
	Attrib := FileExist(fname)
	If (Attrib)
	{
		dir     := _FileGetDir(fname)
		ext     := _FileGetExt(fname)
		default := (PassExt = 1) ? _FileGetNoExt(fname) : _FileGetName(fname)
		newName := (newName != "") ? newName : _Inputbox("ファイル名の変更", "変更後のファイル名を入力", default)
		
		If (Attrib = "D")
			FileMoveDir, %fname%, %dir%\%newName%, %flag%
		Else If (PassExt)
			FileMove, %fname%, %dir%\%newName%.%ext%, %flag%
		Else
			FileMove, %fname%, %dir%\%newName%, %flag%
		return ErrorLevel
	}
	Else
		return 0
}
; 指定ファイルが存在すれば指定先へコピーしてフラグを返す
_FileCopy(fname, fname2, flag=0){
	Attrib := FileExist(fname)
	If (Attrib)
	{
		If (Attrib = "D")
			FileCopyDir, %fname%, %fname2%, %flag%
		Else
			FileCopy, %fname%, %fname2%, %flag%
		return ErrorLevel
	}
	Else
		return 0
}
; 指定ファイルが存在すれば削除してフラグを返す
_FileDelete(fname, confirm=""){
	Attrib := FileExist(fname)
	If (Attrib)
	{
		If (confirm) {
			If ( !_IfMsgBox(fname "を削除しますか？") )
				return 1
		}
		
		If (Attrib = "D")
			FileRemoveDir, %fname%, 1
		Else
			FileDelete, %fname%
		
		return ErrorLevel
	}
	Else
		return 0
}
; ダイアログからファイルを選択
_FileSelectFile(Path="", Prompt="", Filter=""){
	FileSelectFile, file, 3, %Path%, %Prompt%, %Filter%
	If (!file)
		Exit
	return file
}
; パスから拡張子を取得(.zipでなくzip)
_FileGetExt(path){
	SplitPath(path, name, dir, ext, noext, drive)
	return _RemoveSpace(ext)
}
; パスからファイル名(拡張子を除く)を取得
_FileGetNoExt(path){
	SplitPath(path, name, dir, ext, noext, drive)
	return noext
}
; パスからファイル名(拡張子付き)を取得
_FileGetName(path){
	SplitPath(path, name, dir, ext, noext, drive)
	return name
}
; パスから親ディレクトリを取得
_FileGetDir(path){
	SplitPath(path, name, dir, ext, noext, drive)
	return dir
}
; パスから現在ドライブを取得
_FileGetDrive(path){
	SplitPath(path, name, dir, ext, noext, drive)
	return _RemoveSpace(drive)
}
; 指定ファイル(複数可)を削除
_FileDeleteArray(target, confirm="", NoDialog=""){
	If (!target)
		return
	
	If (confirm) {
		Count := 0
		Loop, parse, target, `n, `r
		{
			if (A_LoopField = "")
				continue
			
			_AddLine(files, A_LoopField)
			Count++
		}
		
		If ( !_IfMsgBox(files "`n" "これら" Count "個のファイルを削除しますか？") )
			return 0
	}
	
	Count2 := 0
	Loop, parse, target, `n, `r
	{
		if (A_LoopField = "")
			continue
		
		If ( !_FileDelete(A_LoopField) )
			Count2++
	}
	If (NoDialog = "")
		_MsgBox(Count2 "個のファイルの削除が終了しました")
}
; 指定フォーマットの文字列をオブジェクトに格納
_ObjFromStr(String, Rows="`n", Equal="=", Indent="`t"){
	obj := [], kn := []
	IndentLen := StrLen(Indent)
	Loop, parse, String, %Rows%
	{
		if A_LoopField is space
			continue
		Field := RTrim(A_LoopField, " `t`r")
		
		CurLevel := 1, k := "", v := ""
		While (SubStr(Field,1,IndentLen) = Indent) {
			StringTrimLeft, Field, Field, %IndentLen%
			CurLevel++
		}
		
		EqualPos := InStr(Field, Equal)
		if (EqualPos = 0)
			k := Field
		else
			k := SubStr(Field, 1, EqualPos-1), v := SubStr(Field, EqualPos+1)
		
		k := Trim(k, " `t`r"), v := Trim(v, " `t`r")
		kn[CurLevel] := k
		if !(EqualPos = 0)
		{
			if (CurLevel = 1)
			obj[kn.1] := v
			else if (CurLevel = 2)
			obj[kn.1][k] := v
			else if (CurLevel = 3)
			obj[kn.1][kn.2][k] := v
			else if (CurLevel = 4)
			obj[kn.1][kn.2][kn.3][k] := v
			else if (CurLevel = 5)
			obj[kn.1][kn.2][kn.3][kn.4][k] := v
			else if (CurLevel = 6)
			obj[kn.1][kn.2][kn.3][kn.4][kn.5][k] := v
			else if (CurLevel = 7)
			obj[kn.1][kn.2][kn.3][kn.4][kn.5][kn.6][k] := v
		}
		else
		{
			if (CurLevel = 1)
			obj.Insert(kn.1,Object())
			else if (CurLevel = 2)
			obj[kn.1].Insert(kn.2,Object())
			else if (CurLevel = 3)
			obj[kn.1][kn.2].Insert(kn.3,Object())
			else if (CurLevel = 4)
			obj[kn.1][kn.2][kn.3].Insert(kn.4,Object())
			else if (CurLevel = 5)
			obj[kn.1][kn.2][kn.3][kn.4].Insert(kn.5,Object())
			else if (CurLevel = 6)
			obj[kn.1][kn.2][kn.3][kn.4][kn.5].Insert(kn.6,Object())
		}
	}
	return obj
}
; 指定オブジェクトの内容を文字列に変換
_ObjToStr(Obj, Rows="`n", Equal=" = ", Indent="`t", Depth=7, CurIndent=""){
	For k,v in Obj
		ToReturn .= CurIndent . k . (IsObject(v) && depth>1 ? Rows . _ObjToStr(v, Rows, Equal, Indent, Depth-1, CurIndent . Indent) : Equal . v) . Rows
	return RTrim(ToReturn, Rows)
}
; 指定オブジェクトの内容をファイルに書き出す
_ObjToFile(Obj, FilePath, BackUp="", Rows="`n", Equal=" = ", Indent="`t", Depth=7, CurIndent=""){
	If ( BackUp != "" and IfExist(FilePath) ) {
		backup := _FileGetName(FilePath) ".bak"
		_FileRename(FilePath, backup, 1)
	}
	_FileNewAppend( _ObjToStr(Obj, Rows, Equal, Indent, Depth, CurIndent), FilePath, "UTF-8" )
	return ErrorLevel
}
; 指定ファイルの内容をオブジェクトに読み込む
_ObjFromFile(FilePath, Rows="`n", Equal="=", Indent="`t"){
	If ( !FileExist(FilePath) )
		return
	String := FileRead(FilePath)
	return _ObjFromStr(String, Rows, Equal, Indent)
}
; 指定文字列をクリップボードへ
_Clip(target,time=0.1){
	Clipboard := ""
	Clipboard := target
	ClipWait, %time%
}
; 選択文字列をクリップボードへ
_ClipCopy(time=0.1){
	Clipboard := ""
	Send, ^c
	ClipWait, %time%
}
; 選択ワードor選択ファイルを、なければクリップボードを返す
_SelectedOrClipboard(time=0.1){
	bk  := ClipboardAll
	Ret := Clipboard
	_ClipCopy(time)
	Ret := (Clipboard != "") ? Clipboard : Ret
	Clipboard := bk
	return Ret
}
; 指定文字列の末尾へ行を追加
_AddLine(ByRef target, line){
	target .= line "`n"
}
; 指定文字列をダブルクォーテーション[""]で囲む
_WQ(str){
	;コマンドラインの場合は空白でも囲むべき
	;If (str="")
	;	return
	
	StringGetPos, start, str, ", L
	If (ErrorLevel = 0) {
		StringLen, Length, str
		StringGetPos, end, str, ", R
		If (start = 0 && end = Length-1)
			return str
	}
	str = "%str%"
	return str
}
; 指定文字列を、指定区切り記号ごとに分解後オブジェクト配列に格納
_StringSplit(InputVar, Delimiters, OmitChars=""){
	StringSplit, Array, InputVar, %Delimiters%, %OmitChars%
	Obj := []
	Loop {
		p := Array%A_Index%
		If (p = "")
			Break
		Obj.Insert(p)
	}
	return Obj
}
; 指定文字列を、指定区切り記号ごとに分解後、改行で繋げて連結
_StringSplitCombine(target, SplitChar){
	target := StringReplace(target, SplitChar, "", 1)
	Loop, parse, target, 
		If (A_LoopField != "" && A_LoopField != "h")
			_AddLine(text, SplitChar . A_LoopField)
	return text
}
; 指定文字列(複数)を指定区切り記号で繋げて連結
_StringCombine(Delimiters, args*){
	str    := ""
	Length := StrLen(Delimiters)
	
	For key, value in args
		str .= value . Delimiters
	str := StringTrimRight(str, Length)
	return str
}
; 指定コマンドラインオプション(複数)をダブルクォーテーション[""]で囲み連結
_OptionCombine(args*){
	option := ""
	For key, value in args
		option .= _WQ(value) . " "
	option := StringTrimRight(option, 1)
	return option
}
; 指定文字列から無駄なスペースや改行を取り除く
_RemoveSpace(text){
	text := StringReplace(text, """""", , "All")
	text := StringReplace(text, "　", A_Space, "All")
	text := StringReplace(text, "`r", , "All")
	text := StringReplace(text, "`n", , "All")
	text := RegExReplace(text, " +", " ")
	text := RegExReplace(text, "^\s", "")
	text := RegExReplace(text, "\s$", "")
	return text
}
; 複数改行を単改行に変換
_RemoveIndent(str){
	str2 := ""
	Loop, Parse, str, `n, `r
	{
		If (A_LoopField="")
			Continue
		_AddLine(str2, A_LoopField)
	}
	str2 := StringTrimRight(str2, 1)
	return str2
}
; 指定文字列からファイル名使用不可文字を削除する
_RemoveIllegalChar(var){
	;var := StringReplace(var, A_Space, "_", "All")
	;chars = ,<>:;'"/|\{}=+`%^&*~
	chars = ,<>:;"/|\{}=*~
	loop, parse, chars,
		var := StringReplace(var, A_LoopField, "", "All")
	;var := StringReplace(var, "_", A_Space, "All")
	return var
}
; 指定文字列を検索語に適した文字列に整形する
_OptimizeChar(text){
	text := _ListReplace(text,, "OptimizeReplace")
	text := _ListReplaceRegex(text,, "OptimizeRegex")
	text := _RemoveSpace(text)
	return text
}
; 指定文字列をファイル名に適した文字列に整形する
_OptimizeName(text){
	text := _OptimizeChar(text)
	text := _ListReplace(text,, "OptimizeName")
	text := _RemoveIllegalChar(text)
	return text
}
; 指定文字列から、指定正規表現でマッチした行のみ抽出
_RegexExtract(target, Pattern=""){
	If (!target)
		return
	If (!Pattern)
		Pattern := _Inputbox("指定正規表現でマッチした行を抽出", "正規表現を入力してください",,, "Repeat")
	
	Loop, parse, target, `n, `r
		If ( RegExMatch(A_LoopField, Pattern) )
			_AddLine(text, A_LoopField)
	
	return text
}
; 指定文字列から、指定正規表現で正規変換した行のみ抽出
_RegexExtractReplace(target, Pattern="", Replacement=""){
	If (!target)
		return
	If (!Pattern)
		Pattern := _Inputbox("指定正規表現でマッチした行を抽出", "置換する正規表現を入力",,, "Repeat")
	If (!Replacement)
		Replacement := _Inputbox("指定正規表現でマッチした行を抽出", "置換後の正規表現を入力")
	
	Loop, parse, target, `n, `r
		If ( RegExMatch(A_LoopField, Pattern) ) {
			target := RegExReplace(A_LoopField, Pattern, Replacement)
			_AddLine(text, target)
		}
	
	return text
}
; 指定文字列からURLを抽出
_URLExtract(text){
	;text := _RegexExtractReplace(text, "^.*(ttps?:\/\/[-_.!~*\'()a-zA-Z0-9;\/?:&=+\`$,`%#]+).*$", "h$1")
	text := _RegexExtract(text, "(ttps?:\/\/[-_.!~*a-zA-Z0-9\/?&=+\`$,`%#]+)")
	;text := _StringSplitCombine(text, "://")
	text := _RegexExtractReplace(text, "^.*ttp(s?:\/\/[-_.!~*a-zA-Z0-9\/?&=+\`$,`%#]+).*$", "http$1")
	text := _RemoveIndent(text)
	return text
}
; 指定ディレクトリを基準とした相対パスを絶対パスに変換
_RelToAbs_From(root, dir, s = "\"){
	; 既に絶対パスなら処理せず返す
	If ( _FileGetDrive(dir) )
		return dir

	pr := SubStr(root, 1, len := InStr(root, s, "", InStr(root, s . s) + 2) - 1)
		, root := SubStr(root, len + 1)
	If InStr(root, s, "", 0) = StrLen(root)
		root := StringTrimRight(root, 1)
	If InStr(dir, s, "", 0) = StrLen(dir)
		dir := StringTrimRight(dir, 1)
	sk := 0
	Loop, Parse, dir, %s%
	{
		If A_LoopField = ..
		{
			StringLeft, root, root, InStr(root, s, "", 0) - 1
			sk += 3
		}
		Else If A_LoopField = .
			sk += 2
		Else If A_LoopField =
		{
			root =
			sk++
		}
	}
	dir := StringTrimLeft(dir, sk)
	
	Abs := pr . root . s . dir
	If InStr(Abs, s, "", 0) = StrLen(Abs)
		Abs := StringTrimRight(Abs, 1)
	
	Return, Abs
}
; AHK本体を基準とした相対パスを絶対パスに変換
_RelToAbs(Path){
	return % _RelToAbs_From(A_WorkingDir, Path, "\")
}
; 指定文字列を指定リスト(置換前と後の文字列一覧)を参照して一括置換
_ListReplace(str, list="", objName=""){
	target := A_Init_Object[objName]
	If ( target="" ) {
		list   := IfExist(list) ? list : _FileSelectFile("replace", "置換リストを開く", "テキストドキュメント (*.txt)")
		target := FileRead(list)
	}
	
	Loop, parse, target, `n, `r
	{
		If (A_LoopField = "")
			continue
		
		StringSplit, rule, A_LoopField, %A_Tab%
		l := rule1, r := rule2
		
		str := StringReplace(str, l, r, "All")
	}
	return str
}
; 指定文字列を指定リスト(置換前と後の正規表現一覧)を参照して一括正規置換
_ListReplaceRegex(str, list="", objName=""){
	target := A_Init_Object[objName]
	If ( target="" ) {
		list   := IfExist(list) ? list : _FileSelectFile("regex", "正規表現リストを開く", "テキストドキュメント (*.txt)")
		target := FileRead(list)
	}
	
	Loop, parse, target, `n, `r
	{
		If (A_LoopField = "")
			continue
		
		StringSplit, rule, A_LoopField, %A_Tab%
		l := rule1, r := rule2
		
		l   := "imXS)" l
		r   := StringReplace(r, "\n", "`n", "All")
		r   := StringReplace(r, "\t", A_Tab, "All")
		str := RegExReplace(str, l, r)
	}
	return str
}
; 指定文字列を正規表現検索し、一致した先頭マッチ文字列を取得
_RegExMatch_Get(Target, Pattern){
	RegExMatch(Target, Pattern, $)
	return $1
}
; 指定文字列をクリップボードに入れてツールチップ表示
_ClipGet(target){
	_Clip(target)
	_Tooltip(target, 700)
}
; 指定オブジェクトの最後尾に要素を挿入
_AddToObj(obj, target*){
	obj.Insert(target*)
}
; 指定オブジェクトの格納要素数を取得
_GetMaxIndex(obj){
	key := obj.MaxIndex() ? obj.MaxIndex() : 0y
	return key
}
; 指定オブジェクトをNativeCOMでラッピング、操作可能にする
_NativeCom(ByRef obj){
	If ( !IsObject(obj) )
		return
	
	ComObjError(false)
	If ( !ComObjType(obj,"iid") )
		obj := ComObjEnwrap(COM_Unwrap(obj))
	ComObjError(true)
}
; 指定ウィンドウのIDを取得
_WinGetId(twnd="A"){
	WinGet, id, ID, %twnd%
	return id
}
; 指定ウィンドウを常に最前面表示
_WinAlwaysTop(twnd="A"){
	WinSet, AlwaysOnTop, ON, %twnd%
}
; 指定ウィンドウがアクティブでなければアクティブにする
_WinActivate(twnd="A"){
	IfWinNotActive, %twnd%
		WinActivate, %twnd%
}
; 指定ウィンドウを無理やりトレイアイコンに最小化
_WinMinimizeTray(twnd="A"){
	_WinActivate(twnd)
	Send, !#w
}
; 指定コマンドを実行
_Run(runapp, option="", runcmd=""){
	Run, %runapp% %option%,, %runcmd%
}
; 指定コマンドを実行、終了までウェイト
_RunWait(runapp, option="", runcmd=""){
	RunWait, %runapp% %option%,, %runcmd%
}
; 指定コマンドを作業フォルダを指定して実行
_RunIn(runapp, option="", runcmd="", dir=""){
	If (dir="")
		dir := _FileGetDir(runapp)
	Run, %runapp% %option%, %dir%, %runcmd%
}
; 指定ファイルをポチエスに渡して実行 [ポチエス]
_PochiS(target){
	If (target != "")
		IfExist, %target%
			_RunIn("..\esExt5\esExt5.exe", _WQ( _RelToAbs(target) ) )
}
; 指定ファイルをEmEditorで開く [EmEditor]
_EmEditor(target, line=""){
	Loop, parse, target, `n, `r
	{
		if (A_LoopField = "")
			continue
		
		IfExist, %A_LoopField%
		{
			path := _WQ( _RelToAbs(A_LoopField) )
			If (line)
				line := "/l " . line
			option := _OptionCombine( path, line )
			_RunIn("..\EmEditor_Portable\EmEditor.exe", option )
		}
	}
}
; スタンドアロンでAHK関数を実行
_AHK_SA(function, args*){
	_AHK("AHK_StandAlone",, function, args*)
}
; ツールチップを指定時間のみ表示
_ToolTip(target, interval=1000){
	_AHK_SA("_ToolTip_Main", target, interval)
}
; AHKスクリプト実行
_AHK(fname, wait="", args*){
	IfNotInString, fname, \
		script := "util\" fname ".ahk"
	Else
		script := _RelToAbs(fname)
	
	option := _OptionCombine(args*)
	If (wait)
		_RunWait("AutoHotKey.exe", script " " option)
	Else
		_Run("AutoHotKey.exe", script " " option)
}
; 指定のAHK関数を実行
_ExecFunc(function, args*){
	
	; 関数が不存在ならエラー
	If ( !IsFunc(function) )
		throw Exception("指定した関数は存在しません : _ExecFunc(""" function """).")
	
	; クラス関数なら引数の先頭にダミーを追加
	If ( IfInString(function, ".") )
		args.Insert(1, "")
	
	; 引数の数量チェック
	receivedArgs := args.maxIndex() ? args.maxIndex() : 0
	needArgs     := IsFunc(function) - 1
	If ( receivedArgs < needArgs )
		throw Exception("引数の指定が不足しています : _ExecFunc(""" function """).")
	
	; 関数の実行結果を返り値に
	return Func(function).(args*)
}
