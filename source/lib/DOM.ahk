/*
Use DOM Document and Xpath
*/

EnvSet, A_Lib_Xpath, lib\javascript-xpath.js ; DOM��XPath���������߂ɕK�v

class DOM {
	
	__New(ByRef DOM_data=""){
		; ���݂̃h�L�������g��� (�w��HTML or File�p�X or URL���琶��)
		this.doc := DOM_data ? this.createDoc(DOM_data) : ""
	}
	
	; DOM�h�L�������g���w��HTML�f�[�^ or URL or ���[�J���p�X���琶��
	createDoc(ByRef DOM_data){
		If ( IfInString(DOM_data, "<HTML") )
			doc := this.loadHTML( DOM_data )
		Else If ( RegExMatch(DOM_data, "https?:\/\/") )
			doc := this.loadHTML( _HttpGet(DOM_data) )
		Else IfExist, %DOM_data%
			doc := this.loadHTML( FileRead(DOM_data) )
		Else
			throw Exception("DOM�I�u�W�F�N�g�̐������ɕs���ȃp�X�u" path "�v���n����܂����B")
		
		this.doc := doc ; ���݂�DOM�����㏑��
		return doc
	}
	; �w��XPath�̃m�[�h���擾
	getElementsByXPath(xpath, node="", doc=""){
		elems  := Object()
		result := this.getXpathResult(xpath, node, doc, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE)
		Loop, % result.snapshotLength
			elems.Insert(result.snapshotItem[A_Index-1])
		
		return elems
	}
	; �w��XPath�̃m�[�h���ŏ��̈�̂ݎ擾
	getFirstElementByXPath(xpath, node="", doc=""){
		result := this.getXpathResult(xpath, node, doc, XPathResult.FIRST_ORDERED_NODE_TYPE)
		return result.snapshotItem[0]
	}
	; �w��XPath�̃m�[�h�������ʂ��擾
	getXPathResult(xpath, node, doc, resultType=7){
		doc    := IsObject(doc)  ? doc  : this.doc
		node   := IsObject(node) ? node : this.doc
		result := doc.evaluate(xpath, node, null, resultType, null)
		return result
	}
	
	; HTML�f�[�^��DOM�h�L�������g�`���ɕϊ�
	; 	(ByRef data: HTML�f�[�^�B�f�[�^�ʂ��c��ł��邽�ߎQ�Ɠn��)
	loadHTML(ByRef data){
		doc := ComObjCreate("HTMLfile")
		doc.write(data)
		
		; XPath����֐���t��
		scr      := doc.createElement("script")
		scr.src  := _RelToAbs(A_Lib_Xpath)
		scr.type := "text/javascript"
		doc.getElementsByTagName("head")[0].appendChild(scr)
		
		return doc
	}
	; XML�f�[�^��XML_DOM�I�u�W�F�N�g�`���ɕϊ�
	; 	(ByRef data: XML�f�[�^�B�f�[�^�ʂ��c��ł��邽�ߎQ�Ɠn��)
	loadXML(ByRef data){
		doc := ComObjCreate("MSXML2.DOMDocument.6.0")
		doc.async := false
		doc.loadXML(data)
		return doc
	}
}