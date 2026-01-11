	org	100h
boot	equ	0000h	;Bdos entry point
;
;	RomBios functions
memmod	equ	0ffb9h	;Memory mode
ttstat	equ	0ffc7h	;Keyboard status
ttcon	equ	0ffcdh	;Send message to console
ttio	equ	0ffd6h	;Echo char from console
tti	equ	0ffd3h	;Read char from console
tto	equ	0ffd9h	;Output char
outhexb	equ	0ffdch	;Out hex byte
outhex	equ	0ffdfh	;Out hex word
nibble	equ	0ffe8h	;Is hex?
blp     equ     0ff86h	;Emit sound
blpvol  equ     0ffb0h	;Sound volume
;
;	Constants
cr	equ	0dh	;Carriage return
lf	equ	0ah	;Line feed
esc	equ	1bh	;Escape code
lastlin	equ	230	;Last line of fall
skywid	equ	16	;Top guns char width
nimwid	equ	10	;Top guns name width
skyrid	equ	15	;Top guns entries

; T-KUK 2025 ehk TÄHTEDE KUKKUMINE
; Kadunud JUKU E5104 mängu uusversioon
; Märt Põder / tramm(a)infoaed.ee
; JUKU infosait: https://j3k.infoaed.ee
;
; Avaldatud GNU GPL-3 lähtekoodi litsentsiga
;
	lda	05dh
	call	nibble
	jc	noarg
	call	hexme
	rlc
	rlc
	rlc
	rlc
	ani	0f0h
	mov	b,a
	lda	5eh
	call	nibble
	jc	noarg
	call	hexme
	ani	0fh
	ora	b
	sta	tklev+1
noarg:	lxi	d,taevas
	call	setdma
	call	openf
	jz	error
	call	readf
	lxi	d,taevas+128
	call	setdma
	call	readf
	call	sega
	call	krypti
;
error:	lxi	b,start
	call	ttcon	;cursor off
	lxi	h,0d800h+40-7
	lxi	b,40-7
	mvi	d,240
	mvi	a,0ffh
fillb:	mov	m,a
	inx	h
	mov	m,a
	inx	h
	mov	m,a
	inx	h
	mov	m,a
	inx	h
	mov	m,a
	inx	h
	mov	m,a
	inx	h
	mov	m,a
	inx	h
	dad	b
	dcr	d
	jnz	fillb
	mvi	a,1
	call	memmod
	lda	0d463h
	sta	gener
	call	sega
	lxi	b,segu
	call	ttcon
	lda	gener
	call	outhexb
	lxi	b,kiri
	call	ttcon
	jmp	entry

; tähtede kukutamine
;
mloop:	lxi	h,0d800h+0
	mvi	a,0
	mov	m,a
	lxi	b,320/8
	dad	b
	shld	mloop+1
rloop:	lxi	d,0dd01h
	mvi	c,9
nextl:	ldax	d
	mov	m,a
	mov	a,c
	lxi	b,320/8
	dad	b
	inx	d
	mov	c,a
	dcr	c
	jnz	nextl
	
	call	ttstat
	jz	tklev
	lxi	b,klaff
	call	ttcon
	call	outhexb
	cpi	1bh	;fin
	jz	kyll
	cpi	7bh	;ö !!!
	jz	nw1
	cpi	7dh	;õ
	jz	nw2
	jmp	hitit

nw1:	sui	1eh
nw2:	adi	3h

hitit:	mov	b,a
	lda	curchr
	adi	40h
	cmp	b
	jz	matrix
	adi	20h
	cmp	b
	jz	matrix

; hyperspace calibrator
;
tklev:	mvi	a,00h	;ooteaeg
ootaja:	cpi	80h
	jc	targu
	cpi	0a0h
	jc	tasa
	nop
	nop
	nop
tasa:	nop
	nop
	nop
	nop
targu:	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	dcr	a
	jnz	ootaja
;
	lda	pos
	inr	a
	sta	pos
	push	psw
	push	d
	mov	e,a
	mvi	d,0
	mvi	a,10
	call	blp
	pop	d
	pop	psw
	cpi	lastlin
	jnz	mloop

	mvi	a,0ffh
	call	blpvol
	mvi	a,1
	lxi	d,0ffffh
	call	blp

	lda	lives
	dcr	a
	sta	lives

	mov	b,a
	mvi	a,2
	sub	b
	mov	c,a
	mvi	b,0
	ral
	adi	42h
	sta	fata+5

	lda	curcol
	adi	20h
	sta	botcol+3
	
	lda	curchr
	adi	40h
	sta	botcol+4
	sta	fata+6
	lxi	h,fate
	dad	b
	mov	m,a
	lxi	b,botcol
	call	ttcon

	lxi	b,fata
	call	ttcon

