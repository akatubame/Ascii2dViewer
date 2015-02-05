# Ascii2dViewer

;-------------------------------------------------------------------
; 「Ascii2dViewer」
;   - 画像詳細検索サイト(http://www.ascii2d.net/imagesearch)のWin用クライアントビューア
;-------------------------------------------------------------------

■本ソフトの説明

画像の詳細情報データベースを登録している検索サイト「二次元画像詳細検索」の補助クライアントアプリ。使用言語は「AutoHotKey」。
ソフト名は「Ascii2dViewer」。以下「A2」と略称。

複数画像を一斉検索する場合の効率化目的で作成。主な機能は以下のとおり。

	・Web上、ローカルの画像ファイルの検索、詳細情報の全ダウンロード
	・階層構造を持つ詳細情報を自動的に辿ってダウンロード
	・検索した画像、指定画像の詳細情報のそれぞれの一覧を表示
	・ダウンロードした画像ファイルのリネーム、管理
	・外部からA2を呼び出すホットキー

搭載機能はすべてコンテキストメニューとホットキーの双方から呼び出せる仕様。
効率化のためホットキー推奨。特にマウスボタンをホットキーに用いると素早く検索できる。


;-------------------------------------------------------------------

■使い方

「Ascii2dViewer」を起動すると、メインウィンドウが表示される。
標準では以下の3つの方法で検索の対象となる画像を登録できる。

	[Web上の画像を検索]
		・画像ファイルのURLを入力する
	
	[ローカルドライブの画像を検索]
		・画像ファイル(jpg,gifなど)をメインウィンドウへDrag&Dropする
		・画像ファイルのパスをエクスプローラから選択する
	
	いずれの場合も、画像検索は7秒程度で終了し、検索した画像一覧がウィンドウの左部に表示される。

以下は検索画像リストについての説明。

	一覧のアイテムを選択すると指定画像の詳細一覧がウィンドウ中央上部に表示される。
	また、検索した元画像のビューアがウィンドウ右下部に表示される。
	右クリックメニューを呼び出すと指定画像のリネーム、削除などが行える。

次に詳細情報リストの説明。

	一覧のアイテムを選択すると詳細情報がウィンドウ中央下部に、詳細情報に一致する画像がウィンドウ右上部に表示される。
	詳細情報の画像はデータベースに登録された類似画像のピックアップであるため、元画像と同じ画像とは限らないので注意。
	
	概ね10個の類似判定された画像がDLされるため、ウィンドウ右部のビューアを見比べて目視で同じ画像かを判断すると良い。
	どちらも同じ画像が表示されていれば、中央下部に表示された詳細情報が求める情報となる。

簡単な使い方は以上となる。


;-------------------------------------------------------------------

■その他の機能

上記の機能の他、任意のウィンドウから「クリップボードURLの検索」などの各種機能を呼び出すことができる。
以下は標準のホットキーの場合。

	・「Ctrl + Win + F12」でA2メインウィンドウの呼び出し
	・「Ctrl + Win + F11」でクリップボードURLを詳細検索

また、ホットキーは任意のキーを割り当てることができる。以下参照。

	【ホットキー設定】
		各機能を呼び出すホットキーを自分仕様にカスタマイズすることができる。
		右クリック → 「ホットキーの設定」 から編集GUIを呼び出し、直接文字列を編集する。
		編集後、「変更を保存」をクリックしAEを再起動すると新しいホットキーが有効になる。
		（※この時、重複や存在しないキーなどを指定していると起動失敗するため注意）

;-------------------------------------------------------------------

■終わりに

他にも細かい機能等はあるが右クリックメニューから適当に試行するだけでおそらく学習可能。
質問や機能の追加要望、バグ報告等は以下へ。

;-------------------------------------------------------------------
	Author: akatubame
	Email: kurotubame5@gmail.com
;-------------------------------------------------------------------
