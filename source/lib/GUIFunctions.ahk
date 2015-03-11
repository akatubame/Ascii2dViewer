;-------------------------------------------
; 初期設定
;-------------------------------------------

; グローバル変数の呼出し
global io ; アプリ専用変数格納オブジェクト

;-------------------------------------------
; 制御ルーチン
;-------------------------------------------

; GUIの構築処理
GUI_Build:
	GuiNum     := io.thisGui.GuiNum
	GuiOption  := io.thisGui.GuiOption
	GuiMarginX := io.thisGui.Margin.X
	GuiMarginY := io.thisGui.Margin.Y
	GuiHidden  := io.thisGui.Hidden
	MenuUse    := io.thisGui.MenuUse
	MenuName   := io.thisGui.MenuName
	NotGroup   := io.thisGui.NotGroup
	
	; GUIウィンドウの生成
	Gui, %GuiNum%:%GuiOption%
	If (GuiMarginX != "")
		Gui, %GuiNum%:Margin, %GuiMarginX%, %GuiMarginY%
	If (MenuUse)
		Gui, %GuiNum%:Menu, %MenuName%
	
	; ウィンドウ下のGUIコントロールをすべて生成
	For i in io.thisGui.Ctrs {
		t         := io.thisGui.Ctrs[i]
		t.GuiName := key
		t.GuiNum  := GuiNum
		Gosub, CTL_Build
	}
	
	; GUI情報の記憶
	io.thisGui.ID   := WinExist()
	io.thisGui.Hwnd := "ahk_id " io.thisGui.ID
	t.Hwnd          := io.thisGui.Hwnd
	If (NotGroup = "")
		GroupAdd, GuiGroup, % io.thisGui.Hwnd
	
	; GUIの初期情報の適用
	GUI_Init(io.thisGui)
	
return

; GUIのコントロール付加処理
CTL_Build:
	GuiNum       := t.GuiNum
	CtrType      := t.CtrType
	CtrName      := t.CtrName
	CtrText      := t.CtrText
	CtrEventName := t.CtrEventName
	CtrOption    := t.CtrOption
	CtrHtml      := t.CtrHtml
	SB_SetParts  := t.SB_SetParts
	Pos          := t.Pos
	
	; 各種コントロール準備処理
	If (CtrType = "ListView" or CtrType = "TreeView") {
		IconUse := t.Icon.Use
		AddTags := t.AddTags
		
		LoadItemList(t)
		If (CtrType = "ListView")
			CtrText := LV_GetColumnName(t)
		
		If (IconUse) {
			BaseIcon := t.Icon.BaseIcon
			IL_Path  := t.Icon.IL_Path
			
			IfExist, %IL_Path%
				himl := IML_Load(IL_Path)
			Else {
				himl := IL_CreateEx()
				If (BaseIcon != "")
					t.Icon.BaseIconNumber := IL_Add(himl, BaseIcon)
				t.Icon.IL_Reflesh := 1
			}
			
			If (CtrType = "ListView")
				LV_SetImageList(himl, 1)
			Else If (CtrType = "TreeView")
				CtrOption .= " " . "ImageList" . himl
			
			t.Icon.himl := himl
		}
	}
	
	; Show表示位置の指定
	GUI_PosAddOption(t)
	PosOption := t.PosOption
	
	; GUIコントロール生成
	Gui, %GuiNum%:Add, %CtrType%, g%CtrEventName% v%CtrName% %CtrOption% %PosOption%, %CtrText%
	GuiControlGet, ControlID, %GuiNum%:Hwnd, %CtrName%
	t.ControlID := ControlID
	CTL_Size(t)
	
	; 各種コントロール後処理
	If (CtrType = "ListView" or CtrType = "TreeView") {
		CTL_LST_Build(t)
		If ( CtrType = "TreeView" )
			TV_BuildGroupItemList(t)
	}
	Else If (CtrType = "Picture") {
		t.Picture.CurrentImg := CtrText
	}
	Else If (CtrType = "StatusBar") {
		SB_SetText("", 1, 2)
		If (SB_SetParts != "") {
			args := _StringSplit(SB_SetParts, " ")
			SB_SetParts(args*)
			for k,v in args
				SB_SetText("", k+1, 2)
		}
	}
	Else If (CtrHtml != "") {
		HtmlLoad(t)
	}
return

; GUIの各種データ保存処理
GUI_Save:
	; GUI、リスト情報保存
	For i,thisGui in io.Gui {
		GUI_GetPosClient(thisGui)
		For j,thisCtr in thisGui.Ctrs {
			CTL_LST_Save(thisCtr)
		}
	}
	
	; 不要データの破棄
	If (io.Exit)
		Gosub, GUI_Destroy
	
	; 全体設定保存
	_ObjToFile(io.Gui, io.IniFile)
return

; GUIの各種データ読込処理
GUI_Load:
	; コントロール情報を読込
	For i,thisGui in io.Gui {
		For j,thisCtr in thisGui.Ctrs {
			CTL_LST_Load(thisCtr)
			HtmlLoad(thisCtr)
		}
	}
return

; GUIの各種データ破棄処理
GUI_Destroy:
	; GUI保存情報の定義
	io.SaveGuiData := ["ID", "Hwnd", "PosOption"]
	io.SaveCtrData := ["GuiNum", "GuiName", "ControlID", "Hwnd", "ItemObj", "PosOption", "doc", "ItemObj", "ItemList"]
	
	; 不要データ破棄処理
	For i,thisGui in io.Gui {
		For j in thisGui {
			For key,val in io.SaveGuiData {
				If (j = val) {
					thisGui.Remove(j)
					Break
				}
			}
		}
		For j,thisCtr in thisGui.Ctrs {
			For k in thisCtr {
				For key,val in io.SaveCtrData {
					If (k = val) {
						thisCtr.Remove(k)
						Break
					}
				}
			}
			IL_Destroy(thisCtr.himl) ; アイコンデータの破棄
		}
	}
