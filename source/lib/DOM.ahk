/*
Use DOM Document and Xpath
*/

EnvSet, A_Lib_Xpath, lib\javascript-xpath.js ; DOMでXPathを扱うために必要

class DOM {
	
	__New(ByRef DOM_data=""){
		; 現在のドキュメント情報 (指定HTML or Fileパス or URLから生成)
		this.doc := DOM_data ? this.createDoc(DOM_data) : ""
	}
	
	; DOMドキュメントを指定HTMLデータ or URL or ローカルパスから生成
	createDoc(ByRef DOM_data){
		If ( IfInString(DOM_data, "<HTML") )
			doc := this.loadHTML( DOM_data )
		Else If ( RegExMatch(DOM_data, "https?:\/\/") )
			doc := this.loadHTML( _HttpGet(DOM_data) )
		Else IfExist, %DOM_data%
			doc := this.loadHTML( FileRead(DOM_data) )
		Else
			throw Exception("DOMオブジェクトの生成元に不正なパス「" DOM_data "」が渡されました。")
		
		this.doc := doc ; 現在のDOM情報を上書き
		return doc
	}
	; 指定XPathのノードを取得
	getElementsByXPath(xpath, node="", doc=""){
		elems  := Object()
		result := this.getXpathResult(xpath, node, doc, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE)
		Loop, % result.snapshotLength
			elems.Insert(result.snapshotItem[A_Index-1])
		
		return elems
	}
	; 指定XPathのノードを最初の一つのみ取得
	getFirstElementByXPath(xpath, node="", doc=""){
		result := this.getXpathResult(xpath, node, doc, XPathResult.FIRST_ORDERED_NODE_TYPE)
		return result.snapshotItem[0]
	}
	; 指定XPathのノード検索結果を取得
	getXPathResult(xpath, node, doc, resultType=7){
		doc    := IsObject(doc)  ? doc  : this.doc
		node   := IsObject(node) ? node : this.doc
		result := doc.evaluate(xpath, node, null, resultType, null)
		return result
	}
	
	; HTMLデータをDOMドキュメント形式に変換
	; 	(ByRef data: HTMLデータ。データ量が膨大であるため参照渡し)
	loadHTML(ByRef data){
		doc := ComObjCreate("HTMLfile")
		doc.write(data)
		
		; XPath操作関数を付加
		scr      := doc.createElement("script")
		scr.src  := _RelToAbs(A_Lib_Xpath)
		scr.type := "text/javascript"
		doc.getElementsByTagName("head")[0].appendChild(scr)
		
		return doc
	}
	; XMLデータをXML_DOMオブジェクト形式に変換
	; 	(ByRef data: XMLデータ。データ量が膨大であるため参照渡し)
	loadXML(ByRef data){
		doc := ComObjCreate("MSXML2.DOMDocument.6.0")
		doc.async := false
		doc.loadXML(data)
		return doc
	}
}