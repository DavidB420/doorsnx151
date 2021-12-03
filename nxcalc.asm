;Doors NX Calculator Made by David Badiei
use32
org 50000h
%include 'nxapi.inc'

mov esi,titleString
call sys_setupScreen

call sys_getoldlocation

call drawwidgets

call sys_getoldlocation

finit

call findradtodegconvfactor

mov dword [mouseaddress],lbuttonclick
mov dword [keybaddress],getinput
mov dword [bgtaskaddress],sys_nobgtasks
jmp sys_windowloop

doneprog:
ret
titleString db 'Doors NX Calculator',0
numX dw 120
val times 22 db 0
counter db 0
ten dd 10.0,0
tmp dw 1,0
answer dq 0.0
tmp2 dq 3.2
tmp3 dq -1.0
intval dd 0,0
decval dd 0,0

lbuttonclick:
cmp word [mouseX],619
jle s1
cmp word [mouseX],636
jg s1
cmp word [mouseY],1
jle s1
cmp word [mouseY],13
jg s1
jmp doneprog
s1:
cmp word [mouseX],49
jle s2
cmp word [mouseX],100
jg s2
cmp word [mouseY],99
jle s2
cmp word [mouseY],150
jg s2
mov al,'1'
call addnumber
jmp sys_windowloop
s2:
cmp word [mouseX],149
jle s3
cmp word [mouseX],200
jg s3
cmp word [mouseY],99
jle s3
cmp word [mouseY],150
jg s3
mov al,'2'
call addnumber
jmp sys_windowloop
s3:
cmp word [mouseX],249
jle s4
cmp word [mouseX],300
jg s4
cmp word [mouseY],99
jle s4
cmp word [mouseY],150
jg s4
mov al,'3'
call addnumber
jmp sys_windowloop
s4:
cmp word [mouseX],49
jle s5
cmp word [mouseX],100
jg s5
cmp word [mouseY],199
jle s5
cmp word [mouseY],250
jg s5
mov al,'4'
call addnumber
jmp sys_windowloop
s5:
cmp word [mouseX],149
jle s6
cmp word [mouseX],200
jg s6
cmp word [mouseY],199
jle s6
cmp word [mouseY],250
jg s6
mov al,'5'
call addnumber
jmp sys_windowloop
s6:
cmp word [mouseX],249
jle s7
cmp word [mouseX],300
jg s7
cmp word [mouseY],199
jle s7
cmp word [mouseY],250
jg s7
mov al,'6'
call addnumber
jmp sys_windowloop
s7:
cmp word [mouseX],49
jle s8
cmp word [mouseX],100
jg s8
cmp word [mouseY],299
jle s8
cmp word [mouseY],350
jg s8
mov al,'7'
call addnumber
jmp sys_windowloop
s8:
cmp word [mouseX],149
jle s9
cmp word [mouseX],200
jg s9
cmp word [mouseY],299
jle s9
cmp word [mouseY],350
jg s9
mov al,'8'
call addnumber
jmp sys_windowloop
s9:
cmp word [mouseX],249
jle s10
cmp word [mouseX],300
jg s10
cmp word [mouseY],299
jle s10
cmp word [mouseY],350
jg s10
mov al,'9'
call addnumber
jmp sys_windowloop
s10:
cmp word [mouseX],149
jle s11
cmp word [mouseX],200
jg s11
cmp word [mouseY],399
jle s11
cmp word [mouseY],450
jg s11
mov al,'0'
call addnumber
jmp sys_windowloop
s11:
cmp word [mouseX],249
jle s12
cmp word [mouseX],300
jg s12
cmp word [mouseY],399
jle s12
cmp word [mouseY],450
jg s12
period:
mov esi,val
loopfindperiod2:
lodsb
cmp al,'.'
je foundval2
cmp al,0
je failedtofindperiod2
jmp loopfindperiod2
foundval2:
mov bl,0
jmp failedtofindperiod2+2
failedtofindperiod2:
mov bl,1
cmp bl,0
je sys_windowloop
mov al,'.'
call addnumber
jmp sys_windowloop
s12:
cmp word [mouseX],374
jle s13
cmp word [mouseX],475
jg s13
cmp word [mouseY],74
jle s13
cmp word [mouseY],125
jg s13
cmp byte [counter],0
je sys_windowloop
backspace:
mov ax,word [numX]
mov word [X],ax
mov word [Y],47
mov word [Color],0xffff
mov esi,val
call sys_printString
mov edi,val
dec byte [counter]
movzx ebx,byte [counter]
add edi,ebx
mov al,0
stosb
mov ax,word [numX]
mov word [X],ax
mov word [Y],47
mov word [Color],0
mov esi,val
call sys_printString
mov byte [state],0
jmp sys_windowloop
s13:
cmp word [mouseX],374
jle s14
cmp word [mouseX],475
jg s14
cmp word [mouseY],129
jle s14
cmp word [mouseY],180
jg s14
call clearscreen
call clearfpu
fninit
fldz
fst qword [answer]
mov ecx,16
mov edi,intval
mov al,0
repe stosb
jmp sys_windowloop
s14:
cmp word [mouseX],374
jle s15
cmp word [mouseX],475
jg s15
cmp word [mouseY],184
jle s15
cmp word [mouseY],235
jg s15
addition:
call atof
call clearfpu
fninit
fld qword [tmp2]
fld qword [answer]
fadd st0,st1
fst qword [answer]
call clearscreen
mov byte [state],0
jmp sys_windowloop
s15:
cmp word [mouseX],374
jle s16
cmp word [mouseX],475
jg s16
cmp word [mouseY],239
jle s16
cmp word [mouseY],290
jg s16
subtraction:
call atof
call clearfpu
fninit
fld qword [tmp2]
fld qword [answer]
fsub st0,st1
fst qword [answer]
call clearscreen
mov byte [state],0
jmp sys_windowloop
s16:
cmp word [mouseX],374
jle s17
cmp word [mouseX],475
jg s17
cmp word [mouseY],294
jle s17
cmp word [mouseY],345
jg s17
multiplication:
call atof
call clearfpu
fninit
fld qword [tmp2]
fld qword [answer]
fmul st0,st1
fst qword [answer]
call clearscreen
mov byte [state],0
jmp sys_windowloop
s17:
cmp word [mouseX],374
jle s18
cmp word [mouseX],475
jg s18
cmp word [mouseY],349
jle s18
cmp word [mouseY],400
jg s18
division:
call atof
call clearfpu
fninit
fld qword [tmp2]
fld qword [answer]
fdiv st0,st1
fst qword [answer]
call clearscreen
mov byte [state],0
jmp sys_windowloop
s18:
cmp word [mouseX],374
jle s19
cmp word [mouseX],475
jg s19
cmp word [mouseY],404
jle s19
cmp word [mouseY],455
jg s19
squareroot:
call clearfpu
fninit
fld qword [answer]
fsqrt
fst qword [answer]
mov al,0
mov byte [state],0
jmp sys_windowloop
s19:
cmp word [mouseX],49
jle s20
cmp word [mouseX],100
jg s20
cmp word [mouseY],399
jle s20
cmp word [mouseY],450
jg s20
equals:
call clearscreen
call clearfpu
fninit
fstcw [statusword]
mov ax,word [statusword]
or ax,0x0c00
mov word [tmp],ax
fldcw [tmp]
fld qword [answer]
fist dword [intval]
fisub dword [intval]
fldcw [statusword]
mov ecx,9
shiftdecimalloop:
fmul dword [ten]
loop shiftdecimalloop
fist dword [decval]
mov eax,dword [intval]
mov edi,val
mov cl,0
call inttostr
mov esi,val
findperiodloop:
lodsb
cmp al,'.'
jne findperiodloop
mov edi,esi
mov eax,dword [decval]
mov cl,1
call printdecimal
mov ax,word [numX]
mov word [X],ax
mov word [Y],47
mov word [Color],0
mov esi,val
call sys_printString
mov byte [state],0
jmp sys_windowloop
s20:
cmp word [mouseX],499
jle s21
cmp word [mouseX],600
jg s21
cmp word [mouseY],99
jle s21
cmp word [mouseY],150
jg s21
sin:
call clearfpu
fninit
fld qword [answer]
mov eax,180
push eax
fidiv dword [esp]
fldpi
fmul
fsin
fwait
fst qword [answer]
pop eax
mov al,0
mov byte [state],0
jmp sys_windowloop
s21:
cmp word [mouseX],499
jle s22
cmp word [mouseX],600
jg s22
cmp word [mouseY],154
jle s22
cmp word [mouseY],205
jg s22
arcsin:
call clearfpu
fninit
fld qword [answer]
fld st0
fmul st0,st0
fld1
fsubr
fsqrt
fpatan
fst qword [answer]
call clearfpu
fninit
fld qword [answer]
fld qword [radtodeg]
fmul st0,st1
fst qword [answer]
mov al,0
mov byte [state],0
jmp sys_windowloop
s22:
cmp word [mouseX],499
jle s23
cmp word [mouseX],600
jg s23
cmp word [mouseY],209
jle s23
cmp word [mouseY],260
jg s23
cos:
call clearfpu
fninit
fld qword [answer]
mov eax,180
push eax
fidiv dword [esp]
fldpi
fmul
fcos
fwait
fst qword [answer]
pop eax
mov al,0
mov byte [state],0
jmp sys_windowloop
s23:
cmp word [mouseX],499
jle s24
cmp word [mouseX],600
jg s24
cmp word [mouseY],264
jle s24
cmp word [mouseY],315
jg s24
arccos:
call clearfpu
fninit
fld qword [answer]
fld st0
fmul st0,st0
fld1
fsubr
fsqrt
fxch st1
fpatan
fst qword [answer]
call clearfpu
fninit
fld qword [answer]
fld qword [radtodeg]
fmul st0,st1
fst qword [answer]
mov al,0
mov byte [state],0
jmp sys_windowloop
s24:
cmp word [mouseX],499
jle s25
cmp word [mouseX],600
jg s25
cmp word [mouseY],319
jle s25
cmp word [mouseY],370
jg s25
tan:
call clearfpu
fninit
fld qword [answer]
mov eax,180
push eax
fidiv dword [esp]
fldpi
fmul
fst st1
fsin
fxch st1
fcos
fdiv st1,st0
fxch st1
fwait
fst qword [answer]
pop eax
mov al,0
mov byte [state],0
jmp sys_windowloop
s25:
cmp word [mouseX],499
jle s26
cmp word [mouseX],600
jg s26
cmp word [mouseY],374
jle s26
cmp word [mouseY],425
jg s26
arctan:
call clearfpu
fninit
fld qword [answer]
fld1
fpatan
fst qword [answer]
call clearfpu
fninit
fld qword [answer]
fld qword [radtodeg]
fmul st0,st1
fst qword [answer]
mov al,0
mov byte [state],0
jmp sys_windowloop
s26:
jmp sys_windowloop
tmparctan dw 2