return

; 各種メニュー構築
Menu_Build:
	For i,thisItem in io.MN
		Menu_Build(thisItem.menu, thisItem.name, thisItem.extend)
return


; 各種ホットキー割当て
Hotkey_Build:
	For i in io.HK {
		Hotkey("IfWinActive", io.HK[i].twnd)
		For j,thisHotkey in io.HK[i].hotkeys
			If ( thisHotkey.KeyName != "" )
				Hotkey(thisHotkey.KeyName, thisHotkey.Label)
	}
return

; ホットキー設定
Hotkey_Setting:
	io.thisGui := Object()
	io.thisGui.NotGroup := 1
	io.thisGui.Hotkey   := 1
	
	Hotkey_GuiBuild(io.thisGui)
	Gosub, GUI_Build
	GUI_Show(io.thisGui)
return

; ホットキー設定（Editコントロールモード）
Hotkey_SettingEdit:
	io.thisGui := Object()
	io.thisGui.NotGroup := 1
	
	Hotkey_GuiBuild(io.thisGui)
	Gosub, GUI_Build
	GUI_Show(io.thisGui)
return

; ホットキー設定GUIのセーブ処理
Hotkey_Save:
	GUI_Submit(io.thisGui)
	Hotkey_GuiSave(io.thisGui)
	
	_ObjToFile(io.HK, io.HotkeyFile, "Backup")
	GUI_Destroy(io.thisGui)
return

; ホットキー設定GUIのキャンセル処理
99GuiClose:
99GuiEscape:
Hotkey_Cancel:
	GUI_Cancel(io.thisGui)
	GUI_Destroy(io.thisGui)
return

;-------------------------------------------
; ホットキー定義
;-------------------------------------------

;======= GUI非アクティブ時のホットキー =======;

; ここに定義を書く


;======= GUIアクティブ時のホットキー =======;
#IfWinActive, ahk_group GuiGroup

; ここに定義を書く


#IfWinActive
;-------------------------------------------
; GUIイベント定義
;-------------------------------------------

; イベント前処理
SetUp:
	io.this    := GetGui() ; io.thisGuiを使うと競合しエラー
	io.thisCtr := GetCtrFocus(io.this)
	
	If ( IsObject(io.thisCtr) )
		CTL_SetActive(io.thisCtr)
	Else If ( IsObject(io.this) )
		GUI_SetActive(io.this)
	Else
		return
return


; 汎用操作

Reload:
	Reload
return

NotSaveReload:
	For i,thisGui in io.Gui
		For j,thisCtr in thisGui.Ctrs
			LoadItemList(thisCtr)
	Reload
return

IconReflesh:
	Gosub, SetUp
	IL_Reflesh(io.thisCtr)
return


; 選択アイテムの操作

InsertFocus:
	Gosub, SetUp
	InsertFocus(io.thisCtr)
return

InFocus:
	Gosub, SetUp
	InFocus(io.thisCtr)
return

DeleteFocus:
	Gosub, SetUp
	DeleteFocus(io.thisCtr)
return

SetNameFocus:
	Gosub, SetUp
	SetNameFocus(io.thisCtr)
return

SetIconFocus:
	Gosub, SetUp
	SetIconFocus(io.thisCtr)
return

MoveUpFocus:
	Gosub, SetUp
	MoveFocus("Up", io.thisCtr)
return

MoveDownFocus:
	Gosub, SetUp
	MoveFocus("Down", io.thisCtr)
return

CopyFocus:
	Gosub, SetUp
	CopyFocus(io.thisCtr)
return

PasteFocus:
	Gosub, SetUp
	PasteFocus(io.thisCtr)
return

CopyFocusList:
	Gosub, SetUp
	CopyFocusList(io.thisCtr)
return

PasteFocusList:
	Gosub, SetUp
	PasteFocusList(io.thisCtr)
return


;-------------------------------------------
; 関数
;-------------------------------------------


;--- GUI制御関数 ---;

