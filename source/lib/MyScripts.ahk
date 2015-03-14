;-------------------------------------------
; その他自作関数ライブラリ
; by akatubame
;-------------------------------------------
;
;-------------------------------------------

; 指定テキストで「OK」or「NO」を選択するメッセージボックスを表示
_IfMsgBox(text){
	MsgBox, 4,, %text%
	IfMsgBox, No
		return 0
	Else
		return 1
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
	While (OutputVar == "" && Repeat!="") {
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
; 指定画像ファイルをtransfer.shへアップロード
_UploadImageToTransferSh(file, newName=""){
	
	; アップロード後の指定ファイル名を整形。未指定なら元画像のMD5を使用
	If (newName != "")
		newName := _OptimizeNameUpl(newName)
	Else
		newName := _HashGetMD5(file) "." _FileGetExt(file)
	
	; 画像のバイナリデータを読込
	img := ComObjCreate("WIA.ImageFile")
	img.LoadFile(file)
	postdata := img.filedata.binarydata
	
	; 画像のアップロード
	WinHttpReq := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	WinHttpReq.Open("PUT", "https://transfer.sh/" newName)
	Try
		WinHttpReq.Send(postdata)
	Catch, e
		throw Exception(file "のアップロードに失敗しました：" e)
	
	; アップロード画像のURLを取得
	imgURL := WinHttpReq.ResponseText
	imgURL := RegExReplace(imgURL, "(?:\n|\r)$", "")
	
	return imgURL
}
; 指定文字列 or ファイルから各種ハッシュ文字列を取得
_HashGet(target, Hashname){
	If (target=="")
		return
	
	If ( IfExist(target) )
		FileHashCMS(target, CRC, MD5, SHA)
	Else
		StrHashCMS(target, CRC, MD5, SHA)
	
	return Hashname=="CRC" ? CRC : Hashname=="MD5" ? MD5 : Hashname=="SHA" ? SHA : ""
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
		default := (PassExt == 1) ? _FileGetNoExt(fname) : _FileGetName(fname)
		newName := (newName != "") ? newName : _Inputbox("ファイル名の変更", "変更後のファイル名を入力", default)
		
		If (Attrib == "D")
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
		If (Attrib == "D")
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
		
		If (Attrib == "D")
			FileRemoveDir, %fname%, 1
		Else
			FileDelete, %fname%
		
		return ErrorLevel
	}
	Else
		return 0
}
; 指定ワードを内容に持つファイルを新規作成 ( data=書き込む内容, fname=生成するファイル, enc=文字コード )
_FileNewAppend(data, fname, enc=""){
	FileDelete, %fname%
	FileAppend, %data%, %fname%, %enc%
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
		While (SubStr(Field,1,IndentLen) == Indent) {
			StringTrimLeft, Field, Field, %IndentLen%
			CurLevel++
		}
		
		EqualPos := InStr(Field, Equal)
		if (EqualPos == 0)
			k := Field
		else
			k := SubStr(Field, 1, EqualPos-1), v := SubStr(Field, EqualPos+1)
		
		k := Trim(k, " `t`r"), v := Trim(v, " `t`r")
		kn[CurLevel] := k
		if !(EqualPos == 0)
		{
			if (CurLevel == 1)
			obj[kn.1] := v
			else if (CurLevel == 2)
			obj[kn.1][k] := v
			else if (CurLevel == 3)
			obj[kn.1][kn.2][k] := v
			else if (CurLevel == 4)
			obj[kn.1][kn.2][kn.3][k] := v
			else if (CurLevel == 5)
			obj[kn.1][kn.2][kn.3][kn.4][k] := v
			else if (CurLevel == 6)
			obj[kn.1][kn.2][kn.3][kn.4][kn.5][k] := v
			else if (CurLevel == 7)
			obj[kn.1][kn.2][kn.3][kn.4][kn.5][kn.6][k] := v
		}
		else
		{
			if (CurLevel == 1)
			obj.Insert(kn.1,Object())
			else if (CurLevel == 2)
			obj[kn.1].Insert(kn.2,Object())
			else if (CurLevel == 3)
			obj[kn.1][kn.2].Insert(kn.3,Object())
			else if (CurLevel == 4)
			obj[kn.1][kn.2][kn.3].Insert(kn.4,Object())
			else if (CurLevel == 5)
			obj[kn.1][kn.2][kn.3][kn.4].Insert(kn.5,Object())
			else if (CurLevel == 6)
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
; 指定文字列を、指定区切り記号ごとに分解後オブジェクト配列に格納
_StringSplit(InputVar, Delimiters, OmitChars=""){
	StringSplit, Array, InputVar, %Delimiters%, %OmitChars%
	Obj := []
	Loop {
		p := Array%A_Index%
		If (p == "")
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
			_AddLine(str, SplitChar . A_LoopField)
	return str
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
; 指定文字列の行数を取得
_CountLines(str){
	StringReplace, str, str, `n, `n, UseErrorLevel
	Return ErrorLevel + 1
}
; 指定文字列から無駄なスペースや改行を取り除く
_RemoveSpace(str){
	str := StringReplace(str, """""", , "All")
	str := StringReplace(str, "　", A_Space, "All")
	str := StringReplace(str, "`r", , "All")
	str := StringReplace(str, "`n", , "All")
	str := RegExReplace(str, " +", " ")
	str := RegExReplace(str, "^\s", "")
	str := RegExReplace(str, "\s$", "")
	return str
}
; 指定文字列から複数改行を単改行に変換
_RemoveIndent(str){
	result := ""
	Loop, Parse, str, `n, `r
	{
		If (A_LoopField=="")
			Continue
		
		_AddLine(result, A_LoopField)
	}
	result := RegExReplace(result, "(?:\n|\r)$", "")
	return result
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
_OptimizeChar(str){
	str := _ListReplace(str,, A_Init_Object["OptimizeReplace"])
	str := _ListReplaceRegex(str,, A_Init_Object["OptimizeRegex"])
	str := _RemoveSpace(str)
	return str
}
; 指定文字列をファイル名に適した文字列に整形する
_OptimizeName(str){
	str := _OptimizeChar(str)
	str := _ListReplace(str,, A_Init_Object["OptimizeName"])
	str := _RemoveIllegalChar(str)
	return str
}
; 指定ファイル名をアップロードに適した文字列に整形する
_OptimizeNameUpl(str){
	str := _RegExEscapeZenkaku(str)
	str := _ListReplace(str,, A_Init_Object["OptimizeNameUpl"])
	return str
}
; 指定文字列から全角文字を消去
_RegExEscapeZenkaku(Target){
	return RegExReplace(Target, "[^\x20-\x7e]", "")
}
; 指定文字列から、指定正規表現でマッチした行のみ抽出
_RegexExtract(target, Pattern=""){
	If (!target)
		return
	If (!Pattern)
		Pattern := _Inputbox("指定正規表現でマッチした行を抽出", "正規表現を入力してください",,, "Repeat")
	
	Loop, parse, target, `n, `r
		If ( RegExMatch(A_LoopField, Pattern) )
			_AddLine(str, A_LoopField)
	
	return str
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
			_AddLine(str, target)
		}
	
	return str
}
; 指定文字列からURLを抽出
_URLExtract(str){
	;str := _RegexExtractReplace(str, "^.*(ttps?:\/\/[-_.!~*\'()a-zA-Z0-9;\/?:&=+\`$,`%#]+).*$", "h$1")
	str := _RegexExtract(str, "(ttps?:\/\/[-_.!~*a-zA-Z0-9\/?&=+\`$,`%#]+)")
	;str := _StringSplitCombine(str, "://")
	str := _RegexExtractReplace(str, "^.*ttp(s?:\/\/[-_.!~*a-zA-Z0-9\/?&=+\`$,`%#]+).*$", "http$1")
	str := _RemoveIndent(str)
	return str
}
; 指定ディレクトリを基準とした相対パスを絶対パスに変換
_RelToAbs_From(root, dir, s = "\"){
	; 既に絶対パスなら処理せず返す
	If ( _FileGetDrive(dir) )
		return dir

	pr := SubStr(root, 1, len := InStr(root, s, "", InStr(root, s . s) + 2) - 1)
		, root := SubStr(root, len + 1)
	If InStr(root, s, "", 0) == StrLen(root)
		root := StringTrimRight(root, 1)
	If InStr(dir, s, "", 0) == StrLen(dir)
		dir := StringTrimRight(dir, 1)
	sk := 0
	Loop, Parse, dir, %s%
	{
		If A_LoopField == ..
		{
			StringLeft, root, root, InStr(root, s, "", 0) - 1
			sk += 3
		}
		Else If A_LoopField == .
			sk += 2
		Else If A_LoopField == ""
		{
			root =
			sk++
		}
	}
	dir := StringTrimLeft(dir, sk)
	
	Abs := pr . root . s . dir
	If InStr(Abs, s, "", 0) == StrLen(Abs)
		Abs := StringTrimRight(Abs, 1)
	
	Return, Abs
}
; AHK本体を基準とした相対パスを絶対パスに変換
_RelToAbs(Path){
	return % _RelToAbs_From(A_WorkingDir, Path, "\")
}
; 指定文字列を指定リスト(置換前と後の文字列一覧)を参照して一括置換
_ListReplace(str, list="", ruleText=""){
	replaceRule := ruleText
	If ( replaceRule=="" ) {
		list        := IfExist(list) ? list : _FileSelectFile("replace", "置換リストを開く", "テキストドキュメント (*.txt)")
		replaceRule := FileRead(list)
	}
	
	Loop, parse, replaceRule, `n, `r
	{
		If (A_LoopField == "")
			continue
		
		StringSplit, rule, A_LoopField, %A_Tab%
		l := rule1, r := rule2
		
		str := StringReplace(str, l, r, "All")
	}
	return str
}
; 指定文字列を指定リスト(置換前と後の正規表現一覧)を参照して一括正規置換
_ListReplaceRegex(str, list="", ruleText=""){
	replaceRule := ruleText
	If ( replaceRule=="" ) {
		list        := IfExist(list) ? list : _FileSelectFile("regex", "正規表現リストを開く", "テキストドキュメント (*.txt)")
		replaceRule := FileRead(list)
	}
	
	Loop, parse, replaceRule, `n, `r
	{
		If (A_LoopField == "")
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