findradtodegconvfactor:
fninit
mov eax,constant180
fldpi
fild word [eax]
fdiv st0,st1
fst qword [radtodeg]
ret
constant180 dw 180
radtodeg dq 0

printdecimal:
pusha
push dword [ten]
mov dword [ten],100000000
mov ecx,8
convertdecimal:
mov eax,dword [decval]
mov edx,0
mov ebx,dword [ten]
div ebx
add al,30h
stosb
sub al,30h
mul dword [ten]
sub dword [decval],eax
push eax
push ebx
mov edx,0
mov eax,dword [ten]
mov ebx,10
div ebx
mov dword [ten],eax
pop ebx
pop eax
loop convertdecimal
mov al,0
stosb
pop dword [ten]
popa
mov byte [counter],0
ret

statusword dw 1

inttostr:
pusha
mov ecx,0
mov ebx,10
pushit:
xor edx,edx
div ebx
inc ecx
push edx
test eax,eax
jnz pushit
popit:
pop edx
add dl,30h
pusha
mov al,dl
mov edi,val
movzx ebx,byte [counter]
add edi,ebx
mov byte [edi],al
inc byte [counter]
popa
inc edi
dec ecx
jnz popit
popa
cmp cl,0
jne addzero
mov al,'.'
addperiodorzero:
mov edi,val
movzx ebx,byte [counter]
add edi,ebx
mov byte [edi],al
inc byte [counter]
ret
addzero:
mov al,0
jmp addperiodorzero