GUI_Add(t, GuiNum, GuiOption="", Title="", Margin=""){
	t.GuiNum    := GuiNum
	t.GuiOption := GuiOption
	t.Title     := Title
	t.Margin    := Object()
	t.Margin.X  := Margin.X
	t.Margin.Y  := Margin.Y
	t.Ctrs      := Object()
}
CTL_Add(t, CtrType, CtrName, CtrText="", CtrEventName="", CtrOption="", CtrHtml="", GuiNum="", Pos=""){
	_AddToObj(t.Ctrs, {CtrType:CtrType, CtrName:CtrName, CtrText:CtrText, CtrEventName:CtrEventName, CtrOption:CtrOption, CtrHtml:CtrHtml, GuiNum:GuiNum, Pos:Pos})
}
GUI_Show_NA(t){
	Temp_DHW := A_DetectHiddenWindows
	DetectHiddenWindows, Off
	
	GuiNum := t.GuiNum
	Title  := t.Title
	Hwnd   := t.Hwnd
	
	IfWinNotExist, %Hwnd%
	{
		Gui, %GuiNum%:Show, NA, %Title%
		_WinAlwaysTop(Hwnd)
	}
	
	DetectHiddenWindows, %Temp_DHW%
}
GUI_Show(t){
	GuiNum := t.GuiNum
	Title  := t.Title
	
	Gui, %GuiNum%:Show,, %Title%
}
GUI_Init(t){
	GuiNum := t.GuiNum
	Title  := t.Title
	Pos    := t.Pos
	
	GUI_PosAddOption(t)
	PosOption := t.PosOption
	
	Gui, %GuiNum%:Show, Hide %PosOption%, %Title%
}
GUI_Hide(t){
	GuiNum   := t.GuiNum
	Gui, %GuiNum%:Hide
}
GUI_Submit(t){
	GuiNum   := t.GuiNum
	Gui, %GuiNum%:Submit
}
GUI_Cancel(t){
	GuiNum   := t.GuiNum
	Gui, %GuiNum%:Cancel
}
GUI_Destroy(t){
	GuiNum   := t.GuiNum
	Gui, %GuiNum%:Destroy
}
GUI_Maximize(t){
	GuiNum := t.GuiNum
	Gui, %GuiNum%:Maximize
}
GUI_Minimize(t){
	GuiNum := t.GuiNum
	Gui, %GuiNum%:Minimize
}
GUI_MinimizeTray(t){
	hwnd := t.Hwnd
	_WinMinimizeTray(hwnd)
}
GUI_GetPos(t){
	hwnd    := t.Hwnd
	
	WinGetPos, X, Y, Width, Height, %hwnd%
	t.Pos.X := X
	t.Pos.Y := Y
	t.Pos.W := Width
	t.Pos.H := Height
}
GUI_GetPosClient(t){
	hwnd    := t.Hwnd
	MenuUse := t.MenuUse
	
	BorderW := 8
	BorderH := 8 + 16
	If (MenuUse)
		BorderH += 22
	
	WinGetPos, X, Y, Width, Height, %hwnd%
	t.Pos.X := X
	t.Pos.Y := Y
	t.Pos.W := Width  - BorderW
	t.Pos.H := Height - BorderH
}
Gui_HtmlViewChange(t, ByRef xhtml){
	t.doc.all["id"].innerhtml := xhtml
}
Gui_ImageChange(t, path){
	If ( FileExist(path) ) {
		GuiNum  := t.GuiNum
		CtrName := t.CtrName
		CtrType := t.CtrType
		
		GUI_PosAddOption(t.Picture)
		PosOption := t.Picture.PosOption
		
		Gui, %GuiNum%:Default
		
		GuiControl,, %CtrName%, %PosOption% %path%
		t.Picture.CurrentImg := path
	}
}
GUI_PosAddOption(t){
	Pos         := t.Pos
	CtrType     := t.CtrType
	CurrentImg  := t.CurrentImg
	
	; オプションの初期化
	t.PosOption := ""
	
	; オプションの付加
	If ( IsObject(Pos) ) {
		For k,v in Pos {
			If (v != "") {
				If ( CurrentImg != "" ) {
					t.PosOption .= " *" k v
				}
				Else If ( CtrType != "" ) {
					v := StringReplace(v, "%", "", "UseErrorLevel")
					If (ErrorLevel = 1)
						v := (k = "w") ? A_GuiWidth / 100 * v : (k = "h") ? A_GuiHeight / 100 * v : ""
					If (v != "")
						t.PosOption .= " " k v
				}
				Else
					t.PosOption .= " " k v
			}
		}
	}
}
GUI_SetActive(t){
	GuiNum := t.GuiNum
	Gui, %GuiNum%:Default
}
CTL_SetActive(t){
	GuiNum  := t.GuiNum
	CtrName := t.CtrName
	CtrType := t.CtrType
	
	If (CtrType = "Hotkey")
		return
	Else If (CtrType = "text")
		return
	
	Gui, %GuiNum%:Default
	Gui, %GuiNum%:%CtrType%, %CtrName%
}
CTL_Size(t){
	GuiNum    := t.GuiNum
	CtrName   := t.CtrName
	
	GUI_PosAddOption(t)
	PosOption := t.PosOption
	
	If ( PosOption != "" )
		GuiControl, %GuiNum%:Move, %CtrName%, %PosOption%
	Else If (A_GuiHeight != "")
		GuiControl, %GuiNum%:Move, %CtrName%, w%A_GuiWidth% h%A_GuiHeight%
	Else {
		Gui := GetGuiFromOption("GuiNum", GuiNum)
		W:=Gui.Pos.W, H:=Gui.Pos.H
		GuiControl, %GuiNum%:Move, %CtrName%, w%W% h%H%
	}
}
CTL_LST_Build(t){
	list    := t.ItemObj.ItemList
	GuiNum  := t.GuiNum
	CtrName := t.CtrName
	CtrType := t.CtrType
	IconUse := t.Icon.Use
	
	Gui, %GuiNum%:Default
	Gui, %GuiNum%:%CtrType%, %CtrName%
	GuiControl, %GuiNum%:-Redraw, %CtrName%
	
	; リストビュー
	If (CtrType = "ListView") {
		LV_Delete()
		LV_AddFromList(t)
		LV_Modify(1, "Focus")
	}
	; ツリービュー
	Else If (CtrType = "TreeView") {
		TV_Save(t)
		TV_Delete()
		TV_AddFromList(list, "", t)
	}
	
	If (IconUse)
		t.Icon.IL_Reflesh := 0
	GuiControl, %GuiNum%:+Redraw, %CtrName%
}
CTL_LST_Save(t){
	CtrType := t.CtrType
	IconUse := t.Icon.Use
	himl    := t.Icon.himl
	IL_Path := t.Icon.IL_Path
	
	If ( CtrType != "ListView" and CtrType != "TreeView" )
		return
	
	CTL_SetActive(t)
	If ( CtrType = "ListView" )
		LV_GetColumnWidth(t)
	Else If ( CtrType = "TreeView" ) {
		TV_Save(t)
		TV_DestroyGroupItemList(t)
	}
	
	If (IconUse = 1)
		IML_Save(IL_Path, himl)
	SaveItemList(t)
}
CTL_LST_Load(t){
	CtrType := t.CtrType
	If ( CtrType != "ListView" && CtrType != "TreeView" )
		return
	
	CTL_SetActive(t)
	LoadItemList(t)
	If ( CtrType = "TreeView" )
		TV_BuildGroupItemList(t)
}
Menu_Build(menu, name, extend=""){
	For i,thisItem in menu {
		If ( thisItem.Separator )
			MenuAddSeparator(name)
		Else
			MenuAdd(name, thisItem.text, thisItem.Label)
	}
	If (extend != "") {
		thisMenu := GetMenuFromValue(extend, "name")
		MenuAddSeparator(name)
		Menu_Build(thisMenu.menu, name, thisMenu.extend)
	}
}
Hotkey_GuiBuild(t){
	GuiNumMain := GetGuiFromOption("MainWindow", 1).GuiNum
	GuiOption  := "+LastFound"
	GuiOption  .= (GuiNumMain) ? " Owner" . GuiNumMain : ""
	GUI_Add(t, 99, GuiOption, "ホットキーの設定", Margin:={ X: 10, Y: 30 } )
	
	CTL_Add(t, "Button", "Submit", "変更を保存", "Hotkey_Save",,,, Pos:={ X: 15, Y: 15 } )
	CTL_Add(t, "Button", "Cancel", "キャンセル", "Hotkey_Cancel",,,, Pos:={ X: 95, Y: 15 } )
	CTL_Add(t, "Text", "Text1", "※変更は再起動後に有効",,,,, Pos:={ X: 165, Y: 20 } )
	
	For i in io.HK {
		X := 15+170*(i-1)
		CTL_Add(t, "Text", "Category" i, io.HK[i].text,,,,, Pos:={ X:X, Y:55 } )
		
		For j,thisHotkey in io.HK[i].hotkeys {
			Y := 80+55*(j-1)
			CTL_Add(t, "Text", "Text" i "_" j, thisHotkey.text,,,,, Pos:={ X:X, Y:Y } )
			
			If (t.Hotkey != "")
				CTL_Add(t, "Hotkey", thisHotkey.Label, thisHotkey.KeyName,,,,, Pos:={ X:X, Y:Y+18 } )
			Else
				CTL_Add(t, "Edit", thisHotkey.Label, _ListReplace(thisHotkey.KeyName,, "HotkeyTrans"),,,,, Pos:={ X:X, Y:Y+18, W:120 } )
		}
	}
}
Hotkey_GuiSave(t){
	For i in io.HK {
		For j,thisHotkey in io.HK[i] {
			Label  := thisHotkey.Label
			Hotkey := %Label%
			If (t.Hotkey)
				thisHotkey.KeyName := Hotkey
			Else
				thisHotkey.KeyName := _ListReplaceRegex(Hotkey,, "HotkeyTransRev")
		}
	}
}

