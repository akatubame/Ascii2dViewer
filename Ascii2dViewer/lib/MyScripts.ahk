;-------------------------------------------
; その他自作関数ライブラリ
;-------------------------------------------
;
;-------------------------------------------
;
;-------------------------------------------
; 汎用関数
;-------------------------------------------

; 複数の文字列をハイフン"-"で連結してメッセージボックスに表示
_MsgBox(params*){
	Msg := ""
	For key, value in params
		Msg .= value . " - "
	Msg := StringTrimRight(Msg, 3)
	MsgBox, % Msg
}
; 文字列を入力して変数に取得
_Inputbox(Title="", Prompt="", Default="", Timeout="", Repeat="", HIDE="", Width="", Height="", X="", Y="", Font=""){
	; ダイアログの自動調整
	W := ( Strlen(Default) > StrLen(Prompt) ) ? 150 + 10 * Strlen(Default) : 150 + 10 * StrLen(Prompt)
	H := 140 + 20 * ( (StrLen(Prompt) / 30) - 1 )
	Width  := Width  ? Width  : (W > 400) ? 400 : (W < 200) ? 200 : W
	Height := Height ? Height : (StringGetPos(Prompt, "`n") != -1) ? H + 10 : H
	X      := X      ? X      : (A_ScreenWidth  - Width)  / 2
	Y      := Y      ? Y      : (A_ScreenHeight - Height) / 2
	
	InputBox, OutputVar, %Title%, %Prompt%, %HIDE%, %Width%, %Height%, %X%, %Y%,, %Timeout%, %Default%
	If (!ErrorLevel) {
		While (OutputVar = "" && Repeat!="") {
			InputBox, OutputVar, %Title%, %Prompt%, %HIDE%, %Width%, %Height%, %X%, %Y%,, %Timeout%, %Default%
			If (ErrorLevel)
				Exit
		}
		return OutputVar
	}
	Else
		Exit
}
; AHK再起動＆エラー確認
_Reload(){
	Reload
	WinWait, ahk_class #32770, Error at line , 2
	If ErrorLevel=0
	{
		ErrorMessage := ControlGetText("Static1")
		RegExMatch(ErrorMessage, "Error at line (\d+)", line)
		RegExMatch(ErrorMessage, "include file \W(\S+)\W\.", fname)
		IfExist, %fname1%
			_EmEditor(fname1, line1)
		WinWaitNotActive,, 2
		WinActivate
	}
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
; 指定ファイル(複数可)を、指定サーバへFTP接続でアップロード
_FTP_FileUpload(target, dir="", Server="", User="", Password=""){
	If (!target)
		return
	
	Server   := (Server   != "") ? Server   : _DeWQ(A_FTP_Server)
	User     := (User     != "") ? User     : _DeWQ(A_FTP_User)
	Password := (Password != "") ? Password : _DeWQ(A_FTP_Password)
	
	ftp := new FTP()
	ftp ? : _MsgBoxExit("Could not load module/InternetOpen")
	ftp.Open(Server, User, Password) ? "" : _MsgBoxExit(ftp.LastError)
	
	If (dir != "")
		ftp.SetCurrentDirectory(dir) ? : _MsgBoxExit(ftp.LastError)
	
	Loop, parse, target, `n, `r
	{
		If (A_LoopField = "")
			continue
		
		fname := _OptimizeNameUpl( _FileGetName(A_LoopField) )
		ftp.PutFile(A_LoopField, fname) ? : _MsgBoxExit(ftp.LastError)
	}
	
	;ftp := ""
}
; 指定ファイル(複数可)を、指定サーバからFTP接続で削除
_FTP_FileDelete(target, dir="", Server="", User="", Password=""){
	If (!target)
		return
	
	Server   := (Server   != "") ? Server   : _DeWQ(A_FTP_Server)
	User     := (User     != "") ? User     : _DeWQ(A_FTP_User)
	Password := (Password != "") ? Password : _DeWQ(A_FTP_Password)
	
	ftp := new FTP()
	ftp ? : _MsgBoxExit("Could not load module/InternetOpen")
	ftp.Open(Server, User, Password) ? : _MsgBoxExit(ftp.LastError)
	
	If (dir != "")
		ftp.SetCurrentDirectory(dir) ? : _MsgBoxExit(ftp.LastError)
	
	Loop, parse, target, `n, `r
	{
		If (A_LoopField = "")
			continue
		
		ftp.DeleteFile(A_LoopField) ? : _MsgBoxExit(ftp.LastError)
	}
	
	;ftp := ""
}
; 指定URL(複数可)をダウンロード
_DownloadURLs(target){
	target := _URLExtract(target)
	Loop, parse, target, `n, `r
	{
		If (A_LoopField = "")
			continue
		
		_AddLine(urls, A_LoopField)
		c++
	}
	If (c!=0 && _IfMsgBox(urls "`nこれら" c "個のURLをダウンロードしますか？") ) {
		Loop, parse, urls, `n, `r
		{
			name := _OptimizeName( _FileGetName(A_LoopField) )
			URLDownloadToFile(A_LoopField, A_ClipFolder "\" name)
		}
	}
}
; 指定ドキュメントをXML_DOMオブジェクトに取得
_loadXML(ByRef data){
	doc := ComObjCreate("MSXML2.DOMDocument.6.0")
	doc.async := false
	doc.loadXML(data)
	return doc
}
; 指定ドキュメントをHTML_DOMオブジェクトに取得
_loadHTML(ByRef data, non_xpath=""){
	doc := ComObjCreate("HTMLfile")
	doc.write(data)
	
	; XPath操作関数を付加
	If (!non_xpath) {
		scr      := doc.createElement("script")
		scr.src  := _RelToAbs(A_Lib_Xpath)
		scr.type := "text/javascript"
		doc.getElementsByTagName("head")[0].appendChild(scr)
	}
	return doc
}
; 指定ドキュメントからXPathで指定ノードを取得
_XPath(doc, xpath){
	result := doc.evaluate(xpath, doc, null, 7, null)
	return result
}
; 指定ドキュメントからXPathで指定ノードの一つ目の要素を取得
_XPathGetItem(doc, xpath){
	result := doc.evaluate(xpath, doc, null, 7, null)
	return result.snapshotItem[0]
}
; 指定ドキュメントから各種メソッドでエレメントを取得
_GetElementsBy(doc, method, target="*"){
	e   := Object()
	obj := Object()
	
	If (method = "tag")
		obj := doc.getElementsByTagName(target)
	Else If (method = "id")
		obj := _GetElementsById(doc, target)
	Else If (method = "name")
		obj := doc.getElementsByName(target)
	Else If (method = "class")
		obj := _GetElementsByClassName(doc, target)
	
	return obj
}
; 指定ドキュメントからIDでエレメントを取得
_GetElementsById(doc, targetId){
	e   := Object()
	obj := Object()
	
	if (doc.all)
		e := doc.all
	else
		e := doc.getElementsByTagName("*")
	
	e := _ElementsToObj(e)
	for i in e {
		If (e[i-1].id = targetId)
			return e[i]
	}
	return
}
; 指定ドキュメントからクラス名でエレメントを取得
_GetElementsByClassName(doc, targetClass){
	e   := Object()
	obj := Object()
	
	if (doc.all)
		e := doc.all
	else
		e := doc.getElementsByTagName("*")
	
	i:=0, j:=0
	Loop, % e.length
	{
		if (e[i].className = targetClass) {
			obj[j] := e[i]
			j++
		}
		i++
	}
	
	return obj
}
; 指定ドキュメントからエレメントを指定してオブジェクトに格納して取得
_ElementsToObj(e){
	obj  := Object()
	flag := 0
	
	Loop, % e.length
	{
		flag := 1
		obj[A_Index-1] := e[A_Index-1]
	}
	return flag ? obj : e
}

;-------------------------------------------
; ファイル操作関数
;-------------------------------------------

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
; 指定ファイルが存在すれば指定先へ移動してフラグを返す
_FileMove(Source, Dest, flag=0){
	Attrib := FileExist(Source)
	If (Attrib)
	{
		If (Attrib = "D")
			FileMoveDir, %Source%, %Dest%, %flag%
		Else
			FileMove, %Source%, %Dest%, %flag%
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
; 指定画像の縦横ピクセルSizeを取得
_FileGetPixel(path){
	obj  := Object()
	size := FGP_Value(path, 31)
	p    := _StringSplit(size, "x", " ")
	
	obj.width  := StringTrimLeft(p[1], 1)
	obj.height := StringTrimRight(p[2], 1)
	return obj
}
; 指定ディレクトリ直下(Recurseなら階層下)のファイル・フォルダをすべて取得
_GetDirFiles(TargetDir, IncludeMode="", Recurse=""){
	IncludeFolders := (IncludeMode  = "D") ? 1 : 0
	Recurse        := (Recurse     != "" ) ? 1 : 0
	Loop, %TargetDir%\*.*, %IncludeFolders%, %Recurse%
		_AddLine(files, A_LoopFileFullPath)
	return files
}
; 指定ファイルの生成を待機
_FileLoopWait(file, count=30){
	Loop, %count%
	{
		Sleep, 100
		If ( IfExist(file) )
			return 1
	}
	return 0
}
; 指定フォーマットの文字列をオブジェクトに格納
_ObjFromStr(String, Rows="`n", Equal="=", Indent="`t"){
	obj := Object(), kn := Object()
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

;-------------------------------------------
; 文字列・クリップボード操作関数
;-------------------------------------------

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
; 選択文字列をカット＆クリップボードへ
_ClipCut(time=0.1){
	Clipboard := ""
	Send, ^x
	ClipWait, %time%
}
; 選択ワードor選択ファイルを返す
_Selected(time=0.1){
	bk := ClipboardAll
	_ClipCopy(time)
	Ret := Clipboard
	Clipboard := bk
	return Ret
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
; 一行カット
_LineCut(){
	_ClipCut()
	If (Clipboard = "")
	{
		Send, {End}+{Home}
		Send, ^x{Left}
	}
}
; 一行コピー
_LineCopy(){
	_ClipCopy()
	If (Clipboard = "")
	{
		Send, {End}+{Home}
		Send, ^c
	}
}
; 一行選択
_LinePaste(){
	Send, {End}+{Home}^v
}
; 一行削除
_LineDelete(){
	Send, {End}+{Home}
	Send, {Delete}
}
; 選択行を一行上に送る
_LineUp(){
	_LineCut()
	Sleep, 10
	Send, {Up}^v{Up}
	return
}
; 選択行を一行下に送る
_LineDown(){
	_LineCut()
	Sleep, 10
	Send, {Down}^v{Up}
	return
}
; 指定文字列を貼り付け
_HotString(target){
	bk := ClipboardAll
	_Clip(target)
	Sleep, 100
	Send, ^v
	Clipboard := bk
}
; 選択文字列を指定キーワードで挟み込み
_SandString(start,end){
	target := _Selected()
	If (target != "")
		str := start . target . end
	else
		str := start . end
	_Hotstring(str)
}
; クリップボード文字列を指定キーワードで挟み込み
_ClipSandString(start,end){
	str := start . clipboard . end
	_Hotstring(str)
}
; 指定文字列の末尾へ行を追加
_AddLine(ByRef target, line){
	target .= line "`n"
}
; 指定文字列を指定関数で整形後ペースト
_FuncAndPaste(target, function, params*){
	text := Func(function).(target, params*)
	_HotString(text)
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
; 指定文字列をエスケープ済みダブルクォーテーション[\"\"]で囲む
_WQE(str){
	If (str="")
		return
	
	StringLeft,  left,  str, 1
	StringRight, right, str, 1
		StringGetPos, start, str, ", L
	If (ErrorLevel = 0) {
		StringLen, Length, str
		StringGetPos, end, str, ", R
		If (start = 0 && end = Length-1) {
			str = \%str%\
			return str
		}
	}
	str = \"%str%\"
	return str
}
; 指定文字列のダブルクォーテーション[""]の囲みを削除
_DeWQ(str){
	StringGetPos, start, str, ", L
	If (ErrorLevel = 0) {
		StringLen, Length, str
		StringGetPos, end, str, ", R
		If (start = 0 && end = Length-1) {
			str := StringTrimLeft(str, 1)
			str := StringTrimRight(str, 1)
		}
	}
	return str
}
; 指定文字列を、指定区切り記号ごとに分解後オブジェクト配列に格納
_StringSplit(InputVar, Delimiters, OmitChars=""){
	StringSplit, Array, InputVar, %Delimiters%, %OmitChars%
	Obj := Object()
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
_StringCombine(Delimiters, params*){
	str    := ""
	Length := StrLen(Delimiters)
	
	For key, value in params
		str .= value . Delimiters
	str := StringTrimRight(str, Length)
	return str
}
; 指定コマンドラインオプション(複数)をダブルクォーテーション[""]で囲み連結
_OptionCombine(params*){
	option := ""
	For key, value in params
		option .= _WQ(value) . " "
	option := StringTrimRight(option, 1)
	return option
}
; 指定文字列中の全角英数字を半角に変換
_StringConvZ2H(str){
	obj := A_Init_Object["Z2HTable"]
	for z,h in obj
		str := StringReplace(str, z, h, "All")
	return str
}
; 指定文字列から対象ワードを取り除く
_RemoveText(text, target){
	text := StringReplace(text, target, "", "All")
	return text
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
; 指定ファイル名をアップロードに適した文字列に整形する
_OptimizeNameUpl(text){
	text := _RegExEscapeZenkaku(text)
	text := _ListReplace(text,, "OptimizeNameUpl")
	return text
}
; 指定文字列から正規表現パターンをエスケープ
_RegExEscape(target){
	return _ListReplace(target,, "RegExEscape")
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
; 指定文字列をURLエンコード (enc=文字コード指定[1=Shift_JIS 2=EUC-JP 3=UTF-8 4=JIS 空=すべて])
_URLEncode(Str, Enc=""){
	option := _OptionCombine(str, enc)
	;stdout := _PHP("PHP\urlencode.php", "STDOUT", option )
	stdout := _RunStdOut("PHP\urlencode.exe", option )
	return stdout
}
; 指定文字列をURLデコード(半角記号のみ)
_URLDecode(str, enc=3){
	enc := _EncModeSwitch(enc)
	Pos := 1
	Loop
	{
		Pos := RegExMatch(str, "i)(?:%[\da-f]{2})+", Code, Pos++)
		If (Pos = 0)
			Break
		VarSetCapacity(var, StrLen(Code) // 3, 0)
		StringTrimLeft, Code, Code, 1
		Loop, Parse, Code, `%
			NumPut("0x" . A_LoopField, var, A_Index - 1, "UChar")
		StringReplace, str, str, `%%Code%, % StrGet(&var, enc), All
	}
	Return, str
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


;-------------------------------------------
; オブジェクト操作関数
;-------------------------------------------

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

;-------------------------------------------
; ウィンドウ操作関数
;-------------------------------------------

; 指定ウィンドウの各種情報を取得
_WinGet(Cmd = "", twnd="A"){
	WinGet, v, %Cmd%, %twnd%
	Return, v
}
; 指定ウィンドウの可視・不可視テキストを取得
_WinGetText(twnd="A"){
	WinGetText, text, %twnd%
	Return, text
}
; 指定ウィンドウのIDを取得
_WinGetId(twnd="A"){
	WinGet, id, ID, %twnd%
	return id
}
; 指定ウィンドウのウィンドウクラスを取得
_WinGetClass(twnd="A"){
	WinGetClass, Class, %twnd%
	return Class
}
; 指定ウィンドウのウィンドウタイトルを取得
_WinGetTitle(twnd="A"){
	WinGetTitle, Title, %twnd%
	return Title
}
; 指定ウィンドウを閉じる
_WinClose(twnd="A"){
	WinClose, %twnd%
}
; 指定ウィンドウが表示されるまで待機
_WinWait(twnd="A", Seconds=0.5, STOP=""){
	Seconds := (STOP != "") ? "" : Seconds
	WinWait, %twnd%,, %Seconds%
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
; 指定ウィンドウを無理やりトレイアイコンに最小化
_WinMinimizeTray(twnd="A"){
	_WinActivate(twnd)
	Send, !#w
}
; 指定ウィンドウを最大化
_WinMaximize(twnd="A"){
	WinMaximize, %twnd%
}
; 指定ウィンドウへ指定ファイル(複数可)をドロップ (ptX,ptY : 落とす座標, fNC: 真なら絶対座標/偽なら相対)
_DropFiles(target, hwnd="", ptX=0, ptY=0, fNC=False){
	If (!hwnd)
		hwnd := _WinGetId()
	Loop, parse, target, `n, `r
		_AddLine(files, A_LoopField)
	
	char_type:= A_IsUnicode ? "UShort" : "UChar", char_size := A_IsUnicode ? 2 : 1, isUnicode := A_IsUnicode ? 1 : 0
	files := RTrim(files, "`r`n`t ") . "`n`n"
	byte_length := StrLen(files) * char_size
	Loop, Parse, files
		If (A_LoopField = "`n")
			NumPut(0x00, files, (A_Index-1) * char_size, char_type)
	hDrop := DllCall("GlobalAlloc", "UInt", 0x42, "UInt",20 + byte_length, "Ptr")
	p := DllCall("GlobalLock", "Ptr", hDrop)
	NumPut(20 , p + 00, "Int") ; offset
	NumPut(ptX , p + 04, "Int") ; pt.x
	NumPut(ptY , p + 08, "Int") ; pt.y
	NumPut(fNC , p + 12, "Int") ; fNC
	NumPut(isUnicode, p + 16, "Int") ; fWide
	DllCall("RtlMoveMemory", "Ptr", p + 20, "Str", files, "UInt", byte_length)
	DllCall("GlobalUnlock", "Ptr", hDrop)
	PostMessage, WM_DROPFILES := 0x233, hDrop , 0, , ahk_id %hwnd%
}
; 指定コントロールのハンドルを取得する
_ControlGetID(ClassNN, WinTitle="A"){
	ControlID := ControlGet("Hwnd",, ClassNN, WinTitle)
	return ControlID
}
; 指定コントロールをバックグラウンドでクリック
_ControlClickNA(Control, WinTitle="A", WinText="", WhichButton="", ClickCount=""){
	ControlClick(Control, WinTitle, WinText, WhichButton, ClickCount, "NA")
}
; マウスカーソル下ウィンドウのウィンドウハンドル(ID)を取得
_MouseGetTwnd(){
	MouseGetPos,,, id
	twnd := "ahk_id " . id
	return twnd
}
; マウスカーソル下ウィンドウのコントロールを取得
_MouseGetControl(){
	MouseGetPos,,,, ClassNN
	return ClassNN
}

;-------------------------------------------
; タスク操作関数
;-------------------------------------------

; 指定コマンドを実行
_Run(runapp, option="", runcmd=""){
	Run, %runapp% %option%,, %runcmd%
}
; 指定コマンドを作業フォルダを指定して実行、標準出力(STDOUT)を取得
_RunStdOut(runapp, option="", dir=""){
	runapp := _RelToAbs(runapp)
	If (dir="")
		dir := _FileGetDir(runapp)
	WDir := A_WorkingDir
	SetWorkingDir, %dir%
	
	stdout := _WSHExec(runapp . " " . option)
	
	SetWorkingDir, %WDir%
	return, stdout
}
; 指定ウィンドウが存在しなければ指定コマンドを実行
_RunIfNoWindow(twnd, runapp, option="", runcmd=""){
	IfWinNotExist, %twnd%
	{
		_RunIn(runapp, option, runcmd)
		return 1
	}
	else
		return 0
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

;-------------------------------------------
; 検索関数
;-------------------------------------------

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

