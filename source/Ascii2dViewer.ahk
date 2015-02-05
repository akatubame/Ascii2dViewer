#Persistent
#SingleInstance, Force
;#NoTrayIcon

#Include *i <CommonHeader>
#Include *i <PersistentHeader>

; このアプリ専用のグローバル変数の格納オブジェクト生成
global A_Init_Object
global io := A_Init_Object["Ascii2dViewer"] := Object()

;-------------------------------------------
; 初期設定
;-------------------------------------------

; 関連ファイルのパスを指定
io.IniFile       := A_ScriptDir "\" "Ascii2dViewer.ini"
io.HotkeyFile    := A_ScriptDir "\" "Hotkey.ini"
io.MenuFile      := A_ScriptDir "\" "Menu.ini"
io.DefList       := A_ScriptDir "\" "DefaultDetailList.ini"
io.BlankImage    := A_ScriptDir "\" "black.gif"
io.ImgDir        := A_ScriptDir "\" "image" "\"
io.LogDir        := A_ScriptDir "\" "log"   "\"
io.ThumbDir      := A_ScriptDir "\" "thumb" "\"
Menu, Tray, Icon, % A_ScriptDir "\" "Ascii2dViewer.ico"

; 各種グローバル変数の設定
io.PostUri := "http://www.ascii2d.net/imagesearch/search"
io.GetUri  := "http://www.ascii2d.net/imagesearch/similar/"

; 各種テーブル設定を読みこみ
A_Init_Object["Ascii2dGetUrl"] := FileRead("regex\Ascii2dGetUrl.txt")
A_Init_Object["Ascii2dMD5"]    := FileRead("regex\Ascii2dMD5.txt")
A_Init_Object["Ascii2dThumb"]  := FileRead("regex\Ascii2dThumb.txt")
A_Init_Object["Ascii2dXhtml"]  := FileRead("regex\Ascii2dXhtml.txt")
A_Init_Object["Ascii2dRename"] := FileRead("regex\Ascii2dRename.txt")

; 動作順序の定義
Gosub, Init
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
	io.MN      := _ObjFromFile(io.MenuFile)
	io.ctr     := GetCtrAll()
	io.ThisGui := ""
	
	Gosub, Menu_Build
	Gosub, Hotkey_Build
	
	For key in io.Gui {
		io.ThisGui := io.Gui[key]
		GoSub, GUI_Build
	}
	For key in io.Gui {
		GUI_Show(io.Gui[key])
	}
	
	A2_DetailClear("Init")
	SB_SetText("読込終了", 1, 2)
return


;-------------------------------------------
; 制御ルーチン
;-------------------------------------------