;--- GUI関連情報の取得関数 ---;

GetGui(){
	ID := _WinGetId()
	For i,thisGui in io.Gui
		If (thisGui.ID = ID)
			return thisGui
	return
}
GetGuiName(){
	ID := _WinGetId()
	For i,thisGui in io.Gui
		If (thisGui.ID = ID)
			return thisGui
	return
}
GetGuiFromOption(k, v){
	For i,thisGui in io.Gui
		If (thisGui[k] = v)
			return thisGui
	return
}
GetGuiNum(){
	Gui := GetGui()
	return Gui.GuiNum
}
GetCtrFocus(Gui=""){
	Gui    := ( IsObject(Gui) ) ? Gui : GetGui()
	GuiNum := Gui.GuiNum
	GuiControlGet, CtrName, %GuiNum%:FocusV
	
	For i,thisCtr in Gui.Ctrs
		If (thisCtr.CtrName = CtrName)
			Break
	return thisCtr
}
GetCtrNameFocus(Gui=""){
	ctr := GetCtrFocus(Gui)
	return ctr.CtrName
}
GetCtrFromOption(k, v, Gui=""){
	Gui := ( IsObject(Gui) ) ? Gui : GetGui()
	
	For i,thisCtr in Gui.Ctrs
		If (thisCtr[k] = v)
			Break
	return thisCtr
}
GetCtrAll(){
	Obj := Object()
	For i,thisGui in io.Gui
		For j,thisCtr in thisGui.Ctrs
			Obj[ thisCtr.CtrName ] := thisCtr
	return Obj
}
GetMenuFromValue(target, ItemName="text"){
	For i,thisItem in io.MN
		If (thisItem[ItemName] = target)
			return thisItem
	return
}
GetHotkeyFromValue(target, ItemName="text"){
	For i,thisItem in io.HK
		If (thisItem[ItemName] = target)
			return thisItem
	return
}