atof:
fninit
call clearfpu
mov esi,val
xor eax,eax
integerconv:
lodsb
mov cl,0
cmp al,'.'
je doneintegerconv
mov cl,1
cmp al,0
je doneintegerconv
sub al,30h
movzx eax,al
mov word [tmp],ax
fmul dword [ten]
fiadd word [tmp]
jmp integerconv
doneintegerconv:
cmp cl,1
je skipperiod
fst st1
fsub st0,st0
decimalconv:
lodsb
cmp al,0
je enddecimal
sub al,30h
movzx eax,al
mov word [tmp],ax
movzx ecx,byte [deccount]
multiplydecloop:
fmul dword [ten]
loop multiplydecloop
fiadd word [tmp]
movzx ecx,byte [deccount]
dividedecloop:
fdiv dword [ten]
loop dividedecloop
inc byte [deccount]
jmp decimalconv
enddecimal:
fadd st0,st1
skipperiod:
fst qword [tmp2]
mov byte [deccount],1
ret

deccount db 1

clearfpu:
mov ecx,8
clearfpuloop:
fldz
loop clearfpuloop
mov ecx,100000
clearfpuloop2:
fdecstp
loop clearfpuloop2
ret

addnumber:
push ax
mov esi,val
loopfindperiod:
lodsb
cmp al,'.'
je foundval
cmp al,0
je failedtofindperiod
jmp loopfindperiod
foundval:
mov bl,0
jmp failedtofindperiod+2
failedtofindperiod:
mov bl,1
push bx
mov ax,word [numX]
mov word [X],ax
mov word [Y],47
mov word [Color],0xffff
mov esi,val
call sys_printString
pop bx
pop ax
cmp bl,1
je skipahead
cmp byte [counter],20
je donesub
jmp skipahead2
skipahead:
cmp al,'.'
je skipahead2
cmp byte [counter],10
je donesub
skipahead2:
mov edi,val
movzx ebx,byte [counter]
add edi,ebx
stosb
inc byte [counter]
donesub:
mov ax,word [numX]
mov word [X],ax
mov word [Y],47
mov word [Color],0
mov esi,val
call sys_printString
mov byte [state],0
ret

