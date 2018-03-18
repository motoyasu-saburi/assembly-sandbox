; hello-os
; TAB=4

	ORG	0x7c00		; このプログラムがどこに読み込まれるのか

; 以下は標準的なFAT12フォーマットフロッピーディスクのための記述

	JMP SHORT	entry
	DB	0x90
	DB	"HELLOIPL"	; ブートセクタの名前を自由に書いてよい（8バイト）
	DW	512		; 1セクタの大きさ（512にしなければいけない）
	DB	1		; クラスタの大きさ（1セクタにしなければいけない）
	DW	1		; FATがどこから始まるか（普通は1セクタ目からにする）
	DB	2		; FATの個数（2にしなければいけない）
	DW	224		; ルートディレクトリ領域の大きさ（普通は224エントリにする）
	DW	2880		; このドライブの大きさ（2880セクタにしなければいけない）
	DB	0xf0		; メディアのタイプ（0xf0にしなければいけない）
	DW	9		; FAT領域の長さ（9セクタにしなければいけない）
	DW	18		; 1トラックにいくつのセクタがあるか（18にしなければいけない）
	DW	2		; ヘッドの数（2にしなければいけない）
	DD	0		; パーティションを使ってないのでここは必ず0
	DD	2880		; このドライブ大きさをもう一度書く
	DB	0,0,0x29	; よくわからないけどこの値にしておくといいらしい
	DD	0xffffffff	; たぶんボリュームシリアル番号
	DB	"HELLO-OS   "	; ディスクの名前（11バイト）
	DB	"FAT12   "	; フォーマットの名前（8バイト）
	RESB	18		; とりあえず18バイトあけておく

; プログラム本体

; http://oswiki.osask.jp/?%28AT%29BIOS

entry:
	MOV	AX,0		; レジスタ初期化
	MOV	SS,AX
	MOV	SP,0x7c00
	MOV	DS,AX
	MOV	ES,AX

; カラーモード VGAグラフィックス
	MOV AH,0x00
	MOV AL,0x12
	INT	0x10		; ビデオBIOS呼び出し

; パレット指定し始め
	MOV AX,0x1010
	MOV BX,0x000F ; 背景
	MOV DH,0x3f ; R
	MOV CH,0x00 ; G
	MOV CL,0    ; B
	INT	0x10		; ビデオBIOS呼び出し

; pixel書き込み
	MOV SI,0x00; 初期化
	MOV CX,0x15;
	MOV DX,0x15;

key:
	MOV AH,0x00
	INT	0x16		; ビデオBIOS呼び出し

	CMP AH,0x4d
 	JE right
 	CMP AH,0x4b
 	JE left
 	CMP AH,0x48
 	JE up
 	CMP AH,0x50
 	JE down

right:
ADD CX,1;
JMP pixel

up:
SUB DX,1;
JMP pixel

left:
SUB CX,1;
JMP pixel

down:
ADD DX,1;
JMP pixel

; pixel書き込み
pixel:
	MOV AH,0x0c;
	MOV AL,0x15;
	INT	0x10		; ビデオBIOS呼び出し
	JE SHORT key ; 終了した場合のjump
	;こっちは、いわゆる else
	JMP key ; ループで元に戻す

msg:
	DB	0x0a, 0x0a	; 改行を2つ
	DB	"hello, world"
	DB	0x0a		; 改行
	DB	0

	RESB	0x01fe-($-$$)	; 510バイト目までを0x00で埋める命令

	DB	0x55, 0xaa	; 最後にマーカーが必要