;--- アイテムリスト専用・イベント関数 ---;
CopyFocus(t){
	AddTags := t.AddTags
	target  := GetFocusItem(t)
	
	If (AddTags)
		target := DeQuoteTags(target, t)
	Clipboard := target
	;_ClipGet(target)
}
PasteFocus(t){
	InsertFocus(t, Clipboard)
}
CopyFocusList(t){
	ID        := TV_GetSelection()
	list      := t.ItemObj.ItemList
	target    := TV_GetItemKeyList(ID, list)
	Clipboard := _ObjToStr(target)
	;_ClipGet( _ObjToStr(target) )
}
PasteFocusList(t){
	CtrType := t.CtrType
	list    := t.ItemObj.ItemList
	IconUse := t.Icon.Use
	Obj     := _ObjFromStr(Clipboard)
	
	If ( !IsObject(Obj) )
		return
	If (IconUse = 1)
		t.Icon.IL_Reflesh := 1
	
	If (CtrType = "ListView") {
		return
	}
	Else If (CtrType = "TreeView") {
		ID         := TV_GetSelection()
		key        := TV_GetItemKey(ID, list)
		ParentList := TV_GetParentList(ID, list)
		ParentList.Insert(key, Obj)
		CTL_LST_Build(t)
		TV_Modify(ParentList[key].ID, "Vis Select")
	}
}
InsertFocus(t, target=""){
	CtrType := t.CtrType
	list    := t.ItemObj.ItemList
	Column  := t.ItemObj.Column
	AddTags := t.AddTags
	IconUse := t.Icon.Use
	target  := target ? target : _Inputbox("アイテムの挿入", "挿入するアイテム名を入力してください", Clipboard)
	
	If (IconUse = 1)
		t.Icon.IL_Reflesh := 1
	If (AddTags)
		target := QuoteTags(target, t)
	
	If (CtrType = "ListView") {
		;key  := LV_GetSelectKey(t) + 1
		;Jump := _GetMaxIndex(list) - key + 2
		;obj  := Object()
		;For i in Column {
		;	name    := Column[i].Key
		;	Default := (Column[i].Default = "%target%") ? target : Column[i].Default
		;	obj[name] := Default
		;}
		;_AddToObj(Insert, obj)
		;CTL_LST_Build(t)
		;LV_Modify(Jump, "Vis Select Focus")
		return
	}
	Else If (CtrType = "TreeView") {
		ID         := TV_GetSelection()
		key        := TV_GetItemKey(ID, list)
		ParentList := TV_GetParentList(ID, list)
		ParentList.Insert(key, target)
		ParentList[key] := { Val:target }
		CTL_LST_Build(t)
		TV_Modify(ParentList[key].ID, "Vis Select")
	}
}
InFocus(t, target=""){
	CtrType := t.CtrType
	list    := t.ItemObj.ItemList
	AddTags := t.AddTags
	IconUse := t.Icon.Use
	target  := target ? target : _Inputbox("階層直下にアイテムを挿入", "挿入するアイテム名を入力してください", Clipboard)
	
	If (IconUse = 1)
		t.Icon.IL_Reflesh := 1
	If (AddTags)
		target := QuoteTags(target, t)
	
	If (CtrType = "ListView") {
		return
	}
	Else If (CtrType = "TreeView") {
		ID         := TV_GetSelection()
		key        := TV_GetItemKey(ID, list)
		ParentList := TV_GetParentList(ID, list)
		
		If ( ParentList[key].ItemList[1].ID )
			ParentList[key].ItemList.Insert(1, target)
		ParentList[key].ItemList[1] := { Val:target }
		ParentList[key].Options := "Expand"
		ParentList[key].Val := DeQuoteTags(ParentList[key].Val, t)
		CTL_LST_Build(t)
		TV_Modify(ParentList[key].ID, "Vis Select")
	}
}
DeleteFocus(t){
	CtrType := t.CtrType
	list    := t.ItemObj.ItemList
	
	If (CtrType = "ListView") {
		key  := LV_GetSelectKey(t)
		Jump := _GetMaxIndex(list) + 1 - key
		list.Remove(key)
		CTL_LST_Build(t)
		LV_Modify(Jump, "Vis Select Focus")
	}
	Else If (CtrType = "TreeView") {
		ID         := TV_GetSelection()
		key        := TV_GetItemKey(ID, list)
		ParentList := TV_GetParentList(ID, list)
		ParentList.Remove(key)
		CTL_LST_Build(t)
		TV_Modify(ParentList[key].ID, "Vis Select")
	}
}
SetNameFocus(t){
	CtrType := t.CtrType
	AddTags := t.AddTags
	list    := t.ItemObj.ItemList
	
	If (CtrType = "ListView") {
		key  := LV_GetSelectKey(t)
		Jump := _GetMaxIndex(list) + 1 - key
		list[key].Val := _Inputbox("選択アイテムのリネーム", "アイテム名を入力してください", list[key].Val)
		CTL_LST_Build(t)
		LV_Modify(Jump, "Vis Select Focus")
	}
	Else If (CtrType = "TreeView") {
		ID         := TV_GetSelection()
		key        := TV_GetItemKey(ID, list)
		ParentList := TV_GetParentList(ID, list)
		target     := AddTags ? DeQuoteTags(ParentList[key].Val, t) : ParentList[key].Val
		name       := _Inputbox("選択アイテムのリネーム", "アイテム名を入力してください", target)
		ParentList[key].Val := (AddTags && !TV_GetChild(ID)) ? QuoteTags(name, t) : name
		CTL_LST_Build(t)
		TV_Modify(ParentList[key].ID, "Vis Select")
	}
}
SetIconFocus(t){
	CtrType  := t.CtrType
	AddTags  := t.AddTags
	list     := t.ItemObj.ItemList
	IconUse  := t.Icon.Use
	BaseIcon := t.Icon.BaseIcon
	IconDir  := t.Icon.Dir
	
	If (IconUse != 1)
		return
	
	If (CtrType = "ListView") {
		key     := LV_GetSelectKey(t)
		Jump    := _GetMaxIndex(list) + 1 - key
		path    := list[key].IconPath ? list[key].IconPath : BaseIcon
		icon    := _FileSelectFile(path, "選択アイテムのアイコン変更", "アイコン (*.ico)")
		newIcon := IconDir . _FileGetName(icon)
		
		_FileCopy(icon, newIcon, 1)
		list[key].IconPath := newIcon
		t.Icon.IL_Reflesh := 1
		CTL_LST_Build(t)
		LV_Modify(Jump, "Vis Select Focus")
	}
	Else If (CtrType = "TreeView") {
		ID         := TV_GetSelection()
		key        := TV_GetItemKey(ID, list)
		ParentList := TV_GetParentList(ID, list)
		path       := ParentList[key].IconPath ? ParentList[key].IconPath : BaseIcon
		icon       := _FileSelectFile(path, "選択アイテムのアイコン変更", "アイコン (*.ico)")
		newIcon    := IconDir . _FileGetName(icon)
		
		_FileCopy(icon, newIcon, 1)
		ParentList[key].IconPath := newIcon
		t.Icon.IL_Reflesh := 1
		CTL_LST_Build(t)
		TV_Modify(ParentList[key].ID, "Vis Select")
	}
}
MoveFocus(mode, t){
	CtrType := t.CtrType
	list    := t.ItemObj.ItemList
	tmpObj  := Object()
	
	If (CtrType = "ListView") {
		key       := LV_GetSelectKey(t)
		targetKey := (mode = "Up") ? key + 1 : (mode = "Down") ? key - 1 : 0
		Jump      := _GetMaxIndex(list) + 1 - TargetKey
		
		tmpObj          := list[targetKey]
		list[targetKey] := list[key]
		list[key]       := tmpObj
		CTL_LST_Build(t)
		LV_Modify(Jump, "Vis Select Focus")
	}
	Else If (CtrType = "TreeView") {
		ID       := TV_GetSelection()
		key      := TV_GetItemKey(ID, list)
		targetID := (mode = "Up") ? TV_GetPrev(ID) : (mode = "Down") ? TV_GetNext(ID) : 0
		If (targetID != 0) {
			targetKey  := TV_GetItemKey(targetID, list)
			ParentList := TV_GetParentList(ID, list)
			
			tmpObj                := ParentList[targetKey]
			ParentList[targetKey] := ParentList[key]
			ParentList[key]       := tmpObj
			CTL_LST_Build(t)
			TV_Modify(ParentList[targetKey].ID, "Vis Select")
		}
	}
}
EditItemList(t){
	file := t.ItemListPath
	_EmEditor(file)
}