clearscreen:
mov ax,word [numX]
mov word [X],ax
mov word [Y],47
mov word [Color],0xffff
mov esi,val
call sys_printString
mov edi,val
mov ecx,20
mov al,0
repe stosb
mov byte [counter],0
ret

drawwidgets:
mov ax,50
mov bx,100
mov cx,100
mov dx,150
call sys_drawbox
mov word [X],65
mov word [Y],115
mov esi,onespr
call sys_dispsprite
mov ax,150
mov bx,100
mov cx,200
mov dx,150
call sys_drawbox
mov word [X],165
mov word [Y],115
mov esi,twospr
call sys_dispsprite
mov ax,250
mov bx,100
mov cx,300
mov dx,150
call sys_drawbox
mov word [X],265
mov word [Y],115
mov esi,threespr
call sys_dispsprite
mov ax,50
mov bx,200
mov cx,100
mov dx,250
call sys_drawbox
mov word [X],65
mov word [Y],215
mov esi,fourspr
call sys_dispsprite
mov ax,150
mov bx,200
mov cx,200
mov dx,250
call sys_drawbox
mov word [X],165
mov word [Y],215
mov esi,fivespr
call sys_dispsprite
mov ax,250
mov bx,200
mov cx,300
mov dx,250
call sys_drawbox
mov word [X],265
mov word [Y],215
mov esi,sixspr
call sys_dispsprite
mov ax,50
mov bx,300
mov cx,100
mov dx,350
call sys_drawbox
mov word [X],65
mov word [Y],315
mov esi,sevenspr
call sys_dispsprite
mov ax,150
mov bx,300
mov cx,200
mov dx,350
call sys_drawbox
mov word [X],165
mov word [Y],315
mov esi,eightspr
call sys_dispsprite
mov ax,250
mov bx,300
mov cx,300
mov dx,350
call sys_drawbox
mov word [X],265
mov word [Y],315
mov esi,ninespr
call sys_dispsprite
mov ax,150
mov bx,400
mov cx,200
mov dx,450
call sys_drawbox
mov word [X],165
mov word [Y],415
mov esi,zerospr
call sys_dispsprite
mov ax,50
mov bx,400
mov cx,100
mov dx,450
call sys_drawbox
mov esi,equalspr
mov word [X],65
mov word [Y],415
call sys_dispsprite
mov ax,250
mov bx,400
mov cx,300
mov dx,450
call sys_drawbox
mov esi,periodspr
mov word [X],265
mov word [Y],415
call sys_dispsprite
mov ax,375
mov bx,75
mov cx,475
mov dx,125
call sys_drawbox
mov esi,backspacespr
mov word [X],411
mov word [Y],90
call sys_dispsprite
mov ax,375
mov bx,130
mov cx,475
mov dx,180
call sys_drawbox
mov esi,clearspr
mov word [X],413
mov word [Y],145
call sys_dispsprite
mov ax,375
mov bx,185
mov cx,475
mov dx,235
call sys_drawbox
mov esi,addspr
mov word [X],413
mov word [Y],200
call sys_dispsprite
mov ax,375
mov bx,240
mov cx,475
mov dx,290
call sys_drawbox
mov esi,subspr
mov word [X],413
mov word [Y],255
call sys_dispsprite
mov ax,375
mov bx,295
mov cx,475
mov dx,345
call sys_drawbox
mov esi,mulspr
mov word [X],413
mov word [Y],310
call sys_dispsprite
mov ax,375
mov bx,350
mov cx,475
mov dx,400
call sys_drawbox
mov esi,divspr
mov word [X],413
mov word [Y],365
call sys_dispsprite
mov ax,375
mov bx,405
mov cx,475
mov dx,455
call sys_drawbox
mov esi,sqrspr
mov word [X],413
mov word [Y],420
call sys_dispsprite
mov ax,500
mov bx,100
mov cx,600
mov dx,150
call sys_drawbox
mov esi,fivespr
mov word [X],525
mov word [Y],115
call sys_dispsprite
mov esi,ispr
mov word [X],540
mov word [Y],115
call sys_dispsprite
mov esi,nspr
mov word [X],557
mov word [Y],115
call sys_dispsprite
mov ax,500
mov bx,155
mov cx,600
mov dx,205
call sys_drawbox
mov esi,fivespr
mov word [X],515
mov word [Y],170
call sys_dispsprite
mov esi,ispr
mov word [X],530
mov word [Y],170
call sys_dispsprite
mov esi,nspr
mov word [X],547
mov word [Y],170
call sys_dispsprite
mov byte [buttonornot],1
mov word [Color],0
mov ax,566
mov bx,170
mov cx,579
mov dx,175
call sys_drawbox
mov ax,583
mov bx,165
mov cx,588
mov dx,180
call sys_drawbox
mov byte [buttonornot],0
mov ax,500
mov bx,210
mov cx,600
mov dx,260
call sys_drawbox
mov esi,clearspr
mov word [X],518
mov word [Y],225
call sys_dispsprite
mov esi,zerospr
mov word [X],538
mov word [Y],225
call sys_dispsprite
mov esi,fivespr
mov word [X],558
mov word [Y],225
call sys_dispsprite
mov ax,500
mov bx,265
mov cx,600
mov dx,315
call sys_drawbox
mov esi,clearspr
mov word [X],508
mov word [Y],280
call sys_dispsprite
mov esi,zerospr
mov word [X],528
mov word [Y],280
call sys_dispsprite
mov esi,fivespr
mov word [X],548
mov word [Y],280
call sys_dispsprite
mov byte [buttonornot],1
mov word [Color],0
mov ax,568
mov bx,280
mov cx,581
mov dx,285
call sys_drawbox
mov ax,585
mov bx,275
mov cx,590
mov dx,290
call sys_drawbox
mov byte [buttonornot],0
mov ax,500
mov bx,320
mov cx,600
mov dx,370
call sys_drawbox
mov esi,tspr
mov word [X],520
mov word [Y],335
call sys_dispsprite
mov esi,aspr
mov word [X],537
mov word [Y],335
call sys_dispsprite
mov esi,nspr
mov word [X],557
mov word [Y],335
call sys_dispsprite
mov ax,500
mov bx,375
mov cx,600
mov dx,425
call sys_drawbox
mov esi,tspr
mov word [X],510
mov word [Y],390
call sys_dispsprite
mov esi,aspr
mov word [X],527
mov word [Y],390
call sys_dispsprite
mov esi,nspr
mov word [X],547
mov word [Y],390
call sys_dispsprite
mov byte [buttonornot],1
mov word [Color],0
mov ax,566
mov bx,390
mov cx,579
mov dx,395
call sys_drawbox
mov ax,583
mov bx,385
mov cx,588
mov dx,400
call sys_drawbox
mov byte [buttonornot],0
mov byte [buttonornot],1
mov word [Color],0
mov ax,100
mov bx,25
mov cx,102
mov dx,75
call sys_drawbox
mov ax,348
mov bx,25
mov cx,350
mov dx,75
call sys_drawbox
mov ax,100
mov bx,73
mov cx,348
mov dx,75
call sys_drawbox
mov ax,100
mov bx,25
mov cx,348
mov dx,27
call sys_drawbox
mov byte [buttonornot],0
mov ax,word [numX]
mov word [X],ax
mov word [Y],47
mov word [Color],0
mov esi,val
call sys_printString
ret

