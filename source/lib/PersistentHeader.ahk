;-------------------------------------------
; システムの設定(常駐アプリ専用)
;-------------------------------------------

; 特殊変数を定義
EnvSet, A_FTP_Server,   hogehoge.sakura.ne.jp
EnvSet, A_FTP_User,     hogehoge
EnvSet, A_FTP_Password, 3zbmvOsoQEet5sVbFg71CK0nGKq8n43Z

; 共通ライブラリの読込み定義
#Include *i <ftp>
global ftp

