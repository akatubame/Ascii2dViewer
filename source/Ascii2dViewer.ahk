#Persistent
#SingleInstance, Force
;#NoTrayIcon

#Include *i <CommonHeader>

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

; 各種テーブル設定を読みこみ
io.regex := Object()
io.regex["Ascii2dMD5"]    := FileRead(A_ScriptDir "\" "regex\Ascii2dMD5.txt")
io.regex["Ascii2dXhtml"]  := FileRead(A_ScriptDir "\" "regex\Ascii2dXhtml.txt")
io.regex["Ascii2dRename"] := FileRead(A_ScriptDir "\" "regex\Ascii2dRename.txt")

; 各種グローバル変数の設定
io.PostUri := "http://www.ascii2d.net/imagesearch/search"
io.GetUri  := "http://www.ascii2d.net/imagesearch/similar/"

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
	io.thisGui := ""
	
	Gosub, Menu_Build
	Gosub, Hotkey_Build
	
	For key in io.Gui {
		io.thisGui := io.Gui[key]
		GoSub, GUI_Build
	}
	For key in io.Gui {
		GUI_Show(io.Gui[key])
	}
	
	; データの格納ディレクトリがなければ作成
	For i,thisItem in [io.ImgDir, io.LogDir, io.ThumbDir] {
		If ( FileExist(thisItem)!="D" ) {
			FileCreateDir(thisItem)
		}
	}
	
	A2.DetailClear("Init") ; 各種コントロールの初期化
	SB_SetText("読込終了", 1, 2)
return


;-------------------------------------------
; 制御ルーチン
;-------------------------------------------

; イベント振分け処理
Event:
	; 項目をクリックした時のイベント
	If (A_GuiEvent == "Normal") {
		
		If (A_GuiControl == "ImageList") {
			Gosub, A2_ExpandFocus
		}
		Else If (A_GuiControl == "DetailList") {
			Gosub, A2_DetailFocus
		}
	}
	; 項目をダブルクリックした時のイベント
	Else If (A_GuiEvent == "DoubleClick") {
		
		If (A_GuiControl == "ImageList") {
			Gosub, A2_OpenFocus
		}
		Else If (A_GuiControl == "DetailList") {
			Gosub, A2_RenameFocus_LineCopy
		}
	}
	
	; 項目を矢印上下キーで移動した時のイベント
	Else If (A_GuiEvent == "K") {
		
		For i,key in [33, 34, 35, 36, 38, 40] {
			If (A_EventInfo == key) {
				If (A_GuiControl == "ImageList") {
					Gosub, A2_ExpandFocus
				}
				Else If (A_GuiControl == "DetailList") {
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
	If (A_EventInfo == 1) {
		return
	}
	; それ以外
	Else {
		For i,thisCtr in GetGui().Ctrs
			CTL_Size(thisCtr)
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
	If (A_GuiControl == "ImageList") {
		Menu, ImageListContextMenu, Show
	}
	Else If (A_GuiControl == "DetailList") {
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
	A2.MainDL_Drop(files)
return


;-------------------------------------------
; ホットキーイベント定義
;-------------------------------------------

; 選択画像の詳細情報を展開
A2_ExpandFocus:
	Gosub, SetUp
	A2.ExpandFocus()
return

; 選択した詳細情報をHTMLビュー
A2_DetailFocus:
	Gosub, SetUp
	A2.DetailFocus()
return

; 選択画像の詳細情報を削除
A2_DeleteFocus:
	Gosub, SetUp
	A2.DeleteFocus()
return

; 選択画像を開く
A2_OpenFocus:
	Gosub, SetUp
	A2.OpenFocus()
return

; 選択画像のURLをコピー
A2_GetUrlFocus:
	Gosub, SetUp
	A2.GetUrlFocus()
return

; 詳細情報をすべて削除
A2_DeleteAll:
	Gosub, SetUp
	A2.DeleteAll()
return

; メインDL処理
A2_MainDL:
A2_MainDL2:
	A2.MainDL()
return

; クリップボードURLで詳細検索
A2_MainDL_Clip:
A2_MainDL_Clip2:
	A2.MainDL_Clip()
return

; ファイルダイアログで詳細検索
A2_MainDL_SelectFile:
	A2.MainDL_SelectFile()
return

; 選択ファイル or クリップボードのファイルで詳細検索
A2_MainDL_ClipDrop:
	A2.MainDL_Drop( _SelectedOrClipboard() )
return

; 元画像のリネーム
A2_RenameFocus:
	A2.RenameFocus()
return
A2_RenameFocus_Clip:
	A2.RenameFocus_Clip()
return
A2_RenameFocus_LineCopy:
	A2.RenameFocus_LineCopy()
return


;-------------------------------------------
; 関数
;-------------------------------------------
; 【関数内で使用されている変数の説明】
;
;  　io ： GUIの全データが格納
;  　┗ io.ctr ： 各種コントロールの全データが格納
;        ┣ ImageList   … 画像リスト
;        ┣ DetailList  … 詳細情報リスト
;        ┣ DetailView  … 詳細情報ビュー
;        ┣ SourceImage … 元画像ビュー
;        ┗ DetailImage … 詳細画像ビュー
;-------------------------------------------

; 独自関数コール時には接頭辞にA2.を付ける
class A2 {

;--- 汎用関数 ---;

; 画像ビューの更新
ImageChange(ctr, filePath){
	filePath := FileExist(filePath) ? filePath : io.BlankImage
	Gui_ImageChange(ctr, filePath)
}

; 詳細コントロールのすべてのビューをクリア
DetailClear(Init=""){
	
	; 詳細情報リストをデフォルトに戻す
	io.ctr.DetailList.ItemListPath := io.DefList
	LoadItemList(io.ctr.DetailList)
	CTL_LST_Build(io.ctr.DetailList)
	
	; 画像ビューをブランクに戻す
	A2.ImageChange(io.ctr.DetailImage, io.BlankImage)
	A2.ImageChange(io.ctr.SourceImage, io.BlankImage)
	
	; 詳細ビューを空にする(起動直後は無効)
	If ( !Init )
		Gui_HtmlViewChange(io.ctr.DetailView, "")
}

;--- イベント関数 ---;

; 画像リスト内でフォーカスされたアイテムの展開処理
ExpandFocus(){
	md5 := GetFocus(io.ctr.ImageList, 3)
	If (!md5)
		return 1
	
	; 元画像ビューを、フォーカスされたアイテムの元画像データに更新
	thisList    := io.ctr.ImageList.ItemObj.ItemList
	ID          := TV_GetIDFromValue(md5, thisList, "md5")
	SourceImage := thisList[ID].SourceImage
	A2.ImageChange(io.ctr.SourceImage, SourceImage)
	
	; フォーカスされたアイテムのmd5をもとに詳細情報リストを取得
	logFile := io.LogDir . md5 . ".ini"
	io.ctr.DetailList.ItemListPath := logFile
	LoadItemList(io.ctr.DetailList)
	CTL_LST_Build(io.ctr.DetailList)
	
	; 詳細情報リストの一番上のデータを取得し、詳細画像＆詳細情報ビューを更新
	thisList := io.ctr.DetailList.ItemObj.ItemList
	thumb    := thisList[1].thumb
	xhtml    := thisList[1].xhtml
	A2.ImageChange(io.ctr.DetailImage, thumb)
	Gui_HtmlViewChange(io.ctr.DetailView, xhtml)
	
}
; 詳細情報リスト内でフォーカスされたアイテムの情報を閲覧
DetailFocus(){
	ID := GetFocus(io.ctr.DetailList, 1)
	If (!ID)
		return 1
	
	; 詳細画像＆詳細情報ビューを更新
	thisList := io.ctr.DetailList.ItemObj.ItemList
	thumb    := thisList[ID].thumb
	xhtml    := thisList[ID].xhtml
	A2.ImageChange(io.ctr.DetailImage, thumb)
	Gui_HtmlViewChange(io.ctr.DetailView, xhtml)
	
}
; 画像リスト内でフォーカスされたアイテムの削除
DeleteFocus(){
	md5 := GetFocus(io.ctr.ImageList, 3)
	If (!md5)
		return 1
	
	; 関連ファイルの削除
	thisList := io.ctr.ImageList.ItemObj.ItemList
	ID       := TV_GetIDFromValue(md5, thisList, "md5")
	
	SourceImage := thisList[ID].SourceImage
	logFile     := io.LogDir . md5 . ".ini"
	dir         := io.ThumbDir . md5
	For k,v in [SourceImage, logFile, dir]
		_FileDelete(v)
	
	; 画像リストの保持データを削除
	thisList.Remove(ID)
	
	; 画像リストビューの更新
	CTL_LST_Build(io.ctr.ImageList)
	LV_Modify(ID, "Vis Select Focus")
	miss := A2.ExpandFocus()
	If (miss)
		A2.DetailClear() ; 画像リストが空になった場合、詳細関連ビューをクリア
}
; 画像リスト内でフォーカスされたアイテムを指定されたビューワで開く
OpenFocus(){
	md5 := GetFocus(io.ctr.ImageList, 3)
	If (!md5)
		return 1
	
	thisList    := io.ctr.ImageList.ItemObj.ItemList
	ID          := TV_GetIDFromValue(md5, thisList, "md5")
	SourceImage := thisList[ID].SourceImage
	_Run(SourceImage)
}
; 画像リスト内でフォーカスされた画像のURLを取得
GetUrlFocus(){
	md5 := GetFocus(io.ctr.ImageList, 3)
	If (!md5)
		return 1
	
	thisList  := io.ctr.ImageList.ItemObj.ItemList
	ID        := TV_GetIDFromValue(md5, thisList, "md5")
	ImageURL  := thisList[ID].ImageURL
	Clipboard := ImageURL
	;_ClipGet(ImageURL)
}
; ダウンロードしたすべての情報を消去
DeleteAll(){
	If ( !_IfMsgBox("保存された画像＆詳細情報をすべてクリアしますか？") )
		return
	
	; 画像リストの消去
	io.ctr.ImageList.ItemObj.ItemList := []
	
	; データの格納ディレクトリを空に
	For i,thisItem in [io.ImgDir, io.LogDir, io.ThumbDir] {
		_FileDelete(thisItem)
		FileCreateDir(thisItem)
	}
	
	; すべてのビューをクリア
	CTL_LST_Build(io.ctr.ImageList)
	A2.DetailClear()
}

;--- リネーム関数 ---;

; フォーカスされた画像をリネーム
RenameFocus(){
	A2.Rename()
}
; フォーカスされた画像をリネーム(クリップボード文字列を自動入力)
RenameFocus_Clip(){
	newName := _Inputbox("元画像のリネーム", "画像のファイル名を入力", _SelectedOrClipboard())
	A2.Rename(newName)
}
; フォーカスされた画像をリネーム(詳細情報を自動入力)
RenameFocus_LineCopy(){
	ID := GetFocus(io.ctr.DetailList, 1)
	If (!ID)
		return 1
	
	thisList := io.ctr.DetailList.ItemObj.ItemList
	detail   := thisList[ID].detail
	detail   := _ListReplaceRegex(detail, "", io.regex["Ascii2dRename"])
	detail   := _OptimizeName(detail)
	newName  := _Inputbox("元画像のリネーム", "画像のファイル名を入力", detail)
	A2.Rename(newName)
}
; 画像のリネーム処理
Rename(newName=""){
	md5 := GetFocus(io.ctr.ImageList, 3)
	If (!md5)
		return 1
	
	; 元画像データの取得
	thisList    := io.ctr.ImageList.ItemObj.ItemList
	ID          := TV_GetIDFromValue(md5, thisList, "md5")
	SourceImage := thisList[ID].SourceImage
	
	; リネーム処理
	If (newName == "") {
		oldName := thisList[ID].Renamed ? _FileGetNoExt(SourceImage) : ""
		newName := _Inputbox("元画像のリネーム", "画像のファイル名を入力", oldName)
	}
	newName := _OptimizeName(newName)
	_FileRename(SourceImage, newName, 1, 1)
	
	; 画像リストの保持データへの追記
	ext := _FileGetExt(SourceImage)
	thisList[ID].SourceImage := io.ImgDir . newName "." ext
	thisList[ID].ImageName   := newName
	thisList[ID].Renamed     := 1
	
	; 画像リストビューの更新
	CTL_LST_Build(io.ctr.ImageList)
	LV_Modify(ID, "Vis Select Focus")
}

;--- ダウンロード処理関数 ---;

; 入力したURLの画像を詳細情報ダウンロード
MainDL(){
	ImageURL := _Inputbox("二次元画像詳細検索", "取得する画像のURLを入力")
	A2.MainDL_Main(ImageURL)
}
; クリップボードURLの画像を詳細情報ダウンロード
MainDL_Clip(){
	
	; クリップボードの内容を取得
	target := _SelectedOrClipboard()
	
	; クリップボードがローカルのパス情報であればDrag&Drop
	If ( IfExist(target) ) {
		A2.MainDL_Drop(target)
		return
	}
	
	; クリップボード文字列に含まれるURLの抽出
	imageUrls := _URLExtract(target)
	
	; URLの個数を計算
	count := _CountLines(imageUrls)
	
	; 画像がない場合、画像検索をキャンセルした場合は終了
	If (count == 0)
		return
	Else If ( !_IfMsgBox(imageUrls "`n`n" count "個の画像ファイルを詳細検索しますか？") )
		return
	
	; 抽出URLを一斉詳細検索
	A2.MainDL_Array(count, imageUrls)
	
	; 進捗状況のクリア
	SB_SetText("", 2, 2)
}
; ダイアログで選択した画像を詳細情報ダウンロード
MainDL_SelectFile(){
	file := _FileSelectFile("", "詳細検索する画像を選択", "画像ファイル (*.gif;*.jpg;*.jpeg;*.png)")
	A2.MainDL_Drop(file)
}
; Drag&Dropした画像を詳細情報ダウンロード
MainDL_Drop(files){
	
	; ファイルの個数を計算
	count := _CountLines(files)
	
	; 画像がない場合、画像検索をキャンセルした場合は終了
	If (count == 0)
		return
	Else If ( !_IfMsgBox(files "`n`n" count "個の画像ファイルを詳細検索しますか？") )
		return
	
	; 画像データをtransfer.shへアップロード
	Loop, parse, files, `n, `r
	{
		SB_SetText(A_Index "/" count "枚目のアップロード中...", 2, 2)
		url := _UploadImageToTransferSh(A_LoopField)
		_AddLine(imageUrls, url)
	}
	
	; アップロードした画像のURLを一斉詳細検索
	A2.MainDL_Array(count, imageUrls)
	
	; 進捗状況のクリア
	SB_SetText("", 2, 2)
}
; 複数の画像を詳細情報ダウンロード
MainDL_Array(count, imageUrls){
	Loop, parse, imageUrls, `n, `r
	{
		If (A_LoopField == "")
			return
		
		; 詳細ダウンロード開始
		SB_SetText(A_Index "/" count "枚目の詳細DL中...", 2, 2)
		A2.MainDL_Main(A_LoopField)
		
		; ダウンロード進捗状況の更新(最後の一枚を除く)
		If (A_Index != count) {
			SB_SetText(A_Index "/" count "枚DL完了　次の詳細DLまで5秒待機中...", 2, 2)
			Sleep, 5000
		}
	}
	; 進捗状況のクリア
	SB_SetText("", 2, 2)
}
; 詳細情報ダウンロードのメイン処理
MainDL_Main(ImageURL){
	
	; 詳細HTMLデータのダウンロード
	SB_SetText("詳細リストのダウンロード中...", 1, 2)
	html  := _HttpPost(io.PostUri, "uri=" ImageURL)
	doc   := DOM.createDoc(html)
	elems := DOM.getElementsByXPath("//div[@class='box']", doc)
	
	; 取得失敗時はエラーメッセージを吐いて終了
	If ( !elems.maxIndex() ) {
		xhtml := "<h1>エラーが発生しました。存在しないか、処理できないURLです。</h1><br><h2><a href=" ImageURL "/>" ImageURL "</a></h2>"
		Gui_HtmlViewChange(io.ctr.DetailView, xhtml)
		SB_SetText("ダウンロード失敗", 1, 2)
		return
	}
	
	; 検索元画像のダウンロード（可能ならファイル名をMD5にリネーム ※重複を避けるため）
	SB_SetText("画像サムネイルのダウンロード中...", 1, 2)
	SourceImage := io.ImgDir . _FileGetName(ImageURL)
	URLDownloadToFile(ImageURL, SourceImage)
	If ( FileExist(SourceImage) ) {
		ext       := _FileGetExt(SourceImage)
		SourceMD5 := _HashGetMD5(SourceImage)
		If ( !_FileRename( SourceImage, SourceMD5, 1, 1 ) )
			SourceImage := io.ImgDir . SourceMD5 "." ext
	}
	
	; 画像リストへの追記
	thisList := io.ctr.ImageList.ItemObj.ItemList
	key := _GetMaxIndex(thisList) + 1
	key := key ? key : 1
	_AddToObj(thisList, { ID:key, ImageKey:"%key%", md5:SourceMD5, ImageURL:ImageURL, ImageName:ImageURL, SourceImage:SourceImage } )
	CTL_SetActive(io.ctr.ImageList)
	Lv_Add("", key, ImageURL, SourceMD5)
	LV_Modify(key, "Vis Select Focus")
	
	; ------ 以下より詳細画像のDL開始 ------ ;
	SB_SetText("詳細画像＆追加情報のダウンロード中...", 1, 2)
	
	; 詳細リストのクリア
	CTL_SetActive(io.ctr.DetailList)
	LV_DeleteAll(io.ctr.DetailList)
	
	; サムネイル保管ディレクトリの作成
	dir := io.ThumbDir . SourceMD5
	FileCreateDir(dir)
	
	; HTMLデータから詳細情報を逐次登録
	registData := Object()
	registData := _ObjFromFile(io.DefList)
	for i,e in elems {
		
		; 詳細画像のサムネイルをダウンロード
		thumbURL := e.getElementsByTagName("img")[0].src
		thumbURL := StringReplace(thumbURL, "about:", "http://www.ascii2d.net")
		thumb    := dir "\" _FileGetName(thumbURL)
		URLDownloadToFile(thumbURL, thumb)
		
		; 詳細画像からMD5を抽出
		md5 := _ListReplaceRegex(thumbURL, "", io.regex["Ascii2dMD5"])
		
		; 詳細情報の取得
		e2     := DOM.getFirstElementByXPath("descendant::div[@class='detail']", e, doc)
		detail := e2.innerText
		xhtml  := e2.innerHTML
		detail := (detail=="") ? "＊詳細情報なし" : RegExReplace(detail, "(\n|\r)", "")
		xhtml  := _ListReplaceRegex(xhtml, "", io.regex["Ascii2dXhtml"])
		
		; 掲示板ログから追加情報のダウンロード
		e3   := e2.getElementsByTagName("a")
		href := (e3.length) ? StringReplace( e3[0].href, "about:", "http://www.ascii2d.net") : ""
		If (className := _RegExMatch_Get(href, "\/(ch2|moeren)\/")) {
			addDoc   := DOM.createDoc(href)
			addXhtml := DOM.getFirstElementByXPath("//div[@class='" className "']", addDoc).innerHTML
			addXhtml := _ListReplaceRegex(addXhtml, "", io.regex["Ascii2dXhtml"])
			xhtml    .= "<br>" addXhtml
		}
		
		; 詳細データの登録処理
		_AddToObj(registData.ItemList, { thumb:thumb, md5:md5, thumbURL:thumbURL, ImageKey:key, xhtml:xhtml, detail:detail, detailkey:"%key%", ID:key } )
		Lv_Add("", A_Index, detail, md5, key)
	}
	LV_ModifyCol(2) ; 詳細リストの並び替え
	
	; 詳細情報をログファイルへ書き込み
	log := io.LogDir . SourceMD5 . ".ini"
	_ObjToFile(registData, log)
	
	; 最後にDLした画像のビューを表示して終了
	CTL_SetActive(io.ctr.ImageList)
	A2.ExpandFocus()
	SB_SetText("ダウンロード終了", 1, 2)
	SoundPlay, *64
}

} ; A2クラスのネスト終了