; where do you want to fly today?
;
entry:	mvi	a,0
	sta	pos
	lda	chrrnd
	call	rand
	sta	chrrnd
	stc
	cmc
	rar
	stc
	cmc
	rar
	stc
	cmc
	rar
	cpi	1fh	; _
	jz	plus1
	cpi	1dh	; ]
	jz	entry
	cpi	1bh	; [
	jz	entry
	dcr	a
plus1:	inr	a
	sta	curchr
	lxi	b,kukk
	call	ttcon
	call	outhexb
	lxi	h,0dd01h
	adi	20h
	mvi	c,9
	mvi	b,0
veel:	dad	b
	dcr	a
	jnz	veel
	shld	rloop+1	;märk fonditabelis
	lxi	h,0d800h
	lda	colrnd
	call	rand
	sta	colrnd
	rrc
	rrc
	rrc
	ani	1fh
	mvi	b,0
	mov	c,a
	sta	curcol
	dad	b
	shld	mloop+1	;tulp

	lda	lives
	cpi	0
	jz	kyll

	call	rank
	call	fame

	jmp	mloop

; enter the matrix
;
matrix:	push	psw
	push	d
	mvi	e,238
	mvi	d,0
	mvi	a,100
	call	blp
	pop	d
	pop	psw
pikend:	mvi	a,1	;pikendus
	dcr	a
	jnz	nil
	lda	tklev+1	;ajastus
	xri	0ffh
	stc
	cmc
	rar
	stc
	cmc
	rar
	stc
	cmc
	rar
	stc
	cmc
	rar
	stc
	cmc
	rar
	stc
	cmc
	rar
	cpi	0
	jnz	doit
	mvi	a,1
doit:	sta	pikend+1
	lda	tklev+1	;ajastus
	dcr	a
	sta	tklev+1
	lxi	b,level
	call	ttcon
	call	outhexb
	jmp	punn
nil:	sta	pikend+1
punn:	mvi	e,0
	cpi	80h
	jnc	nobon
	mvi	e,80h
nobon:	mov	b,a
	lhld	score
	lda	pos
	xri	0ffh
	mov	c,a
	cmp	b
	jc	eilahu
	sub	b
	mov	b,a	;lahutatud a
	mov	a,c	;algne a
	jmp	pudis
eilahu:	mvi	b,3
pudis:	stc
	cmc
	rar
	stc
	cmc
	rar
	stc
	cmc
	rar
	cmp	b	;pude vs lahut
	jnc	edasi
	mov	a,b	;kui pude väike
edasi:	ora	e	;boonus >80h
	lxi	b,lastsc
	call	ttcon
	call	outhexb
	mov	c,a
	mvi	b,0
	dad	b
	shld	score
	lxi	b,punne
	call	ttcon
	mov	b,h
	mov	c,l
	call	outhex
	lxi	b,inv
	call	ttcon
	lda	pikend+1
	lxi	b,xtra
	call	ttcon
	call	outhexb
	jmp	entry	;uuesti

; position in edetabel
;
rank:	lhld	score
	xchg
	mvi	c,skyrid
	lxi	h,taevas
	shld	topgun+1
topgun:	lhld	taevas
	mov	a,h
	cmp	d
	jc	updko
	jnz	conti2
	mov	a,l
	cmp	e
	jc	updko
	jz	updko
conti2:	lhld	topgun+1
	push	b
	lxi	b,skywid
	dad	b
	pop	b
	shld	topgun+1
	dcr	c
	jnz	topgun
updko:	mvi	a,skyrid+1
	sub	c
	sta	koht
	ret
	
kyll:	call	rank
	cpi	skyrid+1
	jc	newsc
;
	call	vtsky
	lxi	b,nohi
	call	ttcon
	lxi	b,encour
	call	ttcon
;
finz:	mvi	a,1h
	call	memmod
	lxi	b,finaal
	call	ttcon
	jmp	boot	;and reboot

; uus skoor tabelis
;
newsc:	lxi	h,p6rgu-1
	lxi	d,dante-1
	push	b
nexte:	dcr	c
	jz	fun
	mvi	b,skywid
coprec:	ldax	d
	mov	m,a
	dcx	h
	dcx	d
	dcr	b
	jnz	coprec
	jmp	nexte
fun:	lhld	score
	xchg
	lhld	topgun+1
	mov	m,e
	inx	h
	mov	m,d
	inx	h
	mvi	b,nimwid
	mvi	a,' '
clnim1:	mov	m,a
	dcr	b
	inx	h
	jnz	clnim1
	inx	h
	lxi	d,fate
	ldax	d
	mov	m,a	; 1 elu
	inx	h
	inx	d
	ldax	d
	mov	m,a	; 2 elu
	inx	h
	inx	d
	ldax	d
	mov	m,a	; 3 elu
	
	call	vtsky
	pop	b
	call	insky

	lxi	b,newhi
	call	ttcon
	lhld	topgun+1
	lxi	b,nimwid+1
	dad	b
nchr:	mov	a,m
	dcx	h
	dcr	c
	jz	offgo
	cpi	20h
	jz	nchr
	lxi	d,p6rgu
	lhld	topgun+1
	inx	h
allchr:	inx	h
	mov	a,m
	stax	d
	inx	d
	dcr	c
	jnz	allchr
	mvi	a,0
	stax	d
offgo:	lxi	b,p6rgu
	call	ttcon
	lxi	b,ellip
	call	ttcon
;
	call	delf
	call	creatf
	jz	finz	;error
;
	call	krypti
	lxi	d,taevas
	call	setdma
	call	writef
	lxi	d,taevas+128
	call	setdma
	call	writef
	call	closef
	lxi	b,congr
	call	ttcon
	jmp	finz

; edetabeli näitamine
;
vtsky:	lxi	h,taevas
	mvi	d,skyrid
nxtr:	mvi	a,skyrid
	sub	d
	adi	5+20h
	sta	sky+2
	lxi	b,sky
	call	ttcon
	mov	b,h
	mov	c,l
	inx	b
	inx	b
	call	ttcon
	mvi	a,' '
	call	tto
	push	h
	lxi	b,2+nimwid+1
	dad	b
	mov	a,m
	call	tto
	inx	h
	mov	a,m
	call	tto
	inx	h
	mov	a,m
	call	tto
	pop	h
	mvi	a,' '
	call	tto
	mov	c,m
	inx	h	;!
	mov	b,m
	call	outhex
	lxi	b,skywid-1	;!
	dad	b
	dcr	d
	jnz	nxtr
	ret

; edetabelisse sisestamine
;
insky:	mvi	a,skyrid
	sub	c
	adi	5+20h
	sta	sky+2
	lxi	b,sky
	call	ttcon
	lhld	topgun+1
	inx	h
	inx	h
	lxi	b,curon
	call	ttcon
	mvi	b,0
nimi:	call	tti
	cpi	0dh
	jz	finfa
	cpi	8
	jz	trydel
	cpi	20h
	jc	nimi
	mov	c,a
	mov	a,b
	cpi	10
	jz	nimi
	mov	a,c
	mov	m,a
	call	tto
	inx	h
	inr	b
	jmp	nimi
trydel:	mov	a,b
	cpi	0
	jz	nimi
	dcr	b
	dcx	h
	mvi	a,20h
	mov	m,a
	mvi	a,8
	call	tto
	mvi	a,20h
	call	tto
	mvi	a,8
	call	tto
	jmp	nimi
finfa:	lxi	b,start
	call	ttcon
	lxi	b,norm
	call	ttcon
	ret

; suur font
;
fame:	lxi	h,0dd01h+(9*10h)
	lda	koht
	cpi	10h
	jc	hexa
	mvi	a,0fh	;?
	jmp	subl
hexa:	cpi	0
	jz	zero
	cpi	10
	jc	subl
	adi	7
subl:	lxi	b,9
	dad	b
	dcr	a
	jnz	subl
zero:	xchg
	lxi	h,0d800h+32+(2*40)
	mvi	c,9
	
morlin:	push	d
	ldax	d
	mvi	b,7
replin:	call	skip
	call	transl
	call	transl
	call	transl
	call	transl
	call	transl
	call	transl
	call	transl
	lxi	d,40-8
	dad	d
	dcr	b
	jnz	replin
	pop	d
	inx	d
	dcr	c
	jnz	morlin
	ret
;
skip:	rlc
	inx	h
	ret
	
transl:	mvi	d,011111111b
	rlc
	jnc	finfil
	mvi	d,000000000b
finfil:	mov	m,d
	inx	h
	ret

; char to hex
;
hexme:	sui	30h
	cpi	0ah
	jc	hexmor
	ret
hexmor:	sui	11h
	cpi	06h
	jc	evenmo
	adi	0ah
	ret
evenmo:	adi	41h
	ret

; file op
;
setdma:
	mvi	c,1ah	;dma
	call	5
	ret
	
openf:	mvi	c,0fh	;open
	lxi	d,fcb
	call	5
	cpi	0ffh
	ret

delf:	mvi	c,13h	;del
	lxi	d,fcb
	call	5
	cpi	0ffh
	ret

creatf:	lxi	h,fcb+12
	mvi	b,21
clrfcb: mvi	m,0
	inx	h
	dcr	b
	jnz	clrfcb
	mvi	c,016h	;create
	lxi	d,fcb
	call	5
	cpi	0ffh
	ret

readf:	mvi	c,014h	;read
	lxi	d,fcb
	call	5
	cpi	0ffh
	ret

writef:	mvi	c,015h	;write
	lxi	d,fcb
	call	5
	cpi	0ffh
	ret

closef:	mvi	c,10h	;close
	lxi	d,fcb
	call	5
	cpi	0ffh
	ret

; krüpti ja dekrüpti
;
krypti:	mvi	d,0ffh
	lxi	h,taevas
	lda	gener
	inr	a
kluup:	call	rand
	mov	b,a
	mov	a,m
	xra	b
	mov	m,a
	mov	a,b
	inx	h
	dcr	d
	jnz	kluup
	ret

; juhuarvude generaator
;
rand:	mov	b,a
r1:	mvi	c,1
l1:	stc
	cmc
	ral
	dcr	c
	jnz	l1
	xra	b
	mov	b,a
r2:	mvi	c,1
l2:	stc
	cmc
	rar
	dcr	c
	jnz	l2
	xra	b
	mov	b,a
r3:	mvi	c,2
l3:	stc
	cmc
	ral
	dcr	c
	jnz	l3
	xra	b
	ret

; juhuslikustaja
;
sega:	cpi	0
	jz	ldgen
	stc
	cmc
	rar
	stc
	cmc
	rar
	stc
	cmc
	rar
	cpi	24
	jc	setsd
	stc
	cmc
	rar
	jmp	setsd
ldgen:	lda	gener
setsd:	lxi	h,seeds
	sta	gener
	cpi	0
	jz	nodec
	lxi	b,3
sloop:	dad	b
	dcr	a
	jnz	sloop
nodec:	mov	a,m
	sta	r1+1
	inx	h
	mov	a,m
	sta	r2+1
	inx	h
	mov	a,m
	sta	r3+1
	ret

;
; Data area
;
pos	db	0
koht	db	010h
score	dw	0
lives	db	3
fate	db	0,0,0
chrrnd	db	41
curchr	db	41
chrseed	db	14
colrnd	db	66
curcol	db	99
colseed	db	6
;
finaal:	db	esc,'5',esc,'(',esc,'=',22h,' ',0
start:	db	esc,'4',esc,27h,0
kiri:	db	esc,'=',27h,'BT-KUK',esc,'=(B 2025',esc,'=*BPERSE',esc,'=+BIIDID',esc,'=5BTRAMM',esc,'=6B& J3K',0
newhi:	db	esc,'(',esc,'H','Uus t|ht taevas, ',0
ellip:	db	'...',0
congr:	db	cr,lf,'Palju }nne!',0
nohi:	db	esc,'(',esc,'H','Seekord j|i taevas k}rgeks...',0
encour:	db	cr,lf,'Aga |ra heida meelt!',0
curon:	db	esc,'5',0
inv:	db	esc,27h,0
norm:	db	esc,'(',0
clear:	db	esc,'1', esc,'=) ',0
home:	db	esc,'H',0
col:	db	esc,'= )',0
sky:	db	esc,'=',27h,27h,0
botcol:	db	esc,'=7!X',0
fata:	db	esc,'(',esc,'=-BX',esc,27h,0
punne:	db	esc,'(',esc,'=3C',0
lastsc:	db	esc,'=/B',0
klaff:	db	esc,'=/E',0
level:	db	esc,'=0B',0
xtra:	db	esc,'=0E',0
kukk:	db	esc,'=1B',0
segu:	db	esc,'=1E',0
;
seeds	db	1,1,2
	db	1,1,3
	db	1,7,3
	db	1,7,6
	db	1,7,7
	db	2,1,1
	db	2,5,5
	db	3,1,1
	db	3,1,5
	db	3,5,4
	db	3,5,5
	db	3,5,7
	db	3,7,1
	db	4,5,3
	db	5,1,3
	db	5,3,6
	db	5,3,7
	db	5,5,2
	db	5,5,3
	db	6,3,5
	db	6,7,1
	db	7,3,5
	db	7,5,3
	db	7,7,1
;
fcb:	db	0,'TKUK    TOP'
	db	0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0
	db	0
;
taevas:	db	000,90h,'Liin      ',0,'   '
	db	000,80h,'Laos      ',0,'   '
	db	000,70h,'Volens    ',0,'   '
	db	000,60h,'Laffranque',0,'   '
	db	000,50h,'Vutt      ',0,'   '
	db	00h,40h,'Kull      ',0,'   '
	db	000,30h,'Kiris     ',0,'   '
	db	000,20h,'Brett     ',0,'   '
	db	000,10h,'Paal      ',0,'   '
	db	000,0fh,'Randma    ',0,'   '
	db	000,0eh,'Saare     ',0,'   '
	db	000,0dh,'Sarv      ',0,'   '
	db	000,0ch,'Sepp      ',0,'   '
	db	000,0bh,'Kullerkupp',0,'   '
dante:	db	000,0ah,'Loot      ',0,'   '
p6rgu:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
gener:	db	0
	end
