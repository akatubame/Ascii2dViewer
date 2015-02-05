;-------------------------------------------
; 標準関数ライブラリ
;-------------------------------------------

ControlGet(Cmd, Value = "", Control = "", WinTitle = "A", WinText = "", ExcludeTitle = "", ExcludeText = ""){
	ControlGet, v, %Cmd%, %Value%, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
	Return, v
}
ControlGetFocus(WinTitle = "A", WinText = "", ExcludeTitle = "", ExcludeText = ""){
	ControlGetFocus, v, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
	Return, v
}
ControlGetText(Control = "", WinTitle = "A", WinText = "", ExcludeTitle = "", ExcludeText = ""){
	ControlGetText, v, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
	Return, v
}
DriveGet(Cmd, Value = ""){
	DriveGet, v, %Cmd%, %Value%
	Return, v
}
DriveSpaceFree(Path){
	DriveSpaceFree, v, %Path%
	Return, v
}
EnvGet(EnvVarName){
	EnvGet, v, %EnvVarName%
	Return, v
}
FileAppend(Text, Filename){
	FileAppend, %Text%, %Filename%
}
FileGetAttrib(Filename = ""){
	FileGetAttrib, v, %Filename%
	Return, v
}
FileGetShortcut(LinkFile, ByRef OutTarget = "", ByRef OutDir = "", ByRef OutArgs = "", ByRef OutDescription = "", ByRef OutIcon = "", ByRef OutIconNum = "", ByRef OutRunState = ""){
	FileGetShortcut, %LinkFile%, OutTarget, OutDir, OutArgs, OutDescription, OutIcon, OutIconNum, OutRunState
}
FileGetSize(Filename = "", Units = ""){
	FileGetSize, v, %Filename%, %Units%
	Return, v
}
FileGetTime(Filename = "", WhichTime = ""){
	FileGetTime, v, %Filename%, %WhichTime%
	Return, v
}
FileGetVersion(Filename = ""){
	FileGetVersion, v, %Filename%
	Return, v
}
FileRead(Filename){
	FileRead, v, %Filename%
	Return, v
}
FileReadLine(Filename, LineNum){
	FileReadLine, v, %Filename%, %LineNum%
	Return, v
}
FileSelectFile(Options = "", RootDir = "", Prompt = "", Filter = ""){
	FileSelectFile, v, %Options%, %RootDir%, %Prompt%, %Filter%
	Return, v
}
FileSelectFolder(StartingFolder = "", Options = "", Prompt = ""){
	FileSelectFolder, v, %StartingFolder%, %Options%, %Prompt%
	Return, v
}
FormatTime(YYYYMMDDHH24MISS = "", Format = ""){
	FormatTime, v, %YYYYMMDDHH24MISS%, %Format%
	Return, v
}
GetKeyState(WhichKey , Mode = ""){
	GetKeyState, v, %WhichKey%, %Mode%
	Return, v
}
GuiControlGet(Subcommand = "", ControlID = "", Param4 = ""){
	GuiControlGet, v, %Subcommand%, %ControlID%, %Param4%
	Return, v
}
ImageSearch(ByRef OutputVarX, ByRef OutputVarY, X1, Y1, X2, Y2, ImageFile){
	ImageSearch, OutputVarX, OutputVarY, %X1%, %Y1%, %X2%, %Y2%, %ImageFile%
}
IniRead(Filename, Section, Key, Default = ""){
	IniRead, v, %Filename%, %Section%, %Key%, %Default%
	Return, v
}
Input(Options = "", EndKeys = "", MatchList = ""){
	Input, v, %Options%, %EndKeys%, %MatchList%
	Return, v
}
MouseGetPos(ByRef OutputVarX = "", ByRef OutputVarY = "", ByRef OutputVarWin = "", ByRef OutputVarControl = "", Mode = ""){
	MouseGetPos, OutputVarX, OutputVarY, OutputVarWin, OutputVarControl, %Mode%
}
PixelGetColor(X, Y, RGB = ""){
	PixelGetColor, v, %X%, %Y%, %RGB%
	Return, v
}
PixelSearch(ByRef OutputVarX, ByRef OutputVarY, X1, Y1, X2, Y2, ColorID, Variation = "", Mode = ""){
	PixelSearch, OutputVarX, OutputVarY, %X1%, %Y1%, %X2%, %Y2%, %ColorID%, %Variation%, %Mode%
}
Random(Min = "", Max = ""){
	Random, v, %Min%, %Max%
	Return, v
}
RegRead(RootKey, SubKey, ValueName = ""){
	RegRead, v, %RootKey%, %SubKey%, %ValueName%
	Return, v
}
SoundGet(ComponentType = "", ControlType = "", DeviceNumber = ""){
	SoundGet, v, %ComponentType%, %ControlType%, %DeviceNumber%
	Return, v
}
SoundGetWaveVolume(DeviceNumber = ""){
	SoundGetWaveVolume, v, %DeviceNumber%
	Return, v
}
SplitPath(ByRef InputVar, ByRef OutFileName = "", ByRef OutDir = "", ByRef OutExtension = "", ByRef OutNameNoExt = "", ByRef OutDrive = ""){
	SplitPath, InputVar, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
}
StringGetPos(ByRef InputVar, SearchText, Mode = "", Offset = ""){
	StringGetPos, v, InputVar, %SearchText%, %Mode%, %Offset%
	Return, v
}
StringLeft(ByRef InputVar, Count){
	StringLeft, v, InputVar, %Count%
	Return, v
}
StringLen(ByRef InputVar){
	StringLen, v, InputVar
	Return, v
}
StringLower(ByRef InputVar, T = ""){
	StringLower, v, InputVar, %T%
	Return, v
}
StringMid(ByRef InputVar, StartChar, Count , L = ""){
	StringMid, v, InputVar, %StartChar%, %Count%, %L%
	Return, v
}
StringReplace(ByRef InputVar, SearchText, ReplaceText = "", All = ""){
	StringReplace, v, InputVar, %SearchText%, %ReplaceText%, %All%
	Return, v
}
StringRight(ByRef InputVar, Count){
	StringRight, v, InputVar, %Count%
	Return, v
}
StringTrimLeft(ByRef InputVar, Count){
	StringTrimLeft, v, InputVar, %Count%
	Return, v
}
StringTrimRight(ByRef InputVar, Count){
	StringTrimRight, v, InputVar, %Count%
	Return, v
}
StringUpper(ByRef InputVar, T = ""){
	StringUpper, v, InputVar, %T%
	Return, v
}
SysGet(Subcommand, Param3 = ""){
	SysGet, v, %Subcommand%, %Param3%
	Return, v
}
Transform(Cmd, Value1, Value2 = ""){
	Transform, v, %Cmd%, %Value1%, %Value2%
	Return, v
}
IfInString(Var, SearchString){
	IfInString, Var, %SearchString%
		Return, 1
	Else
		Return, 0
}
IfNotInString(Var, SearchString){
	IfNotInString, Var, %SearchString%
		Return, 1
	Else
		Return, 0
}
IfExist(twnd){
	IfExist, %twnd%
		Return, 1
	Else
		Return, 0
}
IfNotExist(twnd){
	IfNotExist, %twnd%
		Return, 1
	Else
		Return, 0
}
IfWinActive(twnd){
	IfWinActive, %twnd%
		Return, 1
	Else
		Return, 0
}
IfWinNotActive(twnd){
	IfWinNotActive, %twnd%
		Return, 1
	Else
		Return, 0
}
IfWinExist(twnd){
	IfWinExist, %twnd%
		Return, 1
	Else
		Return, 0
}
IfWinNotExist(twnd){
	IfWinNotExist, %twnd%
		Return, 1
	Else
		Return, 0
}
IfMsgBox(twnd){
	IfMsgBox, %twnd%
		Return, 1
	Else
		Return, 0
}
ControlSetText(Control, NewText="", WinTitle="A", WinText="", ExcludeTitle="", ExcludeTex=""){
	ControlSetText, %Control%, %NewText%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeTex%
}
ControlClick(Control, WinTitle="A", WinText="", WhichButton="", ClickCount="", Opt=""){
	ControlClick, %Control%, %WinTitle%, %WinText%, %WhichButton%, %ClickCount%, %Opt%
}
ControlFocus(Control, WinTitle="A", WinText="", ExcludeTitle="", ExcludeTex=""){
	ControlFocus, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeTex%
}
URLDownloadToFile(URL, Filename){
	URLDownloadToFile, %URL%, %Filename%
}
Hotkey(KeyName, Label="", Options=""){
	Hotkey, %KeyName%, %Label%, %Options%
}
MenuAdd(MenuName, text, Label){
	Menu, %MenuName%, Add, %text%, %Label%
}
MenuAddSeparator(MenuName){
	Menu, %MenuName%, Add
}
FileCreateDir(path){
	FileCreateDir, %Path%
}
SplashImage(ImageFile, Options="", SubText="", MainText="", WinTitle="", FontName="", FutureUse=""){
	SplashImage, %ImageFile%, %Options%, %SubText%, %MainText%, %WinTitle%, %FontName%, %FutureUse%
}
Progress(Param1, SubText="", MainText="", WinTitle="", FontName=""){
	Progress, %Param1%, %SubText%, %MainText%, %WinTitle%, %FontName%
}