getinput:
cmp al,'1'
jne key1
mov al,'1'
call addnumber
jmp sys_windowloop
key1:
cmp al,'2'
jne key2
mov al,'2'
call addnumber
jmp sys_windowloop
key2:
cmp al,'3'
jne key3
mov al,'3'
call addnumber
jmp sys_windowloop
key3:
cmp al,'4'
jne key4
mov al,'4'
call addnumber
jmp sys_windowloop
key4:
cmp al,'5'
jne key5
mov al,'5'
call addnumber
jmp sys_windowloop
key5:
cmp al,'6'
jne key6
mov al,'6'
call addnumber
jmp sys_windowloop
key6:
cmp al,'7'
jne key7
mov al,'7'
call addnumber
jmp sys_windowloop
key7:
cmp al,'8'
jne key8
mov al,'8'
call addnumber
jmp sys_windowloop
key8:
cmp al,'9'
jne key9
mov al,'9'
call addnumber
jmp sys_windowloop
key9:
cmp al,'.'
jne key10
jmp period
key10:
cmp al,08h
jne key11
jmp backspace
key11:
cmp al,'c'
jne skipkey11
sub al,20h
skipkey11:
cmp al,'C'
jne key12
call clearscreen
call clearfpu
fninit
fldz
fst qword [answer]
jmp sys_windowloop
key12:
cmp al,'+'
jne key13
jmp addition
key13:
cmp al,'-'
jne key14
jmp subtraction
key14:
cmp al,'*'
jne key15
jmp multiplication
key15:
cmp al,'/'
jne key16
jmp division
key16:
cmp al,'s'
jne skipkey16
sub al,20h
skipkey16:
cmp al,'S'
jne key17
jmp squareroot
key17:
cmp al,0dh
jne key18
jmp equals
key18:
cmp al,'0'
jne key19
mov al,'0'
call addnumber
jmp sys_windowloop
key19:
cmp al,'d'
jne skipkey19
sub al,20h
skipkey19:
cmp al,'D'
jne key20
jmp sin
key20:
cmp al,'f'
jne skipkey20
sub al,20h
skipkey20:
cmp al,'F'
jne key21
jmp arcsin
key21:
cmp al,'g'
jne skipkey21
sub al,20h
skipkey21:
cmp al,'G'
jne key22
jmp cos
key22:
cmp al,'h'
jne skipkey22
sub al,20h
skipkey22:
cmp al,'H'
jne key23
jmp arccos
key23:
cmp al,'j'
jne skipkey23
sub al,20h
skipkey23:
cmp al,'J'
jne key24
jmp tan
key24:
cmp al,'k'
jne skipkey24
sub al,20h
skipkey24:
cmp al,'K'
jne key25
jmp arctan
key25:
jmp sys_windowloop