;--- アイテムリスト専用・アイテム取得関数 ---;

GetFocus(t, target){
	GuiNum  := t.GuiNum
	CtrName := t.CtrName
	CtrType := t.CtrType
	
	Gui, %GuiNum%:%CtrType%, %CtrName%
	If (CtrType = "ListView") {
		ID := LV_GetNext("", F)
		If (ID)
			LV_GetText( ret, ID, target )
	}
	Else If (CtrType = "TreeView") {
		ID := TV_GetSelection()
		If ( target = "text" )
			TV_GetText(ret, ID)
		Else If ( target = "ID" )
			ret := ID
	}
	
	return ret
}
GetFocusItem(t, ColumnNumber = 1){
	CtrType := t.CtrType
	
	If (CtrType = "ListView")
		text := GetFocus(t, ColumnNumber)
	Else If (CtrType = "TreeView")
		text := GetFocus(t, "text")
	
	return text
}
GetFocusID(t){
	CtrType := t.CtrType
	
	If (CtrType = "ListView")
		return
	Else If (CtrType = "TreeView")
		ID := GetFocus(t, "ID")
	
	return ID
}
GetItemAll(t){
	CtrType := t.CtrType
	If (CtrType = "ListView") {
		list := t.ItemObj.ItemList
	}
	Else If (CtrType = "TreeView") {
		ID   := GetFocusID(t)
		list := TV_GetItemAll(ID)
	}
	return list
}
LV_GetSelectKey(t){
	ID := LV_GetNext("", F)
	LV_GetText(key, ID, 2)
	return key
}
LV_GetItemKey(ID, list){
	If (ID = "")
		return
	
	For key in list
		If (ID = list[key].ID)
			return key
	return
}
LV_GetItemKeyFromText(text, list){
	If (text = "")
		return
	
	For key in list
		If (text = list[key].Val)
			return key
	return
}
TV_GetGroup(ID, list){
	If (ID = "")
		return
	
	ID := TV_GetParentTop(ID)
	For key in list
		If (ID = list[key].ID)
			return list[key]
	return
}
TV_GetGroupList(ID, list){
	If (ID = "")
		return
	
	ID := TV_GetParentTop(ID)
	For key in list
		If (ID = list[key].ID)
			return list[key].GroupList
	return
}
TV_GetGroupName(ID, list){
	If (ID = "")
		return
	
	ID := TV_GetParentTop(ID)
	For key in list
		If (ID = list[key].ID)
			return list[key].GroupName
	return
}
TV_GetGroupOption(ID, GetOption, list){
	If (ID = "")
		return
	
	ID := TV_GetParentTop(ID)
	For key in list
		If (ID = list[key].ID)
			return list[key][GetOption]
	return
}
TV_GetIDFromGroup(GroupName, list){
	If (GroupName = "")
		return
	
	For key in list
		If (GroupName = list[key].GroupName)
			ID := list[key].ID
	return ID
}
TV_GetItemKey(ID, list){
	If (ID = "")
		return
	
	For key in list {
		If (ID = list[key].ID) {
			return key
		}
		Else If ( TV_GetChild( list[key].ID ) ) {
			targetKey := TV_GetItemKey(ID, list[key].ItemList)
			If (targetKey != 0)
				return targetKey
		}
	}
	return 0
}
TV_GetItemKeyList(ID, list){
	If (ID = "")
		return
	
	For key in list {
		If (ID = list[key].ID) {
			return list[key]
		}
		Else If ( TV_GetChild( list[key].ID ) ) {
			targetKey := TV_GetItemKeyList(ID, list[key].ItemList)
			If (targetKey != 0)
				return targetKey
		}
	}
	return 0
}
TV_GetIDFromValue(target, list, ItemName="Val"){
	If (target = "")
		return
	
	For key in list {
		If (target = list[key][ItemName]) {
			return list[key].ID
		}
		Else If ( TV_GetChild( list[key].ID ) ) {
			ID := TV_GetIDFromValue(target, list[key].ItemList, ItemName)
			If (ID != 0)
				return ID
		}
	}
	return 0
}
TV_GetItemList(ID, list){
	If (ID = "")
		return
	
	For key in list {
		If (ID = list[key].ID) {
			return list[key].ItemList
		}
		Else If ( TV_GetChild( list[key].ID ) ) {
			targetList := TV_GetItemList(ID, list[key].ItemList)
			If (targetList != 0)
				return targetList
		}
	}
	return 0
}
TV_GetItemText(ID, list){
	If (ID = "")
		return
	
	For key in list {
		If (ID = list[key].ID) {
			text := list[key].Val
			return text
		}
		Else If ( TV_GetChild( list[key].ID ) ) {
			text := TV_GetItemText(ID, list[key])
			If (text != 0)
				return text
		}
	}
	return 0
}
TV_GetItemOption(ID, GetOption, list){
	If (ID = "")
		return
	
	For key in list {
		If (ID = list[key].ID) {
			Option := list[key][GetOption]
			return Option
		}
		Else If ( TV_GetChild( list[key].ID ) ) {
			Option := TV_GetItemOption(ID, GetOption, list[key])
			If (Option != 0)
				return Option
		}
	}
	return 0
}
TV_GetParentList(ID, list){
	If (ID = "")
		return
		
	Parent := TV_GetParent(ID)
	ParentList := TV_GetItemList(Parent, list)
	
	If (ParentList = 0)
		return list
	Else
		return ParentList
}
TV_GetParentTop(ID){
	If (ID = "")
		return
	
	Parent := TV_GetParent(ID)
	If (Parent != 0)
		ID := TV_GetParentTop(Parent)
	return ID
}
TV_GetChildren(ID, list=""){
	If (ID = "")
		return
	
	If ( !IsObject(list) )
		list := Object()
	
	Child := TV_GetChild(ID)
	If (Child) {
		If ( TV_GetChild(Child) )
			TV_GetChildren(Child, list)
		Else {
			TV_GetText(text, Child)
			_AddToObj(list, { ID:Child, Val:text })
		}
		
		While ( Child := TV_GetNext(Child) ) {
			If ( TV_GetChild(Child) )
				TV_GetChildren(Child, list)
			Else {
				TV_GetText(text, Child)
				_AddToObj(list, { ID:Child, Val:text })
			}
		}
	}
	return list
}
TV_GetItemAll(ID){
	If (ID = "")
		return
	
	ID   := TV_GetParentTop(ID)
	list := TV_GetChildren(ID)
	return list
}

