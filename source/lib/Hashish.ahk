

/*                _         _     _
   /\  /\__ _ ___| |__     (_)___| |__   String/File Hash Generator GUI for CRC32/MD5/SHA1
  / /_/ / _` / __| '_ \ ___| / __| '_ \                                  v1.0, 12-Oct-2012
 / __  / (_| \__ \ | | |___| \__ \ | | |
 \/ /_/ \__,_|___/_| |_|   |_|___/_| |_|                            SKAN, Suresh Kumar A N
                                                                  arian.suresh @ gmail.com
 -----------------------------------------------------------------------------------------
 http://www.autohotkey.com/community/viewtopic.php?t=93900
 http://tinyurl.com/skanbox/AutoHotkey/Hashish/v1.0/Hashish.ahk
 _________________________________________________________________________________________
*/

StrHashCMS( ByRef Buffer, Bytes, ByRef CRC="", ByRef MD5="", ByRef SHA="" ) {
	SetFormat, Integer, % SubStr( ( A_FI := A_FormatInteger ) "H", 0 )
	CRC32 := DllCall( "NTDLL\RtlComputeCrc32", UInt,0, UInt,&Buffer, UInt,Bytes, UInt )
	CRC   := SubStr( CRC32 | 0x1000000000, -7 )
	SetFormat, Integer, %A_FI%
	
	VarSetCapacity( MD5_CTX,104,0 ),  DllCall( "advapi32\MD5Init", UInt,&MD5_CTX )
	DllCall( "advapi32\MD5Update", UInt,&MD5_CTX, UInt,&Buffer, UInt,Bytes )
	DllCall( "advapi32\MD5Final", UInt,&MD5_CTX )
	MD5 := HexGet( &MD5_CTX+8,  16 )
	
	VarSetCapacity( SHA_CTX,136,0 ),  DllCall( "advapi32\A_SHAInit", UInt,&SHA_CTX )
	DllCall( "advapi32\A_SHAUpdate", UInt,&SHA_CTX, UInt,&Buffer, UInt,Bytes )
	DllCall( "advapi32\A_SHAFinal", UInt,&SHA_CTX, UInt,&SHA_CTX + 116 )
	SHA := HexGet( &SHA_CTX+116,20 )
}

FileHashCMS( sFile, ByRef CRC="", ByRef MD5="", ByRef SHA="" ) {
	QPX(1)
	cSz := 1*(1024*1024), VarSetCapacity( Buffer,cSz,0 )
	hFil := DllCall( "CreateFile", Str,sFile,UInt,0x80000000, Int,3,Int,0,Int,3,Int,0,Int,0 )
	IfLess,hFil,1, Return
	
	DllCall( "GetFileSizeEx", UInt,hFil, UInt,&Buffer ),
	fSz := NumGet( Buffer,0,"Int64" )
	
	CRC32 := 0, ATC := A_TickCount, Read := 0
	VarSetCapacity( MD5_CTX,104,0 ),  DllCall( "advapi32\MD5Init", UInt,&MD5_CTX )
	VarSetCapacity( SHA_CTX,136,0 ),  DllCall( "advapi32\A_SHAInit", UInt,&SHA_CTX )
	Loop % ( fSz//cSz + !!Mod( fSz,cSz ) )
	{
		DllCall( "ReadFile", UInt,hFil, UInt,&Buffer, UInt,cSz, UIntP,Bytes, UInt,0 )
		CRC32 := DllCall( "NTDLL\RtlComputeCrc32", UInt,CRC32, UInt,&Buffer, UInt,Bytes, UInt )
		SetFormat, Integer, % SubStr( ( A_FI := A_FormatInteger ) "H", 0 )
		CRC := SubStr( CRC32 + 0x1000000000, -7 )
		SetFormat, Integer, %A_FI%
		DllCall( "advapi32\MD5Update", UInt,&MD5_CTX, UInt,&Buffer, UInt,Bytes )
		DllCall( "advapi32\A_SHAUpdate", UInt,&SHA_CTX, UInt,&Buffer, UInt,Bytes )
		
		Prog := Floor( ( ( Read := Read + Bytes ) / fSz ) * 100 )
		Secs := ( A_TickCount - ATC ) / 1000
	}
	DllCall( "advapi32\MD5Final", UInt,&MD5_CTX )
	DllCall( "advapi32\A_SHAFinal", UInt,&SHA_CTX, UInt,&SHA_CTX + 116 )
	MD5 := HexGet( &MD5_CTX+8,  16 )
	SHA := HexGet( &SHA_CTX+116,20 )
	DllCall( "CloseHandle", UInt,hFil )
}

HexGet( Addr, Sz ) {
	DllCall( "Crypt32.dll\CryptBinaryToString" ( A_IsUnicode ? "W" : "A" ), UInt,Addr, UInt,Sz, UInt,4, Int,0, UIntP,ReqSz, "CDECL UInt" )
	VarSetCapacity( Hex, ReqSz := ReqSz * ( A_IsUnicode ? 2 : 1 ) )
	DllCall("Crypt32.dll\CryptBinaryToString" ( A_IsUnicode ? "W" : "A" ), UInt,Addr, UInt,Sz, UInt,4, Str,Hex, UIntP,ReqSz+1, "CDECL UInt")
	Return RegExReplace( Hex, "[^a-fA-F0-9]" )
}

HashOk( Hash, CRC32, MD5, SHA1 ) {
	IfEqual,Hash,%CRC32%, Return  "CRC OK"
	IfEqual,Hash,%MD5%,   Return  "MD5 OK"
	IfEqual,Hash,%SHA1%,  Return  "SHA OK"
}

QPX( N=0 ) {       ;  Wrapper for  QueryPerformanceCounter()by SKAN  | CD: 06/Dec/2009
	Static F,A,Q,P,X  ;  www.autohotkey.com/forum/viewtopic.php?t=52083 | LM: 10/Dec/2009
	If ( N && !P )
		Return  DllCall("QueryPerformanceFrequency",Int64P,F) + (X:=A:=0)
			+ DllCall("QueryPerformanceCounter",Int64P,P)
	DllCall("QueryPerformanceCounter",Int64P,Q), A:=A+Q-P, P:=Q, X:=X+1
	Return ( N && X=N ) ? (X:=X-1)<<64 : ( N=0 && (R:=A/X/F) ) ? ( R + (A:=P:=X:=0) ) : 1
}