onespr:
db 0,0,0,0,1,1,0,0,0,0,2
db 0,0,0,0,1,1,0,0,0,0,2
db 0,0,1,1,1,1,0,0,0,0,2
db 0,0,1,1,1,1,0,0,0,0,2
db 0,0,0,0,1,1,0,0,0,0,2
db 0,0,0,0,1,1,0,0,0,0,2
db 0,0,0,0,1,1,0,0,0,0,2
db 0,0,0,0,1,1,0,0,0,0,2
db 1,1,1,1,1,1,1,1,1,1,2
db 1,1,1,1,1,1,1,1,1,1,3

twospr:
db 0,1,1,1,1,1,1,1,1,1,2
db 0,1,1,1,1,1,1,1,1,1,2
db 0,0,0,0,0,0,0,0,1,1,2
db 0,0,0,0,0,0,0,0,1,1,2
db 0,1,1,1,1,1,1,1,1,1,2
db 0,1,1,1,1,1,1,1,1,1,2
db 0,1,1,0,0,0,0,0,0,0,2
db 0,1,1,0,0,0,0,0,0,0,2
db 0,1,1,1,1,1,1,1,1,1,2
db 0,1,1,1,1,1,1,1,1,1,3

threespr:
db 0,1,1,1,1,1,1,1,1,0,2
db 0,1,1,1,1,1,1,1,1,0,2
db 0,0,0,0,0,0,0,1,1,0,2
db 0,0,0,0,0,0,0,1,1,0,2
db 0,1,1,1,1,1,1,1,1,0,2
db 0,1,1,1,1,1,1,1,1,0,2
db 0,0,0,0,0,0,0,1,1,0,2
db 0,0,0,0,0,0,0,1,1,0,2
db 0,1,1,1,1,1,1,1,1,0,2
db 0,1,1,1,1,1,1,1,1,0,3

fourspr:
db 0,1,1,0,0,0,1,1,0,0,2
db 0,1,1,0,0,0,1,1,0,0,2
db 0,1,1,0,0,0,1,1,0,0,2
db 0,1,1,1,1,1,1,1,1,1,2
db 0,1,1,1,1,1,1,1,1,1,2
db 0,0,0,0,0,0,1,1,0,0,2
db 0,0,0,0,0,0,1,1,0,0,2
db 0,0,0,0,0,0,1,1,0,0,2
db 0,0,0,0,0,0,1,1,0,0,2
db 0,0,0,0,0,0,1,1,0,0,3

fivespr:
db 1,1,1,1,1,1,1,1,1,0,2
db 1,1,1,1,1,1,1,1,1,0,2
db 1,1,0,0,0,0,0,0,0,0,2
db 1,1,0,0,0,0,0,0,0,0,2
db 1,1,1,1,1,1,1,1,1,0,2
db 1,1,1,1,1,1,1,1,1,0,2
db 0,0,0,0,0,0,0,1,1,0,2
db 0,0,0,0,0,0,0,1,1,0,2
db 1,1,1,1,1,1,1,1,1,0,2
db 1,1,1,1,1,1,1,1,1,0,3

sixspr:
db 0,1,1,1,1,1,1,1,1,0,2
db 0,1,1,1,1,1,1,1,1,0,2
db 0,1,1,0,0,0,0,0,0,0,2
db 0,1,1,0,0,0,0,0,0,0,2
db 0,1,1,1,1,1,1,1,1,0,2
db 0,1,1,1,1,1,1,1,1,0,2
db 0,1,1,0,0,0,0,1,1,0,2
db 0,1,1,0,0,0,0,1,1,0,2
db 0,1,1,1,1,1,1,1,1,0,2
db 0,1,1,1,1,1,1,1,1,0,3

sevenspr:
db 0,1,1,1,1,1,1,1,1,0,2
db 0,1,1,1,1,1,1,1,1,0,2
db 0,0,0,0,0,0,0,1,1,0,2
db 0,0,0,0,0,0,0,1,1,0,2
db 0,0,0,0,0,0,0,1,1,0,2
db 0,0,0,0,0,0,0,1,1,0,2
db 0,0,0,0,0,0,0,1,1,0,2
db 0,0,0,0,0,0,0,1,1,0,2
db 0,0,0,0,0,0,0,1,1,0,2
db 0,0,0,0,0,0,0,1,1,0,3