; イベント振分け処理
Event:
	; 項目をクリックした時のイベント
	If (A_GuiEvent = "Normal") {
		
		If (A_GuiControl = "ImageList") {
			Gosub, A2_ExpandFocus
		}
		Else If (A_GuiControl = "DetailList") {
			Gosub, A2_DetailFocus
		}
	}
	; 項目をダブルクリックした時のイベント
	Else If (A_GuiEvent = "DoubleClick") {
		
		If (A_GuiControl = "ImageList") {
			Gosub, A2_OpenFocus
		}
		Else If (A_GuiControl = "DetailList") {
			Gosub, A2_RenameFocus_LineCopy
		}
	}
	
	; 項目を矢印上下キーで移動した時のイベント
	Else If (A_GuiEvent = "K") {
		
		For i,key in [33, 34, 35, 36, 38, 40] {
			If (A_EventInfo = key) {
				If (A_GuiControl = "ImageList") {
					Gosub, A2_ExpandFocus
				}
				Else If (A_GuiControl = "DetailList") {
					Gosub, A2_DetailFocus
				}
			}
		}
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
	;Gosub, SetUp
	; 最小化
	If (A_EventInfo = 1) {
		return
	}
	; それ以外
	Else {
		ctr := GetCtrFromOption("CtrName", A_GuiControl)
		For key in ctr
			CTL_Size(ctr)
	}
return

; ウィンドウを閉じた時のイベント
GuiClose:
GuiEscape:
	GUI_MinimizeTray(A_Gui)
	;GUI_Hide(A_Gui)
return

; 右クリックメニュー時のイベント
GuiContextMenu:
	; 各種コンテキストメニュー表示
	If (A_GuiControl = "ImageList") {
		Menu, ImageListContextMenu, Show
	}
	Else If (A_GuiControl = "DetailList") {
		Menu, DetailListContextMenu, Show
	}
	Else {
		Menu, MyContextMenu, Show
	}
return

; ファイルのD&D処理
GuiDropFiles:
	If (!A_EventInfo)
		Return
	files := A_GuiEvent
	A2_MainDL_Drop(files)
return


;-------------------------------------------
; ホットキーイベント定義
;-------------------------------------------

; 選択画像の詳細情報を展開
A2_ExpandFocus:
	Gosub, SetUp
	A2_ExpandFocus()
return

; 選択した詳細情報をHTMLビュー
A2_DetailFocus:
	Gosub, SetUp
	A2_DetailFocus()
return

; 選択画像の詳細情報を削除
A2_DeleteFocus:
	Gosub, SetUp
	A2_DeleteFocus()
return

; 選択画像を開く
A2_OpenFocus:
	Gosub, SetUp
	A2_OpenFocus()
return

; 選択画像のURLをコピー
A2_GetUrlFocus:
	Gosub, SetUp
	A2_GetUrlFocus()
return

; 詳細情報をすべて削除
A2_DeleteAll:
	Gosub, SetUp
	A2_DeleteAll()
return

; メインDL処理
A2_MainDL:
A2_MainDL2:
	A2_MainDL()
return

; クリップボードURLで詳細検索
A2_MainDL_Clip:
A2_MainDL_Clip2:
	A2_MainDL_Clip()
return

; ファイルダイアログで詳細検索
A2_MainDL_SelectFile:
	A2_MainDL_SelectFile()
return

; 選択ファイル or クリップボードのファイルで詳細検索
A2_MainDL_ClipDrop:
	A2_MainDL_Drop( _SelectedOrClipboard() )
return

; 元画像のリネーム
A2_RenameFocus:
	A2_RenameFocus()
return
A2_RenameFocus_Clip:
	A2_RenameFocus_Clip()
return
A2_RenameFocus_LineCopy:
	A2_RenameFocus_LineCopy()
return


;-------------------------------------------
; 関数
;-------------------------------------------

;--- 汎用関数 ---;

A2_Gui_ImageChange(t, path){
	path := FileExist(path) ? path : io.BlankImage
	Gui_ImageChange(t, path)
}
A2_DetailClear(Init=""){
	t := io.ctr.DetailList
	
	t.ItemListPath := io.DefList
	FileToList(t)
	CTL_LST_Build(t)
	
	A2_Gui_ImageChange(io.ctr.DetailImage, io.BlankImage)
	A2_Gui_ImageChange(io.ctr.SourceImage, io.BlankImage)
	
	If ( !Init )
		io.ctr.DetailView.doc.all["id"].innerhtml := ""
}

;--- イベント関数 ---;

A2_ExpandFocus(){
	t    := io.ctr.ImageList
	list := t.ItemObj.ItemList
	md5  := GetFocus(t, 3)
	If (!md5)
		return 1
	
	ID  := TV_GetIDFromValue(md5, list, "md5")
	log := io.LogDir . md5 . ".ini"
	io.ctr.DetailList.ItemListPath := log
	FileToList(io.ctr.DetailList)
	dlist := io.ctr.DetailList.ItemObj.ItemList
	
	SourceImage := list[ID].SourceImage
	first       := dlist[1]
	thumb       := first.thumb
	xhtml       := first.xhtml
	
	io.ctr.DetailView.doc.all["id"].innerhtml := xhtml
	
	A2_Gui_ImageChange(io.ctr.DetailImage, thumb)
	A2_Gui_ImageChange(io.ctr.SourceImage, SourceImage)
	
	CTL_LST_Build(io.ctr.DetailList)
}
A2_DetailFocus(){
	t    := io.ctr.DetailList
	list := t.ItemObj.ItemList
	ID   := GetFocus(t, 1)
	If (!ID)
		return 1
	
	log   := io.LogDir . ID . ".ini"
	thumb := list[ID].thumb
	xhtml := list[ID].xhtml
	
	io.ctr.DetailView.doc.all["id"].innerhtml := xhtml
	
	A2_Gui_ImageChange(io.ctr.DetailImage, thumb)
}
A2_DeleteFocus(){
	t    := io.ctr.ImageList
	list := t.ItemObj.ItemList
	md5  := GetFocus(t, 3)
	If (!md5)
		return 1
	
	ID  := TV_GetIDFromValue(md5, list, "md5")
	log := io.LogDir . md5 . ".ini"
	dir := io.ThumbDir . md5
	SourceImage := list[ID].SourceImage
	list.Remove(ID)
	For k,v in [log, dir, SourceImage]
		_FileDelete(v)
	
	CTL_LST_Build(t)
	LV_Modify(ID, "Vis Select Focus")
	miss := A2_ExpandFocus()
	If (miss=1)
		A2_DetailClear()
}
A2_OpenFocus(){
	t    := io.ctr.ImageList
	list := t.ItemObj.ItemList
	md5  := GetFocus(t, 3)
	If (!md5)
		return 1
	
	ID := TV_GetIDFromValue(md5, list, "md5")
	SourceImage := list[ID].SourceImage
	_PochiS(SourceImage)
}
A2_GetUrlFocus(){
	t    := io.ctr.ImageList
	list := t.ItemObj.ItemList
	md5  := GetFocus(t, 3)
	If (!md5)
		return 1
	
	ID := TV_GetIDFromValue(md5, list, "md5")
	ImageURL := list[ID].ImageURL
	_ClipGet(ImageURL)
}
A2_DeleteAll(){
	If ( !_IfMsgBox("保存された画像＆詳細情報をすべてクリアしますか？") )
		return
	
	t := io.ctr.ImageList
	t.ItemObj.ItemList := Object()
	
	For k,v in [io.ImgDir, io.LogDir, io.ThumbDir] {
		_FileDelete(v)
		FileCreateDir(v)
	}
	CTL_LST_Build(t)
	A2_DetailClear()
}
A2_RenameFocus(){
	A2_Rename("Input")
}
A2_RenameFocus_Clip(){
	newName := _Inputbox("元画像のリネーム", "画像のファイル名を入力", _SelectedOrClipboard())
	A2_Rename(newName)
}
A2_RenameFocus_LineCopy(){
	t    := io.ctr.DetailList
	list := t.ItemObj.ItemList
	ID   := GetFocus(t, 1)
	If (!ID)
		return 1
	
	detail  := list[ID].detail
	detail  := _ListReplaceRegex(detail, "", "Ascii2dRename")
	detail  := _OptimizeName(detail)
	newName := _Inputbox("元画像のリネーム", "画像のファイル名を入力", detail)
	A2_Rename(newName)
}
A2_Rename(newName){
	t    := io.ctr.ImageList
	list := t.ItemObj.ItemList
	md5  := GetFocus(t, 3)
	If (!md5)
		return 1
	
	ID := TV_GetIDFromValue(md5, list, "md5")
	SourceImage := list[ID].SourceImage
	
	newName := (newName!="Input") ? newName : _Inputbox("元画像のリネーム", "画像のファイル名を入力", list[ID].Renamed ? _FileGetNoExt(SourceImage) : "")
	newName := _OptimizeName(newName)
	_FileRename(SourceImage, newName, 1, 1)
	ext := _FileGetExt(SourceImage)
	list[ID].SourceImage := io.ImgDir . newName "." ext
	list[ID].ImageName   := newName
	list[ID].Renamed     := 1
	CTL_LST_Build(t)
	LV_Modify(ID, "Vis Select Focus")
}
A2_MainDL(){
	ImageURL := _Inputbox("二次元画像詳細検索", "取得する画像のURLを入力")
	A2_MainDL_Main(ImageURL)
}
A2_MainDL_Clip(){
	c      := 0
	obj    := Object()
	target := _SelectedOrClipboard()
	
	If ( IfExist(target) )
		A2_MainDL_Drop(target)
	
	target := _URLExtract(target)
	Loop, parse, target, `n, `r
	{
		If (A_LoopField = "")
			return
		ImageURL := A_LoopField
		
		c++
		obj[c] := ImageURL
		_AddLine(imgs, ImageURL)
	}
	If (c!=0 && _IfMsgBox(imgs "`n" c "個のURLを詳細検索しますか？") ) {
		A2_MainDL_Array(c, obj)
		SB_SetText("", 2, 2)
	}
}
A2_MainDL_SelectFile(){
	file := _FileSelectFile("", "詳細検索する画像を選択", "画像ファイル (*.gif;*.jpg;*.jpeg;*.png)")
	A2_MainDL_Drop(file)
}
A2_MainDL_Drop(files){
	c    := 0
	obj  := Object()
	del  := ""
	
	Loop, parse, files, `n, `r
	{
		If (A_LoopField = "")
			return
		
		c++
		name     := _HashGetMD5(A_LoopField) "." _FileGetExt(A_LoopField)
		ImageURL := "http://oteak.xii.jp/image/" name
		dest     := A_ClipFolder . name
		obj[c]   := ImageURL
		
		_AddLine(sources, A_LoopField)
		_AddLine(imgs, name)
		_FileCopy(A_LoopField, dest)
		_AddLine(ClipImgs, dest)
	}
	If (c!=0 && _IfMsgBox(sources "`n" c "個の画像ファイルを詳細検索しますか？") ) {
		SB_SetText("ファイルのアップロード中...", 2, 2)
		_FTP_FileUpload(ClipImgs, "www/oteak/image")
		
		A2_MainDL_Array(c, obj)
		
		SB_SetText("サーバに残ったファイルの削除中...", 2, 2)
		_FTP_FileDelete(imgs, "www/oteak/image")
	}
	
	SB_SetText("一時ファイルの削除中...", 2, 2)
	_FileDeleteArray(ClipImgs,, "NoDialog")
	SB_SetText("", 2, 2)
}
A2_MainDL_Array(max, obj){
	for key,ImageURL in obj {
		SB_SetText(key "/" max "枚目のDL中...", 2, 2)
		A2_MainDL_Main(ImageURL)
		If (key != max) {
			SB_SetText(key "/" max "枚DL完了　次のDLまで5秒待機中...", 2, 2)
			Sleep, 5000
		}
	}
	SB_SetText("", 2, 2)
}
A2_MainDL_Main(ImageURL){
	t    := io.ctr.ImageList
	list := t.ItemObj.ItemList
	
	SB_SetText("詳細リストのダウンロード中...", 1, 2)
	html := _HttpPost(io.PostUri, "uri=" ImageURL)
	doc  := _loadHTML(html)
	e    := _XPath(doc, "//div[@class='box']")
	
	If ( !e.snapshotLength ) {
		io.ctr.DetailView.doc.all["id"].innerhtml := "<h1>エラーが発生しました。存在しないか、処理できないURLです。</h1><br><h2><a href=" ImageURL "/>" ImageURL "</a></h2>"
		SB_SetText("ダウンロード失敗", 1, 2)
		return
	}
	
	SB_SetText("画像サムネイルのダウンロード中...", 1, 2)
	SourceImage := io.ImgDir . _FileGetName(ImageURL)
	URLDownloadToFile(ImageURL, SourceImage)
	If ( FileExist(SourceImage) ) {
		ext       := _FileGetExt(SourceImage)
		SourceMD5 := _HashGetMD5(SourceImage)
		If ( !_FileRename( SourceImage, SourceMD5, 1, 1 ) )
			SourceImage := io.ImgDir . SourceMD5 "." ext
	}
	
	key := _GetMaxIndex(list) + 1
	key := key ? key : 1
	_AddToObj(list, { ID:key, ImageKey:"%key%", md5:SourceMD5, ImageURL:ImageURL, ImageName:ImageURL, SourceImage:SourceImage } )
	CTL_SetActive(t)
	Lv_Add("", key, ImageURL, SourceMD5)
	LV_Modify(key, "Vis Select Focus")
	
	SB_SetText("詳細情報のダウンロード中...", 1, 2)
	CTL_SetActive(io.ctr.DetailList)
	LV_DeleteAll(io.ctr.DetailList)
	
	dir := io.ThumbDir . SourceMD5
	FileCreateDir(dir)
	
	obj := Object()
	obj := _ObjFromFile(io.DefList)
	Loop, % e.snapshotLength
	{
		e2 := e.snapshotItem[A_Index-1]
		
		thumburl := StringReplace( _GetElementsBy(e2, "tag", "img")[0].src, "about:", "http://www.ascii2d.net")
		md5      := _ListReplaceRegex(thumburl, "regex\Ascii2dMD5.txt")
		thumb    := dir "\" _FileGetName(thumburl)
		URLDownloadToFile(thumburl, thumb)
		
		e3     := _GetElementsByClassName(e2, "detail")[0]
		detail := e3.innerText
		xhtml  := e3.innerHTML
		detail := (detail="") ? "＊詳細情報なし" : RegExReplace(detail, "(\n|\r)", "")
		xhtml  := _ListReplaceRegex(xhtml, "regex\Ascii2dXhtml.txt")
		
		e4     := _GetElementsBy(e3, "tag", "a")
		href   := (e4.length) ? StringReplace( e4[0].href, "about:", "http://www.ascii2d.net") : ""
		If (name := _RegExMatch_Get(href, "\/(ch2|moeren)\/")) {
			addLog := _HttpGet(href)
			addDoc := _loadHTML(addLog)
			add    := _GetElementsByClassName(addDoc, name)[0].innerHTML
			add    := _ListReplaceRegex(add, "regex\Ascii2dXhtml.txt")
			xhtml  .= "<br>" add
		}
		
		_AddToObj(obj.ItemList, { thumb:thumb, md5:md5, thumburl:thumburl, ImageKey:key, xhtml:xhtml, detail:detail, detailkey:"%key%", ID:key } )
		Lv_Add("", A_Index, detail, md5, key)
	}
	LV_ModifyCol(2)
	log := io.LogDir . SourceMD5 . ".ini"
	_ObjToFile(obj, log)
	
	CTL_SetActive(t)
	A2_ExpandFocus()
	SB_SetText("ダウンロード終了", 1, 2)
	SoundPlay, *64
}