;--- アイテムリスト専用・データ操作関数 ---;

LV_AddToGUI(t, Obj*){
	GuiNum  := t.GuiNum
	CtrName := t.CtrName
	CtrType := t.CtrType
	
	Gui, %GuiNum%:Default
	Gui, %GuiNum%:%CtrType%, %CtrName%
	
	LV_Add("", Obj*)
}
LV_DeleteAll(t){
	list    := t.ItemObj.ItemList
	GuiNum  := t.GuiNum
	CtrName := t.CtrName
	CtrType := t.CtrType
	IconUse := t.Icon.Use
	
	Gui, %GuiNum%:Default
	Gui, %GuiNum%:%CtrType%, %CtrName%
	GuiControl, %GuiNum%:-Redraw, %CtrName%
	
	If (CtrType = "ListView") {
		LV_Delete()
		LV_Modify(1, "Focus")
	}
	
	If (IconUse)
		t.Icon.IL_Reflesh := 0
	GuiControl, %GuiNum%:+Redraw, %CtrName%
}
LV_AddFromList(t){
	;himl           := t.Icon.himl
	;BaseIconNumber := t.Icon.BaseIconNumber
	;IL_Reflesh     := t.Icon.IL_Reflesh
	list           := t.ItemObj.ItemList
	Column         := t.ItemObj.Column
	
	For key in list {
		Obj := Object()
		For i in Column {
			item := list[key][ Column[i].Key ]
			If (item = "%key%")
				item := key
			Else If (IsObject(item))
				item := _StringCombine("　", item*)
			_AddToObj(Obj, item)
		}
		ID := LV_Add("", Obj*)
		list[key].ID := ID
	}
	For i in Column
		LV_ModifyCol(i, Column[i].Width . " " . Column[i].Option)
}
TV_AddFromList(list, Parent, t){
	himl           := t.Icon.himl
	BaseIconNumber := t.Icon.BaseIconNumber
	IL_Reflesh     := t.Icon.IL_Reflesh
	
	For key in list {
		Val      := list[key].Val
		Options  := list[key].Options
		IconPath := list[key].IconPath
		IconNum  := list[key].IconNum
		
		If (himl != 0 && himl != "") {
			If (IL_Reflesh = 1) {
				IfExist, %IconPath%
					IconNum := IL_Add(himl, IconPath)
				Else
					IconNum := BaseIconNumber
			}
			Options .= " " . "Icon" . IconNum
			list[key].IconNum := IconNum
		}
		ID := TV_Add(Val, Parent, Options)
		TV_AddFromList(list[key].ItemList, ID, t)
		list[key].ID := ID
	}
}
TV_Save(t){
	list := t.ItemObj.ItemList
	TV_SaveOption(list)
}
TV_SaveOption(list){
	For key in list {
		ID := list[key].ID
		If ( TV_GetChild( ID ) ) {
			Options := TV_Get(ID, "Expand") ? "Expand" : ""
			TV_SetItemOption(ID, "Options", Options, list)
			TV_SaveOption(list[key])
		}
	}
}
TV_SetItemOption(ID, SetOption, SetValue, list){
	If (ID = "")
		return
	
	For key in list {
		If (ID = list[key].ID) {
			list[key][SetOption] := SetValue
			return 1
		}
		Else If ( TV_GetChild(list[key].ID) ) {
			TV_SetItemOption(ID, SetOption, SetValue, list[key])
		}
	}
	
	return 0
}
TV_BuildGroupItemList(t){
	list := t.ItemObj.ItemList
	For key in list {
		ID := list[key].ID
		list[key].GroupList := TV_GetItemAll(ID)
	}
}
TV_DestroyGroupItemList(t){
	list := t.ItemObj.ItemList
	For key in list {
		list[key].GroupList := Object()
	}
}
LV_GetColumnName(t){
	Column := t.ItemObj.Column
	
	For i in Column
		ret .= Column[i].Name "|"
	ret := StringTrimRight(ret, 1)
	
	return ret
}
LV_GetColumnWidth(t){
	Column    := t.ItemObj.Column
	ControlID := t.ControlID
	
	LVM_GETCOLUMNWIDTH := 0x1000 + 29
	For i in Column {
		c := i-1
		SendMessage, %LVM_GETCOLUMNWIDTH%, c, 0,, ahk_id %ControlID%
		If (ErrorLevel)
			Column[i].Width := ErrorLevel
	}
}
LoadItemList(t){
	file := t.ItemListPath
	
	If ( IfExist(file) )
		t.ItemObj := _ObjFromFile(file)
}
SaveItemList(t){
	obj    := t.ItemObj
	file   := t.ItemListPath
	Backup := (t.NoBackup != "") ? "" : 1
	
	_ObjToFile(obj, file, Backup)
}
DestroyItemList(t){
	t.Remove("ItemObj")
}