eightspr:
db 0,1,1,1,1,1,1,1,1,0,2
db 0,1,1,1,1,1,1,1,1,0,2
db 0,1,1,0,0,0,0,1,1,0,2
db 0,1,1,0,0,0,0,1,1,0,2
db 0,1,1,1,1,1,1,1,1,0,2
db 0,1,1,1,1,1,1,1,1,0,2
db 0,1,1,0,0,0,0,1,1,0,2
db 0,1,1,0,0,0,0,1,1,0,2
db 0,1,1,1,1,1,1,1,1,0,2
db 0,1,1,1,1,1,1,1,1,0,3

ninespr:
db 0,1,1,1,1,1,1,1,1,0,2
db 0,1,1,1,1,1,1,1,1,0,2
db 0,1,1,0,0,0,0,1,1,0,2
db 0,1,1,0,0,0,0,1,1,0,2
db 0,1,1,1,1,1,1,1,1,0,2
db 0,1,1,1,1,1,1,1,1,0,2
db 0,0,0,0,0,0,0,1,1,0,2
db 0,0,0,0,0,0,0,1,1,0,2
db 0,1,1,1,1,1,1,1,1,0,2
db 0,1,1,1,1,1,1,1,1,0,3

zerospr:
db 0,1,1,1,1,1,1,1,1,0,2
db 0,1,1,1,1,1,1,1,1,0,2
db 0,1,1,0,0,0,0,1,1,0,2
db 0,1,1,0,0,0,0,1,1,0,2
db 0,1,1,0,0,0,0,1,1,0,2
db 0,1,1,0,0,0,0,1,1,0,2
db 0,1,1,0,0,0,0,1,1,0,2
db 0,1,1,0,0,0,0,1,1,0,2
db 0,1,1,1,1,1,1,1,1,0,2
db 0,1,1,1,1,1,1,1,1,0,3

equalspr:
db 1,1,1,1,1,1,1,1,1,1,2
db 1,1,1,1,1,1,1,1,1,1,2
db 0,0,0,0,0,0,0,0,0,0,2
db 0,0,0,0,0,0,0,0,0,0,2
db 0,0,0,0,0,0,0,0,0,0,2
db 0,0,0,0,0,0,0,0,0,0,2
db 0,0,0,0,0,0,0,0,0,0,2
db 0,0,0,0,0,0,0,0,0,0,2
db 1,1,1,1,1,1,1,1,1,1,2
db 1,1,1,1,1,1,1,1,1,1,3

periodspr:
db 0,0,0,0,0,0,0,0,0,0,2
db 0,0,0,0,0,0,0,0,0,0,2
db 0,0,0,0,0,0,0,0,0,0,2
db 0,0,0,0,0,0,0,0,0,0,2
db 0,0,0,0,0,0,0,0,0,0,2
db 0,0,0,0,0,0,0,0,0,0,2
db 0,0,0,0,0,0,0,0,0,0,2
db 0,0,0,1,1,1,1,0,0,0,2
db 0,0,0,1,1,1,1,0,0,0,2
db 0,0,0,1,1,1,1,0,0,0,3

backspacespr:
db 0,0,0,0,0,0,0,0,0,0,2
db 0,0,0,0,0,0,0,0,0,0,2
db 0,0,0,0,1,0,0,0,0,0,2
db 0,0,0,1,1,0,0,0,0,0,2
db 0,0,1,1,1,1,1,1,1,1,2
db 0,0,1,1,1,1,1,1,1,1,2
db 0,0,0,1,1,0,0,0,0,0,2
db 0,0,0,0,1,0,0,0,0,0,2
db 0,0,0,0,0,0,0,0,0,0,2
db 0,0,0,0,0,0,0,0,0,0,3

clearspr:
db 1,1,1,1,1,1,1,1,1,1,2
db 1,1,1,1,1,1,1,1,1,1,2
db 1,1,0,0,0,0,0,0,0,0,2
db 1,1,0,0,0,0,0,0,0,0,2
db 1,1,0,0,0,0,0,0,0,0,2
db 1,1,0,0,0,0,0,0,0,0,2
db 1,1,0,0,0,0,0,0,0,0,2
db 1,1,0,0,0,0,0,0,0,0,2
db 1,1,1,1,1,1,1,1,1,1,2
db 1,1,1,1,1,1,1,1,1,1,3

addspr:
db 0,0,0,0,1,1,0,0,0,0,2
db 0,0,0,0,1,1,0,0,0,0,2
db 0,0,0,0,1,1,0,0,0,0,2
db 0,0,0,0,1,1,0,0,0,0,2
db 1,1,1,1,1,1,1,1,1,1,2
db 1,1,1,1,1,1,1,1,1,1,2
db 0,0,0,0,1,1,0,0,0,0,2
db 0,0,0,0,1,1,0,0,0,0,2
db 0,0,0,0,1,1,0,0,0,0,2
db 0,0,0,0,1,1,0,0,0,0,3

