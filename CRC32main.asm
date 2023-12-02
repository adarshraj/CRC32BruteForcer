.686
.model flat, stdcall
option casemap: none

include windows.inc
include user32.inc
include kernel32.inc
include comctl32.inc
include masm32.inc
include /masm32/macros/macros.asm
includelib user32.lib
includelib kernel32.lib
includelib comctl32.lib
includelib masm32.lib

include crc32.asm
WndProc	proto	:DWORD, :DWORD, :DWORD, :DWORD
CalculateSerial	proto	:HWND

.data
	szHexFormat		db	"%X",0
	szFormat1		db	"%X",0
	szAscii			db	"abcdefghijklmnopqrstuvwxyz",0
	nLen2			dd	1
	szStringFormat	db	"%C",0
	
.data?
	hInstance		HINSTANCE	?
	szHash			db	8 dup (?)   
	szSerial		db	60 dup(?)
	szTemp			db	60 dup(?)
	szHashBuffer	db	8 dup (?)
	szHashBuffer2	db	8 dup (?)
	szHashBuffer3	db	8 dup (?)

.const
	IDD_CRACKME			equ	1001
	IDC_NAME			equ	1004
	IDC_SERIAL			equ	1006
	IDC_CHECK			equ	1007
	IDC_EXIT			equ	1008	

.code
Crackme:
	invoke GetModuleHandle, NULL
	mov hInstance, eax	
	invoke InitCommonControls
	invoke DialogBoxParam, hInstance, IDD_CRACKME, NULL, addr WndProc, NULL
	invoke ExitProcess,0
	
WndProc	proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	.if	uMsg == WM_INITDIALOG
		invoke SetWindowText, hWnd, SADD("CRC32 BruteForcer")
	.elseif uMsg == WM_COMMAND
		mov eax, wParam
		.if eax == IDC_CHECK
			invoke SendDlgItemMessage, hWnd, IDC_NAME,WM_GETTEXT,32,addr szHash
				invoke CalculateSerial, hWnd		
		.elseif eax == IDC_EXIT
			invoke SendMessage, hWnd,WM_CLOSE,0,0	
		.endif
	.elseif uMsg == WM_CLOSE
		invoke EndDialog, hWnd, 0
	.endif		
xor eax, eax
	Ret
WndProc EndP	

CalculateSerial proc hWnd:HWND
LOCAL nLen : DWORD
	invoke lstrlen, addr szAscii
	mov nLen, eax
	
	xor eax, eax
	xor ebx, ebx
	xor esi, esi
	xor edi, edi
	mov edi, offset szAscii
	.WHILE nLen
		xor eax, eax
		mov al, byte ptr ds:[edi + ebx] 
		invoke wsprintf, addr szHashBuffer, addr szStringFormat, eax
		invoke CRC32,nLen2 ,offset szHashBuffer	
		mov esi, eax
		invoke ltoa, eax, addr szHashBuffer2	
		invoke wsprintf, addr szHashBuffer3, addr szHexFormat, eax
invoke lstrcmp, addr szHash, addr szHashBuffer3
		jz Hope
		inc ebx
		dec nLen
	.ENDW
	RET
Hope:
	invoke MessageBox, hWnd, SADD("Got you"),SADD("Ya"), MB_OK
		ret
xor eax, eax
	Ret
CalculateSerial EndP
end Crackme