;--- 汎用データ操作関数 ---;

HtmlLoad(t){
	CtrHtml := t.CtrHtml
	If (CtrHtml="")
		return
	
	doc := COM_AtlAxCreateControl( t.ControlID, "HTMLfile" ) ; http://msdn.microsoft.com/en-us/library/da181h29
	_NativeCom(doc)
	doc.write(CtrHtml)
	
	t.doc := doc
}
HtmlDestroy(t){
	t.Remove("doc")
}
IL_CreateEx(Width = 16, Height = 16){
	himl := DllCall("ImageList_Create",Int,Width,Int,Height,UInt,0x21,Int,w,Int,w,UInt)
	return himl
}
IL_Reflesh(t){
	himl           := t.Icon.himl
	BaseIcon       := t.Icon.BaseIcon
	BaseIconNumber := t.Icon.BaseIconNumber
	
	IL_Destroy(himl)
	himl := IL_CreateEx()
	If (BaseIcon != "")
		BaseIconNumber := IL_Add(himl, BaseIcon)
	
	t.Icon.IL_Reflesh := 1
	t.Icon.himl := himl
	CTL_LST_Build(t)
}
IML_Save( File, himl ){
	SplitPath, File,,,Ext
	Off := ( Ext = "BMP" ) ? 28 : 0
	DllCall( "ole32\CreateStreamOnHGlobal", UInt,0, Int,1, UIntP,pStream )
	DllCall( "ImageList_Write", UInt,himl, UInt,pStream )
	DllCall( "ole32\GetHGlobalFromStream", UInt,pStream, UIntP,hData )
	pData := DllCall( "GlobalLock", UInt,hData )
	nSize := DllCall( "GlobalSize", UInt,hData )
	If ( hF := DllCall( "CreateFile", Str,File, UInt,0x40000000, UInt,2
	                   , Int,0, UInt,2, Int,0, Int,0 ) ) > 0
	  Bytes := DllCall( "_lwrite", UInt,hF, UInt,pData+Off, UInt,nSize-Off )
	        ,  DllCall( "CloseHandle",UInt,hF )
	DllCall( "GlobalUnlock", UInt,hData )
	DllCall( NumGet( NumGet( 1*pStream ) + 8 ), UInt,pStream )
	DllCall( "GlobalFree",   UInt,hData )
	Return Bytes > 0 ? Bytes : 0
}
IML_Load( File ){
	If ( hF := DllCall( "CreateFile", Str,File, UInt,0x80000000, UInt,3
	                   , Int,0, UInt,3, Int,0, Int,0 ) ) < 1
	|| ( nSiz := DllCall( "GetFileSize", UInt,hF, Int,0, UInt ) ) < 1
	 Return ( ErrorLevel := 1 ) >> 64,  DllCall( "CloseHandle",UInt,hF )
	hData := DllCall("GlobalAlloc", UInt,2, UInt,nSiz )
	pData := DllCall("GlobalLock",  UInt,hData )
	DllCall( "_lread", UInt,hF, UInt,pData, UInt,nSiz )
	DllCall( "GlobalUnlock", UInt,hData ), DllCall( "CloseHandle",UInt,hF )
	DllCall( "ole32\CreateStreamOnHGlobal", UInt,hData, Int,True, UIntP,pStream )
	himl := DllCall( "ImageList_Read", UInt,pStream )
	DllCall( NumGet( NumGet( 1*pStream ) + 8 ), UInt,pStream )
	DllCall( "GlobalFree", UInt,hData )
	Return himl
}


;--- 文字列操作関数 ---;

QuoteTags(target, t){
	ID     := GetFocusID(t)
	list   := t.ItemObj.ItemList
	Group  := TV_GetGroup(ID, list)
	Quote  := Group.Quote
	
	If (Quote != "") {
		l      := StringLeft(Quote, 1)
		r      := StringRight(Quote, 1)
		tLeft  := StringLeft(target, 1)
		tRight := StringRight(target, 1)
		If (tLeft != l)
			target := l . target
		If (tRight != r)
			target := target . r
	}
	return target
}
DeQuoteTags(target, t){
	ID     := GetFocusID(t)
	list   := t.ItemObj.ItemList
	Group  := TV_GetGroup(ID, list)
	Quote  := Group.Quote
	
	If (Quote != "") {
		l      := StringLeft(Quote, 1)
		r      := StringRight(Quote, 1)
		tLeft  := StringLeft(target, 1)
		tRight := StringRight(target, 1)
		If (tLeft = l)
			target := StringTrimLeft(target, 1)
		If (tRight = r)
			target := StringTrimRight(target, 1)
	}
	return target
}