subspr:
db 0,0,0,0,0,0,0,0,0,0,2
db 0,0,0,0,0,0,0,0,0,0,2
db 0,0,0,0,0,0,0,0,0,0,2
db 0,0,0,0,0,0,0,0,0,0,2
db 1,1,1,1,1,1,1,1,1,1,2
db 1,1,1,1,1,1,1,1,1,1,2
db 0,0,0,0,0,0,0,0,0,0,2
db 0,0,0,0,0,0,0,0,0,0,2
db 0,0,0,0,0,0,0,0,0,0,2
db 0,0,0,0,0,0,0,0,0,0,3

mulspr:
db 1,1,0,0,0,0,0,0,1,1,2
db 1,1,0,0,0,0,0,0,1,1,2
db 0,0,1,1,0,0,1,1,0,0,2
db 0,0,1,1,0,0,1,1,0,0,2
db 0,0,0,0,1,1,0,0,0,0,2
db 0,0,0,0,1,1,0,0,0,0,2
db 0,0,1,1,0,0,1,1,0,0,2
db 0,0,1,1,0,0,1,1,0,0,2
db 1,1,0,0,0,0,0,0,1,1,2
db 1,1,0,0,0,0,0,0,1,1,3

divspr:
db 0,0,0,0,1,1,0,0,0,0,2
db 0,0,0,0,1,1,0,0,0,0,2
db 0,0,0,0,0,0,0,0,0,0,2
db 0,0,0,0,0,0,0,0,0,0,2
db 1,1,1,1,1,1,1,1,1,1,2
db 1,1,1,1,1,1,1,1,1,1,2
db 0,0,0,0,0,0,0,0,0,0,2
db 0,0,0,0,0,0,0,0,0,0,2
db 0,0,0,0,1,1,0,0,0,0,2
db 0,0,0,0,1,1,0,0,0,0,3

sqrspr:
db 0,0,1,1,1,1,1,1,1,1,2
db 0,0,1,1,1,1,1,1,1,1,2
db 0,0,1,1,0,0,0,0,0,0,2
db 0,0,1,1,0,0,0,0,0,0,2
db 0,0,1,1,0,0,0,0,0,0,2
db 0,0,1,1,0,0,0,0,0,0,2
db 0,0,1,1,0,0,0,0,0,0,2
db 1,1,1,1,0,0,0,0,0,0,2
db 0,1,1,1,0,0,0,0,0,0,2
db 0,0,1,1,0,0,0,0,0,0,3

ispr:
db 0,0,0,0,1,1,0,0,0,0,2
db 0,0,0,0,1,1,0,0,0,0,2
db 0,0,0,0,1,1,0,0,0,0,2
db 0,0,0,0,1,1,0,0,0,0,2
db 0,0,0,0,1,1,0,0,0,0,2
db 0,0,0,0,1,1,0,0,0,0,2
db 0,0,0,0,1,1,0,0,0,0,2
db 0,0,0,0,1,1,0,0,0,0,2
db 0,0,0,0,1,1,0,0,0,0,2
db 0,0,0,0,1,1,0,0,0,0,3

nspr:
db 1,1,1,1,1,0,1,1,0,0,2
db 1,1,1,1,1,0,1,1,0,0,2
db 1,1,0,1,1,0,1,1,0,0,2
db 1,1,0,1,1,0,1,1,0,0,2
db 1,1,0,1,1,0,1,1,0,0,2
db 1,1,0,1,1,0,1,1,0,0,2
db 1,1,0,1,1,0,1,1,0,0,2
db 1,1,0,1,1,0,1,1,0,0,2
db 1,1,0,1,1,1,1,1,0,0,2
db 1,1,0,1,1,1,1,1,0,0,3

tspr:
db 1,1,1,1,1,1,1,1,1,1,2
db 1,1,1,1,1,1,1,1,1,1,2
db 0,0,0,0,1,1,0,0,0,0,2
db 0,0,0,0,1,1,0,0,0,0,2
db 0,0,0,0,1,1,0,0,0,0,2
db 0,0,0,0,1,1,0,0,0,0,2
db 0,0,0,0,1,1,0,0,0,0,2
db 0,0,0,0,1,1,0,0,0,0,2
db 0,0,0,0,1,1,0,0,0,0,2
db 0,0,0,0,1,1,0,0,0,0,3

aspr:
db 0,0,0,0,1,1,0,0,0,0,2
db 0,0,0,0,1,1,0,0,0,0,2
db 0,0,1,1,0,0,1,1,0,0,2
db 0,0,1,1,0,0,1,1,0,0,2
db 0,0,1,1,0,0,1,1,0,0,2
db 0,0,1,1,1,1,1,1,0,0,2
db 0,0,1,1,1,1,1,1,0,0,2
db 0,0,1,1,0,0,1,1,0,0,2
db 0,0,1,1,0,0,1,1,0,0,2
db 0,0,1,1,0,0,1,1,0,0,3