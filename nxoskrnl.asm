;Doors NX kernel Made by David Badiei
use32
org 30000h

apiVector:
jmp sys_main
jmp sys_plotpixel
jmp sys_setupScreen
jmp sys_drawbox
jmp sys_printString
jmp sys_getpixel
jmp sys_dispsprite
jmp sys_singleLineEntry
jmp sys_loadfile
buttonornot db 0
entrysuccess db 0
loadsuccess db 0
state db 0
X dw 0
Y dw 0
Color dw 0
mouseX dw 0
mouseY dw 0
jmp sys_getoldlocation
ioornot db 0
jmp sys_term_setupScreen
jmp sys_term_redrawbuffer
jmp sys_term_movecursor
jmp sys_term_printChar
jmp sys_term_getcursor
keydata db 0
jmp sys_term_getkey
jmp sys_term_printString
jmp sys_term_getString
jmp sys_printChar
jmp sys_getrootdirectory
jmp sys_deletefile
jmp sys_renamefile
jmp sys_charforward
jmp sys_charbackward
jmp sys_createfile
jmp sys_writefile
jmp sys_makefnfat12
jmp sys_windowloop
jmp sys_nobgtasks
mouseaddress dd 0
keybaddress dd 0
bgtaskaddress dd 0
keyormouse db 0
jmp sys_mouseemuenable
jmp sys_mouseemudisable
jmp sys_overwrite
jmp sys_genrandnumber

sys_main:
mov dword [vidmem],eax

mov byte [keyormouse],dl

mov al,byte [201d2h+3]
mov byte [bootdev],al
mov ax,word [201c9h+3]
mov word [SectorsPerTrack],ax
mov ax,word [201cbh+3]
mov word [Sides],ax
mov al,byte [201fch]
mov byte [picmaster],al
mov al,byte [201fdh]
mov byte [picslave],al

sgdt [gdtloc]
sidt [idtloc]

mov edi,idt 
mov cx,45
idtloop:
mov ebx,unhandled
mov [edi],bx
shr ebx,16
mov [edi+6],bx
add edi,8
loop idtloop

mov ebx,pithandler
mov [idt31+8],bx
shr ebx,16
mov [idt31+14],bx

mov ebx,kbhandler
mov [idt32+8],bx
shr ebx,16
mov [idt32+14],bx

mov ebx,mousehandler
mov [idt31+104],bx
shr ebx,16
mov [idt31+110],bx

call pic32
lidt [idtptr]
cmp byte [keyormouse],0
je skipmousedrv
call initmouse
skipmousedrv:
call initKeyboard
mov eax,0x8253
call initPIT
mov ecx,32
readyforirq:
mov al,0x20
out 0x20,al
out 0xa0,al
loop readyforirq
cmp byte [keyormouse],1
jne skippicenable
mov byte [picslave],0xef
jmp skippicdisable
skippicenable:
mov byte [picslave],0xff
skippicdisable:
sti

mov esi,titleString
call sys_setupScreen

call drawWidgets

mov al,0xf8
out 0x21,al
mov al,byte [picslave]
out 0xa1,al

mov word [mouseX],320
mov word [mouseY],240
mov word [Color],0
call drawcursor

mov byte [autoornot],1
mov esi,autoFN
mov edi,program
call sys_loadfile
cmp byte [loadsuccess],1
je doneautoex
mov esi,program
mov edi,autoFN
mov ecx,13
repe movsb
mov esi,autoFN
mov edi,program
call sys_loadfile
jmp otherprogramcontinue
doneautoex:

osstart:
mov dword [mouseaddress],lbuttonclick
mov dword [keybaddress],sys_windowloop
mov dword [bgtaskaddress],sys_nobgtasks
jmp sys_windowloop

jmp $

titleString db 'Doors NX 1.51 Copyright (C) 2021 David Badiei',0
table db 0x01,"1234567890-=",0X0E,0x0F,'qwertyuiop[]',0x1C,0,"asdfghjkl;'",0,0,0,"zxcvbnm,./",0,0,0," ",0
tableCaps db 0x01,"1234567890-=",0X0E,0x0F,'QWERTYUIOP[]',0x1C,0,"ASDFGHJKL;'",0,0,0,"ZXCVBNM,./",0,0,0," ",0
tableShift db 0x01,"!@#$%^&*()_+",0X0E,0x0F,'QWERTYUIOP{}',0x1C,0,"ASDFGHJKL:",0x22,0,0,0,"ZXCVBNM<>?",0,0,0," ",0
msoldloc times 8 dw 0xffff
prevmouseX dw 320
prevmouseY dw 240
prevColor dw 0
bootdev db 0
tableNum db '789-456+1230.',0
testbyte2 db 0
vidmem dd 0
autoornot db 0
mouseemutoggle db 0
calcFN db 'NXCALC.EXE',0
fileFN db 'NXFILE.EXE',0
editFN db 'NXEDIT.EXE',0
autoFN db 'AUTOEX.CFG',0

fontlocation:
incbin 'fontdata.bin'

sys_plotpixel:
pusha
movzx ecx,word [Color]
movzx eax,word [X]
movzx ebx,word [Y]
imul eax,2
imul ebx,1280
add eax,ebx
mov edi,dword [vidmem]
add edi,eax
mov ax,cx
stosw
popa
ret

sys_getpixel:
push ebx
movzx eax,word [X]
movzx ebx,word [Y]
imul eax,2
imul ebx,1280
add eax,ebx
mov esi,dword [vidmem]
add esi,eax
pop ebx
lodsw
ret

sys_drawbox:
pusha
push ax
mov al,0xfa
out 0x21,al
mov al,0xff
out 0xa1,al
pop ax
mov word [X],ax
mov word [Y],bx
cmp byte [buttonornot],0
jne drawbutton1
mov word [Color],0xBDF7
drawbutton1:
call sys_plotpixel
inc word [X]
cmp word [X],cx
jne drawbutton1
mov word [X],ax
inc word [Y]
cmp word [Y],dx
jne drawbutton1
push ax
mov al,0xf8
out 0x21,al
mov al,byte [picslave]
out 0xa1,al
pop ax
popa
ret

sys_setupScreen:
cli
push ax
mov al,0xfa
out 0x21,al
mov al,0xff
out 0xa1,al
pop ax
;Draw background
mov ax,0xffff
mov edi,dword [vidmem]
mov ecx,0xfffff
repe stosw
;Draw titlebar
mov ax,0x0057
mov edi,dword [vidmem]
mov cx,8320
repe stosw
;Write title string
mov word [X],1
mov word [Y],3
mov word [Color],0xffff
call sys_printString
;Draw Close Button
mov byte [buttonornot],1
mov ax,621
mov bx,2
mov cx,636
mov dx,11
mov word [Color],0xF800
call sys_drawbox
mov byte [buttonornot],0
mov word [X],626
mov word [Y],3
xor dh,dh
mov dl,'X'
mov word [Color],0xffff
call sys_printChar
push ax
mov al,0xf8
out 0x21,al
mov al,byte [picslave]
out 0xa1,al
pop ax
sti
ret

sys_printString:
push ax
mov al,0xfa
out 0x21,al
mov al,0xff
out 0xa1,al
pop ax
xor eax,eax
xor ebx,ebx
xor ecx,ecx
xor edx,edx
push word [X]
loopprint:
cmp word [Y],480
jg donestr
lodsb
mov dl,al
test al,al
jz donestr
cmp al,0ah
je newline
cmp word [X],635
jge endofline
cmp byte [cutter],1
je continueprint
call sys_printChar
continueprint:
jmp loopprint
newline:
mov byte [cutter],0
pop word [X]
add word [Y],8
push word [X]
jmp continueprint
donestr:
pop word [X]
push ax
mov al,0xf8
out 0x21,al
mov al,byte [picslave]
out 0xa1,al
pop ax
ret
endofline:
mov byte [cutter],1
jmp loopprint
cutter db 0

sys_charforward:
pusha
push esi
findendoftextblock:
lodsb
test al,al
jz foundendoftext
jmp findendoftextblock
foundendoftext:
pop edi
loopforward:
mov al,byte [esi]
mov byte [esi+1],al
dec esi
cmp esi,edi
jl doneforward
jmp loopforward
doneforward:
inc dword [ebx]
inc dword [ecx]
popa
ret

sys_charbackward:
pusha
dec esi
loopbackward:
mov al,byte [esi+1]
mov byte [esi],al
inc esi
cmp byte [esi],0
jne loopbackward
dec dword [ebx]
dec dword [ecx]
popa
ret

sys_singleLineEntry:
mov byte [state],9
mov byte [entrysuccess],0
pusha
mov byte [maxval],al
push esi
mov ax,150
mov bx,200
mov cx,500
mov dx,268
call sys_drawbox
mov byte [buttonornot],1
mov ax,175
mov bx,220
mov cx,475
mov dx,232
mov word [Color],0xffff
call sys_drawbox
mov ax,284
mov bx,240
mov cx,354
mov dx,260
mov word [Color],0xFFFF
call sys_drawbox
mov byte [buttonornot],0
mov word [X],301
mov word [Y],245
mov word [Color],0
mov esi,cancel
call sys_printString
pop esi
mov word [X],152
mov word [Y],202
mov word [Color],0
call sys_printString
call sys_getoldlocation
cmp byte [otherprog],1
je doneentry
mov dword [mouseaddress],lbuttonclick4
mov dword [keybaddress],getinput
mov dword [bgtaskaddress],sys_nobgtasks
jmp sys_windowloop
doneentry:
popa
mov word [counterdel],0
mov word [lineX],175
mov word [lineY],222
mov byte [otherprog],0
ret

sys_getrootdirectory:
pusha
mov ax,19
call twelvehts2
mov edi,disk_buffer
mov dl,byte [bootdev]
mov al,14
call readsectors
popa
ret

sys_term_setupScreen:
mov esi,filename
call sys_setupScreen
mov ax,0
mov bx,0
call sys_term_movecursor
call sys_getoldlocation
mov ecx,5985
mov edi,terminalbuffer
mov al,0
repe stosb
ret

sys_term_redrawbuffer:
mov esi,terminalbuffer
mov word [X],0
mov word [Y],14
call sys_printString
ret

sys_term_movecursor:
pusha
and ecx,0xffff
and edx,0xffff
mov byte [termX],ah
mov byte [termY],bh
mov word [Color],0xffff
call drawcaret
mov byte [termX],al
mov byte [termY],bl
mov word [Color],0
call drawcaret
popa
ret

sys_term_getcursor:
mov al,byte [termX]
mov bl,byte [termY]
ret

sys_term_printChar:
pusha
push ax
cmp al,0x0d
je termnewline1
cmp al,0
je donemove
cmp byte [termX],105
je termnewline2
continuetoprint:
movzx eax,byte [termX]
mov dx,6
mul dx
inc ax
mov word [X],ax
movzx eax,byte [termY]
mov dx,8
mul dx
add ax,15
mov word [Y],ax
push word [X]
push word [Y]
pusha
mov byte [buttonornot],1
mov ax,word [X]
mov bx,word [Y]
mov cx,ax
add cx,5
mov dx,bx
add dx,7
mov word [Color],0xffff
call sys_drawbox
mov byte [buttonornot],0
popa
pop word [Y]
pop word [X]
pop ax
movzx dx,al
push ax
mov word [Color],0
call sys_printChar
mov cl,1
continuetomove:
mov ah,byte [termX]
inc byte [termX]
mov al,byte [termX]
mov bh,byte [termY]
mov bl,byte [termY]
call sys_term_movecursor
pop ax
inc word [termpos]
mov edi,terminalbuffer
add di,word [termpos]
mov byte [edi],al
skipstosb:
popa
ret
termnewline1:
mov cl,0
cmp byte [termY],57
je scrolltermdown
continuenewline1:
mov word [Color],0xffff
call drawcaret
mov byte [termX],-1
inc byte [termY]
pop ax
mov al,0x0a
push ax
mov cl,0
jmp continuetomove
termnewline2:
mov word [Color],0xffff
call drawcaret
mov byte [termX],0
inc byte [termY]
pop ax
mov al,0x0a
push ax
jmp continuetoprint
donemove:
pop ax
popa
ret
scrolltermdown:
pusha
mov word [Color],0xffff
push edi
mov edi,dword [vidmem]
add edi,19200
mov ecx,297600
mov ax,0xffff
repe stosw
pop edi
mov esi,terminalbuffer
inc esi
mov word [X],1
mov word [Y],15
call sys_printString
mov esi,terminalbuffer
mov cx,0
inc esi
findnewline:
lodsb
inc cx
cmp al,10
jne findnewline
sub word [termpos],cx
movzx ecx,word [termpos]
mov edi,terminalbuffer
inc edi
repe movsb
mov al,0
stosb
stosb
mov esi,terminalbuffer
inc esi
skipclear:
mov word [Color],0
mov word [X],1
mov word [Y],15
call sys_printString
push esi
mov byte [buttonornot],1
mov ax,0
mov bx,471
mov cx,640
mov dx,480
mov word [Color],0xffff
call sys_drawbox
mov byte [buttonornot],0
call sys_term_getcursor
mov ah,al
mov bh,bl
mov bl,56
call sys_term_movecursor
pop esi
push edi
mov edi,esi
mov al,0
stosb
pop edi
popa
cmp cl,0
je continuenewline1

terminalbuffer equ 10000h
termX db 0
termY db 0
termpos dw 0

sys_term_getkey:
hlt
cmp byte [state],9
je lbuttonclick6
cmp byte [ioornot],1
je sys_term_getkey
ret
jmp sys_term_getkey

lbuttonclick6:
cmp word [mouseX],619
jle s61
cmp word [mouseX],636
jg s61
cmp word [mouseY],1
jle s61
cmp word [mouseY],13
jg s61
mov esp,0xffc
ret
s61:
jmp sys_term_getkey

sys_term_printString:
pusha
loop1:
lodsb
test al,al
jz donetermprintstring
call sys_term_printChar
jmp loop1
donetermprintstring:
popa
ret

sys_term_getString:
pusha
mov byte [loc],0
mov byte [maxstrlength],al
getStringloop:
call sys_term_getkey
mov al,byte [keydata]
cmp al,0x0d
je enterpress1
cmp al,0x08
je backspace2
cmp al,0
je getStringloop
mov bl,byte [maxstrlength]
cmp byte [loc],bl
je getStringloop
stosb
call sys_term_printChar
inc byte [loc]
jmp getStringloop
enterpress1:
call sys_term_printChar
mov byte [loc],0
popa
ret
backspace2:
cmp byte [loc],0
je getStringloop
call sys_term_getcursor
mov cl,0
cmp al,0
jle reducey
continuebackspace:
call sys_term_getcursor
mov ah,al
dec al
mov bh,bl
call sys_term_movecursor
mov al,' '
call sys_term_printChar
call sys_term_getcursor
mov cl,1
cmp al,0
je reducey
continuebackspace2:
call sys_term_getcursor
mov ah,al
dec al
mov bh,bl
call sys_term_movecursor
dec edi
mov byte [edi],0
dec byte [loc]
pushad
dec word [termpos]
mov edi,terminalbuffer
add di,word [termpos]
mov byte [edi],0
dec word [termpos]
popad
jmp getStringloop
reducey:
mov bh,bl
dec bl
mov ah,al
mov al,105
call sys_term_movecursor
cmp cl,0
je continuebackspace
cmp cl,1
je continuebackspace2
maxstrlength db 0
loc db 0

drawcaret:
pusha
movzx eax,byte [termX]
mov dx,6
mul dx
mov word [X],ax
movzx eax,byte [termY]
mov dx,8
mul dx
add ax,15
mov word [Y],ax
mov cx,7
caretLoop:
call sys_plotpixel
inc word [Y]
loop caretLoop
popa
ret

getinput:
push ax
mov ax,word [X]
mov bx,word [Y]
mov cx,word [lineX]
mov dx,word [lineY]
mov word [X],cx
mov word [Y],dx
pop ax
cmp byte [keydata],0
je windowloop
cmp al,0dh
je enterpress
cmp al,08h
je backspace1
movzx bx,byte [maxval]
cmp word [counterdel],bx
je windowloop
add word [X],6
add word [lineX],6
mov byte [bslast],0	
drawchar:
push dx
push di
continueinput:
add di,word [counterdel]
mov ax, word [keydata]
stosb
movzx dx,byte [keydata]
call sys_printChar
inc word [counterdel]
pop di
pop dx
mov cx,word [X]
sub cx,6
mov word [lineX],cx
mov word [X],ax
mov word [Y],bx
jmp windowloop
backspace1:
cmp word [counterdel],0
je windowloop
pusha
mov byte [buttonornot],1
mov ax,cx
mov bx,word [Y]
add cx,5
add dx,7
mov word [Color],0ffffh
call sys_drawbox
mov byte [buttonornot],0
popa
push di
add di,word [counterdel]
mov byte [di],0
pop di
mov word [Color],0
dec word [counterdel]
sub word [lineX],6
mov byte [bslast],1
jmp windowloop
enterpress:
jmp doneentry
lineX dw 175
lineY dw 222
counterdel dw 0
bslast db 0
maxval db 0


lbuttonclick4:
cmp word [mouseX],283
jle s41
cmp word [mouseX],354
jg s41
cmp word [mouseY],239
jle s41
cmp word [mouseY],260
jg s41
cli
mov word [counterdel],0
mov word [lineX],175
mov word [lineY],222
mov esi,titleString
call sys_setupScreen
call drawWidgets
call sys_getoldlocation
sti
mov byte [entrysuccess],1
jmp doneentry
s41:
jmp windowloop

sys_printChar:
pusha
cmp dx,0
je exitchar
mov ax,7
mul dx
mov bx,ax
mov cx,0
printLine:
cmp cx,7
je discharend
inc cx
mov esi,fontlocation
add esi,ebx
lodsb
inc bx
push ax
and al,128
cmp al,128
jne nxtprint
call sys_plotpixel
nxtprint:
pop ax
inc word [X]
push ax
and al,64
cmp al,64
jne nxtprintB
call sys_plotpixel
nxtprintB:
pop ax
inc word [X]
push ax
and al,32
cmp al,32
jne nxtprintC
call sys_plotpixel
nxtprintC:
pop ax
inc word [X]
push ax
and al,16
cmp al,16
jne nxtprintD
call sys_plotpixel
nxtprintD:
pop ax
inc word [X]
push ax
and al,8
cmp al,8
jne dislineend
call sys_plotpixel
dislineend:
pop ax
inc word [Y]
sub word [X],4
jmp printLine
discharend:
popa
sub word [Y],7
add word [X],6
ret
exitchar:
popa
sub word [Y],7
ret

sys_windowloop:
windowloop:
call dword [bgtaskaddress]
hlt
cmp byte [state],9
je lbuttonloopclick
cmp byte [ioornot],1
je windowloop
cmp byte [keyormouse],0
je mouseemu
jmp dword [keybaddress]
jmp windowloop
lbuttonloopclick:
cmp byte [keyormouse],0
je resetstate
jmp dword [mouseaddress]
resetstate:
mov byte [state],0
jmp windowloop

sys_mouseemuenable:
mov byte [mouseemutoggle],0
ret

sys_mouseemudisable:
mov byte [mouseemutoggle],1
ret

mouseemu:
cmp byte [mouseemutoggle],1
je donemouseemu
cmp byte [keydata],1
je moveup
cmp byte [keydata],2
je movedown
cmp byte [keydata],3
je moveleft
cmp byte [keydata],4
je moveright
cmp byte [keydata],6
je setstate
donemouseemu:
jmp dword [keybaddress]
moveup:
cmp word [mouseY],4
jle windowloop
call printoldlocation
sub word [mouseY],7
call sys_getoldlocation
mov word [Color],0
call drawcursor
jmp windowloop
movedown:
cmp word [mouseY],476
jge windowloop
call printoldlocation
add word [mouseY],7
call sys_getoldlocation
mov word [Color],0
call drawcursor
jmp windowloop
moveleft:
cmp word [mouseX],4
jle windowloop
call printoldlocation
sub word [mouseX],7
call sys_getoldlocation
mov word [Color],0
call drawcursor
jmp windowloop
moveright:
cmp word [mouseX],636
jge windowloop
call printoldlocation
add word [mouseX],7
call sys_getoldlocation
mov word [Color],0
call drawcursor
jmp windowloop
setstate:
jmp dword [mouseaddress]

sys_nobgtasks:
ret

kbhandler:
cli
mov byte [ioornot],0
pushad
loop:
in al,0x64
and al,0001b
jz invalid
cmp byte [shiftornot],1
je shiftpress
in al,60h
cmp al,0x3b
je f1pressed
cmp al,0x3c
je f2pressed
cmp al,0x48
je uparrow
cmp al,0x50
je downarrow
cmp al,0x4b
je leftarrow
cmp al,0x4d
je rightarrow
cmp al,0x53
je deletepressed
cmp al,0x0e
je backspacepressed
cmp al,0x1c
je enterpressed
cmp al,0x2a
je shiftpress
cmp al,0x36
je shiftpress
cmp al,0x37
je numshiftpressed
cmp al,0x47
jge numpadpressed
cmp al,0x29
je tickpress
cmp al,0x2b
je backslashpress
goback:
test al,80h
jnz loop
cmp al,0x3a
je capsLockpress
and al,0x7f
cmp byte [capsornot],0
jne caps
mov esi,table
jmp continueon
caps:
mov esi,tableCaps
continueon:
dec al
xor ah,ah
add si,ax
mov al,byte [esi]
mov byte [keydata],al
popad
mov al,0x20
out 0x20,al
mov al,byte [keydata]
sti
iret
shiftpress:
loop2:
mov byte [shiftornot],1
in al,64h
test al,1
jz invalid
in al,60h
mov byte [ioornot],0
cmp al,0xaa
je shiftreleased
cmp al,0xb6
je shiftreleased
cmp al,0x29
je tickpress
cmp al,0x2b
je backslashpress
test al,80h
jnz loop2
and al,0x7f
mov esi,tableShift
jmp continueon
shiftreleased:
mov byte [shiftornot],0
jmp loop
backslashpress:
cmp byte [shiftornot],0
jne shiftbackslash
mov byte [keydata],0x5c
jmp setkey
shiftbackslash:
mov byte [keydata],'|'
jmp setkey
tickpress:
cmp byte [shiftornot],0
jne shifttick
mov byte [keydata],0x60
jmp setkey
shifttick:
mov byte [keydata],'~'
setkey:
popad
mov al,0x20
out 0x20,al
mov al,byte [keydata]
sti
iret
numpadpressed:
cmp al,0x57
jg goback
sub al,0x47
mov esi,tableNum
xor ah,ah
add si,ax
mov al,byte [esi]
mov byte [keydata],al
popad
mov al,0x20
out 0x20,al
mov al,byte [keydata]
sti
iret
numshiftpressed:
mov byte [keydata],'*'
popad
mov al,0x20
out 0x20,al
mov al,byte [keydata]
sti
iret
backspacepressed:
mov byte [keydata],0x08
popad
mov al,0x20
out 0x20,al
mov al,byte [keydata]
sti
iret
enterpressed:
mov byte [keydata],0x0d
popad
mov al,0x20
out 0x20,al
mov al,byte [keydata]
sti
iret
capsLockpress:
cmp byte [capsornot],1
je disableCaps
enableCaps:
mov byte [capsornot],1
or  byte [ledstate],0000000100b
mov al,byte [ledstate]
call setLEDs
mov byte [keydata],0
popad
mov al,0x20
out 0x20,al
mov al,byte [keydata]
sti
iret
disableCaps:
mov byte [capsornot],0
and byte [ledstate],0000000000b
mov al,byte [ledstate]
call setLEDs
mov byte [keydata],0
popad
mov al,0x20
out 0x20,al
mov al,byte [keydata]
sti
iret
setLEDs:
mov al,0xed
out 0x60,al
call waitforack
mov al,byte [ledstate]
out 0x60,al
call waitforack
ret
waitforack:
in al,0x64
test al,0x02
jne waitforack
ret
invalid:
mov byte [keydata],0
mov al,0x20
out 0x20,al
popad
sti
iret
arrowkeys:
in al,60h
uparrow:
cmp al,0x48
jne downarrow
mov byte [keydata],1
jmp donearrow
downarrow:
cmp al,0x50
jne leftarrow
mov byte [keydata],2
jmp donearrow
leftarrow:
cmp al,0x4b
jne rightarrow
mov byte [keydata],3
jmp donearrow
rightarrow:
cmp al,0x4d
jne invalid
mov byte [keydata],4
donearrow:
popad
mov al,0x20
out 0x20,al
mov al,byte [keydata]
mov byte [ioornot],0
sti
iret
deletepressed:
mov byte [keydata],5
jmp donearrow
f1pressed:
mov byte [keydata],6
jmp donearrow
f2pressed:
mov byte [keydata],7
jmp donearrow
capsornot db 0
ledstate db 0
shiftornot db 0
initmouse:
pushad
mov bl,0xa8
call kbcmd
call kbread
mov bl,0x20
call kbcmd
call kbread
or al,3
mov byte [ccbyte],al
mov bl,0x60
push eax
call kbcmd
pop eax
call kbwrite
mov bl,0xd4
call kbcmd
mov al,0xf4
call kbwrite
call kbread
donemouseinit:
popad
ret

kbread:
push ecx
push edx
mov ecx,0xffff
krloop:
in al,0x64
test al,1
jnz krready
loop krloop
mov ah,1
jmp krexit
krready:
push ecx
mov ecx,32
krdelay:
loop krdelay
pop ecx
in al,0x60
xor ah,ah
krexit:
pop edx
pop ecx
ret

kbwrite:
push ecx
push edx
mov dl,al
mov ecx,0xffff
kwloop1:
in al,0x64
test al,0x20
jz kwok1
loop kwloop1
mov ah,1
jmp kwexit
kwok1:
in al,0x60
mov ecx,0xffff
kwloop:
in al,0x64
test al,2
jz kwok
loop kwloop
mov ah,1
jmp kwexit
kwok:
mov al,dl
out 0x60,al
mov ecx,0xffff
kwloop3:
in al,0x64
test al,2
jz kwok3
loop kwloop3
mov ah,1
jmp kwexit
kwok3:
mov ah,8
kwloop4:
mov ecx,0xffff
kwloop5:
in al,0x64
test al,1
jnz kwok4
loop kwloop5
dec ah
jnz kwloop4
kwok4:
xor ah,ah
kwexit:
pop edx
pop ecx
ret

kbcmd:
mov cx,0xffff
cwait:
in al,0x64
test al,2
jz csend
loop cwait
jmp cerror
csend:
mov al,bl
out 0x64,al
mov ecx,0xffff
caccept:
in al,0x64
test al,2
jz cok
loop caccept
cerror:
mov ah,1
jmp cexit
cok:
xor ah,ah
cexit:
ret

picallowirq:
push eax
push ebx
push ecx
mov ecx,eax
mov ebx,1
inc ecx
cmp ecx,0x8
jg pic2
pic1:
shl ebx,1
loop pic1
shr ebx,1
not ebx
in al,0x21
and al,bl
out 0x21,al
jmp endallowirq
pic2:
sub ecx,0x8
picloop2:
shl ebx,1
loop picloop2
shr ebx,1
not ebx
in al,0xa1
and al,bl
out 0xa1,al
jmp endallowirq
endallowirq:
pop ecx
pop ebx
pop eax
ret

picdelay:
jmp donepicdelay
donepicdelay:
ret

idt:
%rep 0x1f
dw 0
dw 0x08
db 0
db 8Eh
dw 0
%endrep
idt31:
dw 0
dw 0x08
db 0
db 8Eh
dw 0
idt32:
dw 0
dw 0x08
db 0
db 8Eh
dw 0
%rep 14
dw 0
dw 0x08
db 0
db 8Eh
dw 0
%endrep
idtend:
idtptr:
dw idtend-idt-1
dd idt

pithandler:
pusha
push eax
push ebx
push ecx
mov eax,[irq0fractions]
mov ebx,[irq0ms]
add [systimerfractions],eax
adc [systimerms],ebx
mov byte [ioornot],1
mov al,0x20
out 0x20,al
pop ecx
pop ebx
pop eax
popa
iret

irq0fractions dd 0
irq0ms dd 0
systimerfractions dd 0
systimerms dd 0
pitreloadvalue dw 0
irq0freq dd 0

mousehandler:
pushad
push eax
mov byte [ioornot],1
cmp byte [mouseStep],0
je statePacket
cmp byte [mouseStep],1
je xmovPacket
cmp byte [mouseStep],2
je ymovPacket
statePacket:
in al,0x64
and al,0001b
jz donemouse
call printoldlocation
in al,0x60
test al,0xc0
jnz donemouse
mov byte [state],al
inc byte [mouseStep]
jmp donemouse
xmovPacket:
in al,0x64
and al,0001b
jz donemouse
in al,0x60
mov byte [xmovement],al
inc byte [mouseStep]
jmp donemouse
ymovPacket:
in al,0x64
and al,0001b
jz donemouse
in al,0x60
mov byte [ymovement],al
mov byte [mouseStep],0
endmouse:
mov al,byte [state]
cmp byte [xmovement],0
je checky
movzx bx,byte [xmovement]
test al,00010000b
jz rightmovement
xor bx,0xff
sub word [mouseX],bx
jmp checky	
rightmovement:
add word [mouseX],bx
checky:
cmp byte [ymovement],0
je donemovement
mov al,byte [state]
movzx bx,byte [ymovement]
neg bx
test al,00100000b
jz downmovement
xor bx,0xff
sub word [mouseY],bx
jmp donemovement
downmovement:
add word [mouseY],bx
donemovement:
cmp word [mouseX],636
jge stopmovement1
cmp word [mouseX],0
jle stopmovement2
cmp word [mouseY],476
jge stopmovement3
cmp word [mouseY],0
jle stopmovement4
continuemouse:
cmp byte [state],9
je donemouse
call sys_getoldlocation
cmp byte [state],0
je donemouse
mov word [Color],0
call drawcursor
donemouse:
mov al,0x20
out 0x20,al
out 0xa0,al
pop eax
popad
iret
mouseStep db 0
xmovement db 0
ymovement db 0
stopmovement1:
mov word [mouseX],636
jmp continuemouse
stopmovement2:
mov word [mouseX],0
jmp continuemouse
stopmovement3:
mov word [mouseY],476
jmp continuemouse
stopmovement4:
mov word [mouseY],0
jmp continuemouse

inttostr:
pushad
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
mov dh,0
call sys_printChar
popa
inc edi
dec ecx
jnz popit
popad
ret

initPIT:
pushad
mov eax,0x10000
cmp ebx,18
jbe gotReloadValue
mov eax,1
cmp ebx,1193181
jae gotReloadValue
mov eax,3579545
mov edx,0
div ebx
cmp edx,3579545 / 2
jb l1
inc eax
l1:
mov ebx,3
mov edx,0
div ebx
cmp edx,3 / 2
jb l2
inc eax
l2:
gotReloadValue:
push eax
mov [pitreloadvalue],ax
mov ebx,eax
mov eax,3579545
mov edx,0
div ebx
cmp edx,3579545 / 2
jb l3
inc eax
l3:
mov ebx,3
mov edx,0
div ebx
cmp edx,3 / 2
jb l4
inc eax
l4:
mov [irq0freq],eax
pop ebx
mov eax,0xDBB3A062
mul ebx
shrd eax,edx,10
shr edx,10
mov [irq0ms],edx
mov [irq0fractions],eax
pushfd
cli
mov al,00110100b
out 0x43,al
mov ax,[pitreloadvalue]
out 0x40,al
mov al,ah
out 0x40,al
popfd
popad
ret

unhandled:
push eax
mov byte [ioornot],1
mov al,0x20
out 0x20,al
pop eax
iret

installisr:
push eax
push ebp
mov ebp,eax
mov eax,esi
mov word [idt+ebp*8],ax
shr eax,16
mov word [idt+ebp*8+6],ax
pop ebp
pop eax
ret


initKeyboard:
push eax
mov al,0xed
call ps2write
out 0x60,al
call ps2read
in al,0x60
mov al,000b
call ps2write
out 0x60,al
call ps2read
in al,0x60
mov al,0xf3
call ps2write
out 0x60,al
call ps2read
in al,0x60
mov al,0
call ps2write
out 0x60,al
call ps2read
in al,0x60
end:
pop eax
ret

ps2write:
push eax
waitloop:
in al,0x64
bt ax,1
jnc donewrite
jmp waitloop
donewrite:
pop eax
ret

ps2read:
push eax
waitloop2:
in al,0x64
bt ax,0
jc doneread
jmp waitloop2
doneread:
pop eax
ret

drawcursor:
push word [X]
push word [Y]
mov ax,word [mouseX]
mov word [X],ax
mov ax,word [mouseY]
mov word [Y],ax
call sys_plotpixel
inc word [X]
call sys_plotpixel
inc word [X]
call sys_plotpixel
sub word [X],2
inc word [Y]
call sys_plotpixel
inc word [Y]
call sys_plotpixel
sub word [Y],2
inc word [X]
inc word [Y]
call sys_plotpixel
inc word [X]
inc word [Y]
call sys_plotpixel
inc word [X]
inc word [Y]
call sys_plotpixel
pop word [Y]
pop word [X]
ret

sys_getoldlocation:
pusha
push ax
mov al,0xff
out 0x21,al
pop ax
mov ax,word [mouseX]
mov word [prevmouseX],ax
mov word [X],ax
mov ax,word [mouseY]
mov word [prevmouseY],ax
mov word [Y],ax
call sys_getpixel
;mov ax,word [prevColor]
mov word [msoldloc],ax
inc word [X]
call sys_getpixel
;mov ax,word [prevColor]
mov word [msoldloc+2],ax
inc word [X]
call sys_getpixel
;mov ax,word [prevColor]
mov word [msoldloc+4],ax
sub word [X],2
inc word [Y]
call sys_getpixel
;mov ax,word [prevColor]
mov word [msoldloc+6],ax
inc word [Y]
call sys_getpixel
;mov ax,word [prevColor]
mov word [msoldloc+8],ax
sub word [Y],2
inc word [X]
inc word [Y]
call sys_getpixel
;mov ax,word [prevColor]
mov word [msoldloc+10],ax
inc word [X]
inc word [Y]
call sys_getpixel
;mov ax,word [prevColor]
mov word [msoldloc+12],ax
inc word [X]
inc word [Y]
call sys_getpixel
;mov ax,word [prevColor]
mov word [msoldloc+14],ax
push ax
mov al,0xf8
out 0x21,al
pop ax
popa
ret

printoldlocation:
pusha
mov ax,word [prevmouseX]
mov word [X],ax
mov ax,word [prevmouseY]
mov word [Y],ax
mov ax,word [msoldloc]
mov word [Color],ax
call sys_plotpixel
inc word [X]
mov ax,word [msoldloc+2]
mov word [Color],ax
call sys_plotpixel
inc word [X]
mov ax,word [msoldloc+4]
mov word [Color],ax
call sys_plotpixel
sub word [X],2
inc word [Y]
mov ax,word [msoldloc+6]
mov word [Color],ax
call sys_plotpixel
inc word [Y]
mov ax,word [msoldloc+8]
mov word [Color],ax
call sys_plotpixel
sub word [Y],2
inc word [X]
inc word [Y]
mov ax,word [msoldloc+10]
mov word [Color],ax
call sys_plotpixel
inc word [X]
inc word [Y]
mov ax,word [msoldloc+12]
mov word [Color],ax
call sys_plotpixel
inc word [X]
inc word [Y]
mov ax,word [msoldloc+14]
mov word [Color],ax
call sys_plotpixel
popa
ret

lbuttonclick:
cmp word [mouseX],619
jle s1
cmp word [mouseX],636
jg s1
cmp word [mouseY],1
jle s1
cmp word [mouseY],13
jg s1
jmp poweroptions
s1:
cmp word [mouseX],99
jle s2
cmp word [mouseX],150
jg s2
cmp word [mouseY],99
jle s2
cmp word [mouseY],150
jg s2
jmp distimedate
s2:
cmp word [mouseX],279
jle s3
cmp word [mouseX],330
jg s3
cmp word [mouseY],99
jle s3
cmp word [mouseY],150
jg s3
s3:
cmp word [mouseX],189
jle s4
cmp word [mouseX],240
jg s4
cmp word [mouseY],199
jle s4
cmp word [mouseY],250
jg s4
jmp loadprogram
s4:
cmp word [mouseX],369
jle s5
cmp word [mouseX],420
jg s5
cmp word [mouseY],199
jle s5
cmp word [mouseY],250
jg s5
mov byte [otherprog],1
call sys_singleLineEntry
mov esi,titleString
call sys_setupScreen
call drawWidgets
mov esi,calcFN
mov edi,program
call sys_loadfile
jmp otherprogramcontinue
mov byte [state],0
jmp osstart
s5:
cmp word [mouseX],279
jle s6
cmp word [mouseX],330
jg s6
cmp word [mouseY],99
jle s6
cmp word [mouseY],150
jg s6
mov byte [otherprog],1
call sys_singleLineEntry
mov esi,titleString
call sys_setupScreen
call drawWidgets
mov esi,fileFN
mov edi,program
call sys_loadfile
jmp otherprogramcontinue
mov byte [state],0
jmp osstart
s6:
cmp word [mouseX],459
jle s7
cmp word [mouseX],510
jg s7
cmp word [mouseY],99
jle s7
cmp word [mouseY],150
jg s7
mov byte [otherprog],1
call sys_singleLineEntry
mov esi,titleString
call sys_setupScreen
call drawWidgets
mov esi,editFN
mov edi,program
call sys_loadfile
jmp otherprogramcontinue
mov byte [state],0
jmp osstart
s7:
jmp osstart
otherprog db 0

loadprogram:
mov esi,filenamestr
mov edi,filename
mov al,13
call sys_singleLineEntry
cli
mov esi,titleString
call sys_setupScreen
call drawWidgets
call sys_getoldlocation
sti
cmp byte [entrysuccess],1
je skipload
mov esi,filename
mov edi,program
call sys_loadfile
otherprogramcontinue:
mov esi,titleString
call sys_setupScreen
call drawWidgets
call sys_getoldlocation
cmp byte [loadsuccess],1
je osstart
mov dl,byte [bootdev]
call program
mov esi,titleString
call sys_setupScreen
call drawWidgets
call sys_getoldlocation
mov byte [state],0
call sys_mouseemuenable
jmp osstart
skipload:
jmp osstart

filenamestr db 'Enter file name:',0
filename times 13 db 0
fat12fn times 13 db 0
Sides dw 0
fileSize dd 0
cluster dw 0
SectorsPerTrack dw 18
program equ 50000h
disk_buffer equ 40000h
fat equ 0ac00h

sys_loadfile:
mov byte [loadsuccess],0
push edi
mov edi,fat12fn
call sys_makefnfat12
pop edi
mov ax,19
call twelvehts2
push edi
mov edi,disk_buffer
mov dl,byte [bootdev]
mov al,14
call readsectors
mov edi,disk_buffer
mov esi,fat12fn
mov bx,0
mov ax,0
findfn1:
mov ecx,11
cld
repe cmpsb
je foundfn1
inc bx
add ax,32
mov esi,fat12fn
mov edi,disk_buffer
and eax,0xffff
add edi,eax
cmp bx,224
jle findfn1
cmp bx,224
jae filenotfound
foundfn1:
mov ax,32
mul bx
mov edi,disk_buffer
and eax,0xffff
add edi,eax
push eax
mov eax,dword [edi+1ch]
mov dword [fileSize],eax
pop eax
mov ax,word [edi+1Ah]
mov word [cluster],ax
push ax
mov ax,1
call twelvehts2
mov edi,disk_buffer
mov dl,byte [bootdev]
mov al,9
call readsectors
pop ax
pop edi
;mov ebx,edi
mov ax,word [cluster]
call twelvehts
mov al,1
mov dl,byte [bootdev]
push edi
call readsectors
pop edi
;mov ebp,0
mov ax,word [cluster]
loadnextclust:
movzx ecx,ax
movzx edx,ax
shr edx,1
add ecx,edx
mov ebx,disk_buffer
add ebx,ecx
mov dx,word [ebx]
test ax,1
jnz odd1
even1:
and dx,0fffh
jmp endload
odd1:
shr dx,4
endload:
mov ax,dx
mov word [cluster],dx
call twelvehts
add edi,256
mov al,1
mov dl,byte [bootdev]
push edi
call readsectors
pop edi
mov dx,word [cluster]
mov ax,dx
cmp dx,0ff0h
jb loadnextclust
mov eax,dword [fileSize]
ret

sys_overwrite:
cli
push esi
push ebx
push eax
call sys_deletefile
cli
pop eax
pop ebx
pop esi	
call sys_writefile
mov byte [state],0
mov al,byte [ccbyte]
mov bl,0x20
call kbcmd
call kbread
donewritw2:
ret


sys_writefile:
mov dword [fileSize],eax
push ebx
push esi
mov ax,19
call twelvehts2
mov dl,byte [bootdev]
mov al,14
mov edi,disk_buffer
call readsectors
pop esi
call sys_createfile
pop ebx
mov dword [location],ebx
mov edi,freeclusts
mov ecx,1024
cleanroutine:
mov word [edi],0
add edi,2
loop cleanroutine
getclustamount:
mov ecx,dword [fileSize]
mov eax,ecx
mov edx,0
mov ebx,512
div ebx
cmp edx,0
jg addaclust
jmp createentry
addaclust:
inc eax
createentry:
mov word [clustersneeded],ax
mov ebx,dword [fileSize]
cmp ebx,0
je finishwrite
mov ax,1
call twelvehts2
mov dl,byte [bootdev]
mov al,9
mov edi,disk_buffer
pusha
call readsectors
popa
mov esi,disk_buffer+3
movzx ecx,word [clustersneeded]
mov ebx,2
mov edx,0
findcluster:
lodsw
and ax,0fffh
jz foundeven
moreodd:
inc bx
dec esi
lodsw
shr ax,4
or ax,ax
jz foundodd
moreeven:
inc bx
jmp findcluster
foundeven:
push esi
mov esi,freeclusts
add esi,edx
mov word [esi],bx
pop esi
dec ecx
cmp ecx,0
je donefind
inc dx
inc dx
jmp moreodd
foundodd:
push esi
mov esi,freeclusts
add esi,edx
mov word [esi],bx
pop esi
dec ecx
cmp ecx,0
je donefind
inc dx
inc dx
jmp moreeven
donefind:
mov ecx,0
mov word [count],1
chainloop:
movzx eax,word [count]
cmp ax,word [clustersneeded]
je lastcluster
mov edi,freeclusts
add edi,ecx
movzx ebx,word [edi]
mov ax,bx
mov edx,0
mov bx,3
mul bx
mov bx,2
div bx
mov esi,disk_buffer
add esi,eax
mov ax,word [esi]
or dx,dx
jz even2
odd2:
and ax,000fh
mov edi,freeclusts
add edi,ecx
mov bx,word [edi+2]
shl bx,4
add ax,bx
mov word [esi],ax
inc word [count]
add cx,2
jmp chainloop
even2:
and ax,0f000h
mov edi,freeclusts
add edi,ecx
mov bx,word [edi+2]
add ax,bx
mov word [esi],ax
inc word [count]
add cx,2
jmp chainloop
lastcluster:
mov edi,freeclusts
add edi,ecx
movzx ebx,word [edi]
mov eax,ebx
mov edx,0
mov bx,3
mul bx
mov bx,2
div bx
mov esi,disk_buffer
add esi,eax
movzx eax,word [esi]
or dx,dx
jz evenlast
oddlast:
and ax,000fh
add ax,0ff80h
jmp writefat
evenlast:
and ax,0f000h
add ax,0ff8h
writefat:
mov word [esi],ax
mov ax,1
call twelvehts2
mov dl,byte [bootdev]
mov esi,disk_buffer
mov al,9
call writesectors
mov ecx,0
saveloop:
mov edi,freeclusts
add edi,ecx
mov ax,word [edi]
cmp ax,0
je writerootentry
pusha
call twelvehts
mov esi,dword [location]
mov dl,byte [bootdev]
mov al,1
call writesectors
popa
add dword [location],256
inc cx
inc cx
jmp saveloop
writerootentry:
mov ax,19
call twelvehts2
mov edi,disk_buffer
mov dl,byte [bootdev]
mov al,14
call readsectors
mov edi,disk_buffer
mov esi,fat12fn
mov bx,0
mov ax,0
findfn4:
mov ecx,11
cld
repe cmpsb
je foundfn4
inc bx
add ax,32
mov esi,fat12fn
mov edi,disk_buffer
and eax,0xffff
add edi,eax
cmp bx,224
jle findfn4
push edi
foundfn4:
mov ax,32
mul bx
mov edi,disk_buffer
and eax,0xffff
add edi,eax
mov ax,word [freeclusts]
mov word [edi+26],ax
mov dword ecx,[fileSize]
mov dword [edi+28],ecx
mov ax,19
call twelvehts2
mov dl,byte [bootdev]
mov esi,disk_buffer
mov al,14
call writesectors
finishwrite:
sti
ret
location dd 0
freeclusts times 1024 dw 0
clustersneeded dd 0
count dw 0

sys_createfile:
mov edi,fat12fn
call sys_makefnfat12
mov edi,disk_buffer
mov ecx,224
findemptyrootentry:
mov byte al,[edi]
cmp al,0
je foundempty
cmp al,0e5h
je foundempty
add edi,32
loop findemptyrootentry
foundempty:
mov esi,fat12fn
mov ecx,11
cld
repe movsb
sub edi,11
mov byte [edi+11],0
mov byte [edi+12],0
mov byte [edi+13],0
mov byte [edi+14],0c6h
mov byte [edi+15],07eh
mov byte [edi+16],0
mov byte [edi+17],0
mov byte [edi+18],0
mov byte [edi+19],0
mov byte [edi+20],0
mov byte [edi+21],0
mov byte [edi+22],0c6h
mov byte [edi+23],07eh
mov byte [edi+24],0
mov byte [edi+25],0
mov byte [edi+26],0
mov byte [edi+27],0
mov byte [edi+28],0
mov byte [edi+29],0
mov byte [edi+30],0
mov byte [edi+31],0
mov ax,19
call twelvehts2
mov dl,byte [bootdev]
mov al,14
mov esi,disk_buffer
call writesectors
ret

sys_deletefile:
mov byte [loadsuccess],0
mov edi,fat12fn
call sys_makefnfat12
mov ax,19
call twelvehts2
mov edi,disk_buffer
mov dl,byte [bootdev]
mov al,14
call readsectors
mov edi,disk_buffer
mov esi,fat12fn
mov bx,0
mov ax,0
findfn2:
mov ecx,11
cld
repe cmpsb
je foundfn2
inc bx
add ax,32
mov esi,fat12fn
mov edi,disk_buffer
and eax,0xffff
add edi,eax
cmp bx,224
jle findfn2
push edi
cmp bx,224
jae filenotfound
foundfn2:
mov ax,32
mul bx
mov edi,disk_buffer
and eax,0xffff
add edi,eax
mov byte [edi],229
mov ax,19
call twelvehts2
push edi
mov dl,byte [bootdev]
mov al,14
mov esi,disk_buffer
call writesectors
pop edi
mov ax,word [edi+26]
mov word [tmpcluster],ax
push ax
mov ax,1
call twelvehts2
mov edi,disk_buffer
mov al,9
call readsectors
pop ax
and eax,0xffff
and ebx,0xffff
moreCluster:
mov bx,3
mul bx
mov bx,2
div bx
mov esi,disk_buffer
add esi,eax
mov ax, word [esi]
test dx,dx
jz even
odd:
push ax
and ax,0x000F
mov word [esi],ax
pop ax
shr ax,4
jmp calcclustcount
even:
push ax
and ax,0xF000
mov word [esi],ax
pop ax
and ax,0x0fff
calcclustcount:
mov word [tmpcluster],ax
cmp ax,0ff8h
jae donefat
jmp moreCluster
donefat:
mov ax,1
call twelvehts2
mov esi,disk_buffer
mov dl,byte [bootdev]
mov al,9
mov esi,disk_buffer
call writesectors
ret

tmpcluster dw 0

sys_renamefile:
push esi
push edi
mov byte [loadsuccess],0
mov edi,fat12fn
call sys_makefnfat12
call sys_getrootdirectory
mov edi,disk_buffer
mov esi,fat12fn
mov bx,0
mov ax,0
findfn3:
mov ecx,11
cld
repe cmpsb
je foundfn3
inc bx
add ax,32
mov esi,fat12fn
mov edi,disk_buffer
and eax,0xffff
add edi,eax
cmp bx,224
jle findfn3
pop edi
pop esi
push edi
cmp bx,224
jae filenotfound
foundfn3:
mov ax,32
mul bx
mov edi,disk_buffer
and eax,0xffff
add edi,eax
mov eax,edi
pop edi
pop esi
mov esi,edi
pusha
mov edi,fat12fn2
call sys_makefnfat12
popa
mov edi,eax
mov esi,fat12fn2
mov ecx,12
repe movsb
mov ax,19
call twelvehts2
mov esi,disk_buffer
mov al,14
call writesectors
ret

fat12fn2 times 13 db 0

filenotfound:
cmp byte [autoornot],1
je donefnf
mov ax,150
mov bx,200
mov cx,500
mov dx,250
call sys_drawbox
mov byte [buttonornot],1
mov ax,290
mov bx,227
mov cx,338
mov dx,241
mov word [Color],0xffff
call sys_drawbox
mov byte [buttonornot],0
mov word [X],200
mov word [Y],210
mov esi,fnfspr
call sys_dispsprite
mov word [X],306
mov word [Y],229
mov esi,ok
call sys_printString
mov word [X],247
mov word [Y],210
mov esi,errorfnf
call sys_printString
call sys_getoldlocation
mov dword [mouseaddress],lbuttonclick5
mov dword [keybaddress],sys_windowloop
mov dword [bgtaskaddress],sys_nobgtasks
jmp sys_windowloop
ok db 'OK',0
errorfnf db 'Error: File not found!',0

lbuttonclick5:
cmp word [mouseX],289
jle s51
cmp word [mouseX],337
jg s51
cmp word [mouseY],226
jle s51
cmp word [mouseY],241
jg s51
donefnf:
pop edi
mov byte [loadsuccess],1
mov byte [autoornot],0
ret
s51:
jmp windowloop

readsectors:
cli
mov word [cxreg],cx
mov word [dxreg],dx
mov dword [edireg],edi
mov dword [ebpreg],ebp
mov dword [espreg],esp
mov byte [alreg],al
call go16
use16
mov al,byte [alreg]
mov cx,word [cxreg]
mov dx,word [dxreg]
mov edi,dword [edireg]
push edi
shr edi,4
push ax
mov ax,di
mov es,ax
pop ax
pop edi
mov ah,02h
mov bx,di
int 13h
call go32
use32
mov eax,0x10
mov ds,eax
mov es,eax
mov fs,eax
mov gs,eax
mov ss,eax
mov esp,dword [espreg]
mov ebp,dword [ebpreg]
call pic32
lidt [idtptr]
sti
mov al,0xf8
out 0x21,al
mov al,byte [picslave]
out 0xa1,al
ret

writesectors:
cli
mov word [cxreg],cx
mov word [dxreg],dx
mov dword [edireg],esi
mov dword [ebpreg],ebp
mov dword [espreg],esp
mov byte [alreg],al
call go16
use16
mov al,byte [alreg]
mov cx,word [cxreg]
mov dx,word [dxreg]
mov esi,dword [edireg]
push esi
shr esi,4
push ax
mov ax,si
mov es,ax
pop ax
pop esi
mov ah,03h
mov bx,si
int 13h
call go32
use32
mov eax,0x10
mov ds,eax
mov es,eax
mov fs,eax
mov gs,eax
mov ss,eax
mov esp,dword [espreg]
mov ebp,dword [ebpreg]
call pic32
lidt [idtptr]
sti
mov al,0xf8
out 0x21,al
mov al,byte [picslave]
out 0xa1,al
ret

alreg db 0
cxreg dw 0
dxreg dw 0
edireg dd 0 
espreg dd 0
ebpreg dd 0
ccbyte db 0

go32:
use16
cli
pop bp
and ebp,0x0000ffff
mov eax,cs
shl eax,4
mov ebx,eax
lgdt [gdtloc]
mov eax,cr0
or eax,1
mov cr0,eax
add ebx,ebp
push 0x08
push ebx
mov bp,sp
jmp dword far [bp]
retf
use32

gdtloc times 6 db 0
idtloc times 6 db 0


pic32:
mov al,0x11
out 0x20,al
call picdelay
out 0xA0,al
call picdelay
mov al,0x20
out 0x21,al
call picdelay
mov al,0x28
out 0xA1,al
call picdelay
mov al,0x04
out 0x21,al
call picdelay
mov al,0x02
out 0xA1,al
call picdelay
mov al,0x01
out 0x21,al
call picdelay
out 0xA1,al
call picdelay
mov al,0xff
out 0x21,al
call picdelay
out 0xa1,al
call picdelay
ret

sys_makefnfat12:
call getStringLength
xor dh,dh
movzx edx,dx
sub esi,edx
call makeCaps
sub esi,edx
mov cx,0
mov ebx,edi
copytonewstr:
lodsb
cmp al,'.'
je extfound
stosb
inc cx
jmp copytonewstr
extfound:
cmp cx,8
je addext
addspaces:
mov byte [edi],' '
inc edi
inc cx
cmp cx,8
jl addspaces
addext:
lodsb
stosb
lodsb
stosb
lodsb
stosb
pusha
add cx,3
and ecx,0xffff
sub edi,ecx
mov esi,edi
call getStringLength
movzx edx,dl
sub esi,edx
checkifspaceneeded:
cmp edx,11
jle addspace
popa
mov al,0
stosb
ret
addspace:
add esi,edx
mov byte [esi],' '
sub esi,edx
inc edx
jmp checkifspaceneeded

twelvehts:
add ax,31
twelvehts2:
push bx
push ax
mov bx,ax
mov dx,0
div word [SectorsPerTrack]
add dl,01h
mov cl,dl
mov ax,bx
mov dx,0
div word [SectorsPerTrack]
mov dx,0
div word [Sides]
mov dh,dl
mov ch,al
pop ax
pop bx
mov dl,byte [bootdev]
ret

getStringLength:
mov dl,0
loopstrlength:
cmp byte [esi],0
jne inccounter
cmp byte [esi],0
je donestrlength
jmp loopstrlength
inccounter:
inc dl
inc esi
jmp loopstrlength
donestrlength:
ret

makeCaps:
cmp byte [esi],0
je doneCaps
cmp byte [esi],61h
jl notatoz
cmp byte [esi],7ah
jg notatoz
sub byte [esi],20h
notatoz:
inc esi
jmp makeCaps
doneCaps:
ret


distimedate:
cli
mov byte [buttonornot],1
mov ax,223
mov bx,200
mov cx,423
mov dx,300
mov word [Color],0xBDF7
call sys_drawbox
mov ax,289
mov bx,255
mov cx,359
mov dx,275
mov word [Color],0xFFFF
call sys_drawbox
mov byte [buttonornot],0
mov word [X],306
mov word [Y],260
mov word [Color],0
mov esi,cancel
call sys_printString
mov word [X],265
mov word [Y],210
mov esi,time
call sys_printString
mov word [X],265
mov word [Y],225
mov esi,date
call sys_printString
sti
mov dword [mouseaddress],lbuttonclick3
mov dword [keybaddress],sys_windowloop
mov dword [bgtaskaddress],rtchandler
jmp sys_windowloop
time db 'Time:',0
date db 'Date:',0
status db 0
bcdtest db 0
timedstruct times 8 db 0


rtchandler:
pusha
cli
mov byte [ioornot],1
mov edi,timedstruct
mov al,0
out 0x70,al
in al,0x71
stosb
mov al,0x02
out 0x70,al
in al,0x71
stosb
mov al,0x04
out 0x70,al
in al,0x71
stosb
mov al,0x06
out 0x70,al
in al,0x71
stosb
mov al,0x07
out 0x70,al
in al,0x71
stosb
mov al,0x08
out 0x70,al
in al,0x71
stosb
mov al,0x09
out 0x70,al
in al,0x71
stosb
mov al,0x32
out 0x70,al
in al,0x71
stosb
mov al,0x0b
out 0x70,al
in al,0x71
test al,4
jnz notit
mov esi,timedstruct
mov ecx,8
bcdloop:
lodsb
push cx
push ax
and al,11110000b
shr al,4
mov cl,10
mul cl
pop cx
and cl,00001111b
add al,cl
pop cx
loop bcdloop
notit:
mov byte [buttonornot],1
mov ax,300
mov bx,200
mov cx,423
mov dx,240
mov word [Color],0xBDF7
call sys_drawbox
mov byte [buttonornot],0
mov esi,timedstruct
lodsb
xor ah,ah
mov word [X],335
mov word [Y],210
mov word [Color],0
call printtimed
mov word [X],330
mov word [Y],210
mov dx,':'
call sys_printChar
lodsb
xor ah,ah
mov word [X],318
mov word [Y],210
call printtimed
lodsb
mov word [X],300
mov word [Y],210
call printtimed
mov word [X],312
mov word [Y],210
mov dx,':'
call sys_printChar
lodsb
lodsb
mov word [X],300
mov word [Y],225
call printtimed
mov word [X],312
mov word [Y],225
mov dx,'/'
call sys_printChar
lodsb
mov word [X],318
mov word [Y],225
call printtimed
mov word [X],330
mov word [Y],225
mov dx,'/'
call sys_printChar
lodsb
mov word [X],347
mov word [Y],225
call printtimed
lodsb
mov word [X],335
mov word [Y],225
call printtimed
sti
popa
ret
printtimed:
pusha
mov bl,al
and al,00001111b
mov esi,hexvalue
mov edi,finalvalue+1
movzx eax,al
add esi,eax
movsb
mov al,bl
and al,11110000b
shr al,4
mov esi,hexvalue
mov edi,finalvalue
movzx eax,al
add esi,eax
movsb
mov esi,finalvalue
call sys_printString
popa
ret

hexvalue db '0123456789ABCDEF',0
finalvalue times 2 db 0
db 0

poweroptions:
cli
mov byte [buttonornot],1
mov ax,100
mov bx,100
mov cx,540
mov dx,350
mov word [Color],0xBDF7
call sys_drawbox
mov byte [buttonornot],0
mov esi,poweroptionsstr
mov word [Color],0
mov word [X],278
mov word [Y],110
call sys_printString
mov byte [buttonornot],1
mov ax,150
mov bx,150
mov cx,250
mov dx,250
mov word [Color],0xE73C
call sys_drawbox
mov ax,390
mov bx,150
mov cx,490
mov dx,250
mov word [Color],0xE73C
call sys_drawbox
mov ax,288
mov bx,310
mov cx,358
mov dx,330
mov word [Color],0xFFFF
call sys_drawbox
mov byte [buttonornot],0
mov word [Color],0
mov word [X],172
mov word [Y],260
mov esi,shutdown
call sys_printString
mov word [X],417
mov word [Y],260
mov esi,reboot
call sys_printString
mov word [X],305
mov word [Y],315
mov esi,cancel
call sys_printString
mov word [X],191
mov word [Y],193
mov esi,sdspr
call sys_dispsprite
mov word [X],431
mov word [Y],193
mov esi,respr
call sys_dispsprite
sti
mov dword [mouseaddress],lbuttonclick2
mov dword [keybaddress],sys_windowloop
mov dword [bgtaskaddress],sys_nobgtasks
jmp sys_windowloop
poweroptionsstr db 'Power options:',0
shutdown db 'Shut Down',0
reboot db 'Restart',0
cancel db 'Cancel',0

lbuttonclick2:
cmp word [mouseX],287
jle s21
cmp word [mouseX],358
jg s21
cmp word [mouseY],309
jle s21
cmp word [mouseY],330
jg s21
cli
mov esi,titleString
call sys_setupScreen
call drawWidgets
call sys_getoldlocation
sti
jmp osstart
s21:
cmp word [mouseX],389
jle s22
cmp word [mouseX],490
jg s22
cmp word [mouseY],149
jle s22
cmp word [mouseY],250
jg s22
mov al,0xfe
out 0x64,al
jmp 0xffff:0000h
s22:
cmp word [mouseX],149
jle s23
cmp word [mouseX],250
jg s23
cmp word [mouseY],149
jle s23
cmp word [mouseY],250
jg s23
call shutdownpc
s23:
jmp windowloop

lbuttonclick3:
cmp word [mouseX],288
jle s31
cmp word [mouseX],359
jg s31
cmp word [mouseY],254
jle s31
cmp word [mouseY],275
jg s31
cli
mov esi,titleString
call sys_setupScreen
call drawWidgets
call sys_getoldlocation
sti
jmp osstart
s31:
jmp windowloop

shutdownpc:
call acpishutdown
call go16
db 0xB8, 0x00, 0x53, 0xBB, 0x00, 0x00, 0xCD, 0x15, 0xB8, 0x01, 0x53, 0xBB, 0x00, 0x00, 0xCD, 0x15, 0xB8, 0x0E, 0x53, 0xBB
db 0x00, 0x00, 0xB9, 0x02, 0x01, 0xCD, 0x15, 0xB8, 0x07, 0x53, 0xB9, 0x03, 0x00, 0xBB, 0x01, 0x00, 0xCD, 0x15, 0xF4, 0xEB, 0xFE

acpishutdown:
mov edi,0xe0000
mov esi,rsdp
mov ecx,8
findrsdp:
pusha
rep cmpsb
popa
jne couldntfindrsdp
jmp foundrsdp
doneacpi:
ret
couldntfindrsdp:
cmp edi,0xfffff
jge doneacpi
add edi,8
mov esi,rsdp
mov ecx,8
jmp findrsdp
foundrsdp:
mov eax,dword [edi+16]
mov esi,eax
mov ecx,[esi+4]
sub ecx,36
shr ecx,2
findfacp:
add esi,36
mov ebx,[esi]
mov eax,[ebx]
cmp eax,'FACP'
je foundfacp
add esi,4
dec cx
cmp cx,0
jne findfacp
jmp doneacpi
foundfacp:
mov esi,ebx
mov eax,[esi+64]
mov [oneacontrolblock],eax
mov eax,[esi+68]
mov [onebcontrolblock],eax
mov esi,[esi+40]
sub esi,10000h
mov edx,[esi+4]
mov eax,0dfh
mul edx
xchg eax,edx
mov edi,'_S5_'
mov ecx,4
s5check:
cmp edi,[esi]
je founds5
inc esi
dec edx
cmp edx,0
jne s5check
jmp doneacpi
founds5:
mov eax,esi
add esi,5
mov al,[esi]
and al,0c0h
shr al,6
add al,2
movzx eax,al
add esi,eax
a32 lodsb
cmp al,0ah
jne byteprefix1
a32 lodsb
byteprefix1:
movzx ax,al
shl ax,10
mov [sla],ax
a32 lodsb
cmp al,0ah
jna byteprefix2
a32 lodsb
byteprefix2:
movzx ax,al
shl ax,10
mov [slb],ax
cli
mov dx,[oneacontrolblock]
mov ax,[sla]
or ax,2000h
out dx,ax
mov dx,[onebcontrolblock]
mov ax,[slb]
or ax,2000h
out dx,ax
sti
ret

rsdp db 'RSD PTR '
oneacontrolblock dw 0
onebcontrolblock dw 0
sla dw 0
slb dw 0

go16:
cli
pop edx
lidt [idtloc]
mov al,0x11
out 0x20,al
call picdelay
out 0xA0,al
call picdelay
mov al,0x08
out 0x21,al
call picdelay
mov al,0x70
out 0xA1,al
call picdelay
mov al,0x04
out 0x21,al
call picdelay
mov al,0x02
out 0xA1,al
call picdelay
mov al,0x01
out 0x21,al
call picdelay
out 0xA1,al
call picdelay
mov al,0xff
out 0x21,al
call picdelay
mov al,0xff
out 0xa1,al
call picdelay
mov al,byte [picmaster]
out 0x21,al
mov al,byte [picslave]
out 0xa1,al
mov esi,pm16
mov edi,0x5021
mov eax,0
mov ecx,0
looptransfer:
lodsw
stosw
inc ecx
cmp ecx,sixteendata
jne looptransfer
push dword 0x18
push 0x5021
retf
use16
pm16:
mov ax,0x20
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
mov ss,ax
mov eax,cr0
and eax,0xfe
mov cr0,eax
jmp 3000h:rmode
rmode:
mov ax, 3000h
mov ds, ax
mov es, ax
mov ss, ax    
mov sp, 0
sti
push 3000h
push dx
retf

use32

sixteendata equ $-pm16

picmaster db 0
picslave db 0

drawWidgets:
mov word [X],230
mov word [Y],50
mov word [Color],0
mov esi,options
call sys_printString
mov ax,100
mov bx,100
mov cx,150
mov dx,150
call sys_drawbox
mov word [X],115
mov word [Y],115
mov esi,tispr
call sys_dispsprite
mov esi,timedstr
mov word [X],94
mov word [Y],160
mov word [Color],0
call sys_printString
mov ax,280
mov bx,100
mov cx,330
mov dx,150
call sys_drawbox
mov word [X],295
mov word [Y],115
mov esi,fmspr
call sys_dispsprite
mov word [X],271
mov word [Y],160
mov word [Color],0
mov esi,fmstr
call sys_printString
mov ax,460
mov bx,100
mov cx,510
mov dx,150
call sys_drawbox
mov word [X],475
mov word [Y],115
mov esi,tespr
call sys_dispsprite
mov word [X],453
mov word [Y],160
mov esi,testr
mov word [Color],0
call sys_printString
mov ax,190
mov bx,200
mov cx,240
mov dx,250
call sys_drawbox
mov word [X],205
mov word [Y],215
mov esi,progspr
call sys_dispsprite
mov word [X],181
mov word [Y],260
mov word [Color],0
mov esi,progstr
call sys_printString
mov ax,370
mov bx,200
mov cx,420
mov dx,250
call sys_drawbox
mov word [X],385
mov word [Y],215
mov esi,calcspr
call sys_dispsprite
mov word [X],367
mov word [Y],260
mov word [Color],0
mov esi,calcstr
call sys_printString
ret
options db 'Please choose an option below:',0
timedstr db 'Date & time',0
fmstr db 'File manager',0
testr db 'Text editor',0
progstr db 'Load program',0
calcstr db 'Calculator',0

sys_genrandnumber:
pusha
push eax
push ebx
mov ecx,dword [systimerms]
mov eax,1103515245
mul ecx
add eax,12345
mov edx,0
mov ecx,65535
div ecx
mov edx,0
pop ebx
mov ecx,ebx
pop ebx
sub ecx,ebx
inc ecx
div ecx
mov dword [edireg],edx
popa
mov edx,dword [edireg]
cmp edx,0
jne skipaddition
cmp eax,0
je skipaddition
add edx,eax
skipaddition:
ret

sys_dispsprite:
pusha
loopsprite:
lodsb
cmp al,0
je skipahead
cmp al,1
je printonesprite
cmp al,2
je nextline
cmp al,3
je lastline
donesprite:
popa
mov byte [lastlinebyte],0
ret
skipahead:
inc word [X]
cmp bl,1
je loopsprite
inc word [X]
jmp loopsprite
printonesprite:
mov word [Color],00h
call sys_plotpixel
inc word [X]
cmp bl,1
je loopsprite
mov word [Color],00h
call sys_plotpixel
inc word [X]
jmp loopsprite
nextline:
sub word [X],10
inc word [Y]
cmp bl,1
je loopsprite
sub word [X],10
cmp byte [spriteswitch],0
je doagain
mov byte [spriteswitch],0
jmp loopsprite
doagain:
sub esi,11
mov byte [spriteswitch],1
jmp loopsprite
lastline:
cmp bl,1
je donesprite
cmp byte [lastlinebyte],1
je donesprite
sub esi,11
sub word [X],20
inc word [Y]
mov byte [lastlinebyte],1
jmp loopsprite

spriteswitch db 0
lastlinebyte db 0

respr:
db 0,0,0,0,0,1,0,0,0,0,2
db 0,1,1,1,1,1,1,0,0,0,2
db 0,1,0,0,0,1,0,0,1,0,2
db 0,1,0,0,0,0,0,0,1,0,2
db 0,1,0,0,0,0,0,0,1,0,2
db 0,1,0,0,0,0,0,0,1,0,2
db 0,1,0,0,0,0,0,0,1,0,2
db 0,1,0,0,0,0,0,0,1,0,2
db 0,1,1,1,1,1,1,1,1,0,2
db 0,0,0,0,0,0,0,0,0,0,3

sdspr:
db 0,0,0,1,1,1,1,0,0,0,2
db 0,0,1,0,0,0,0,1,0,0,2
db 0,1,0,0,1,1,0,0,1,0,2
db 0,1,0,0,1,1,0,0,1,0,2
db 0,1,0,0,1,1,0,0,1,0,2
db 0,1,0,0,1,1,0,0,1,0,2
db 0,1,0,0,1,1,0,0,1,0,2
db 0,1,0,0,1,1,0,0,1,0,2
db 0,0,1,0,0,0,0,1,0,0,2
db 0,0,0,1,1,1,1,0,0,0,3

tispr:
db 0,1,1,1,1,1,1,1,1,0,2
db 1,0,0,0,0,0,0,0,0,1,2
db 1,0,0,0,1,0,0,0,0,1,2
db 1,0,0,0,1,0,0,0,0,1,2
db 1,0,0,0,1,0,0,0,0,1,2
db 1,0,0,0,1,1,1,1,0,1,2
db 1,0,0,0,0,0,0,0,0,1,2
db 1,0,0,0,0,0,0,0,0,1,2
db 1,0,0,0,0,0,0,0,0,1,2
db 0,1,1,1,1,1,1,1,1,0,3

fmspr:
db 1,1,1,1,0,0,0,0,0,0,2
db 1,0,0,1,0,0,0,0,0,0,2
db 1,0,0,1,1,1,1,1,1,1,2
db 1,0,0,0,0,0,0,0,0,1,2
db 1,0,0,0,1,1,1,1,1,1,2
db 1,1,1,1,1,0,0,0,0,1,2
db 1,0,0,0,0,0,0,0,0,1,2
db 1,0,0,0,0,0,0,0,0,1,2
db 1,0,0,0,0,0,0,0,0,1,2
db 1,1,1,1,1,1,1,1,1,1,3

tespr:
db 1,1,1,1,1,1,1,1,1,1,2
db 1,0,0,0,0,0,0,0,0,1,2
db 1,0,1,1,1,1,1,1,0,1,2
db 1,0,0,0,0,0,0,0,0,1,2
db 1,0,1,1,1,1,1,1,0,1,2
db 1,0,0,0,0,0,0,0,0,1,2
db 1,0,0,0,0,0,1,1,1,1,2
db 1,0,0,0,0,0,1,0,0,1,2
db 1,0,0,0,0,0,1,0,1,0,2
db 1,1,1,1,1,1,1,1,0,0,3

progspr:
db 1,1,1,1,1,1,1,1,1,1,2
db 1,0,0,0,0,0,0,0,0,1,2
db 1,1,1,1,1,1,1,1,1,1,2
db 1,0,0,0,0,0,0,0,0,1,2
db 1,0,0,0,0,0,1,0,0,1,2
db 1,0,0,0,0,0,1,0,0,1,2
db 1,0,0,0,1,1,1,1,1,1,2
db 1,0,0,0,0,0,1,0,0,1,2
db 1,0,0,0,0,0,1,0,0,1,2
db 1,1,1,1,1,1,1,1,1,1,3

calcspr:
db 1,1,1,1,1,1,1,1,1,1,2
db 1,0,0,0,0,0,0,0,0,1,2
db 1,1,1,1,1,1,1,1,1,1,2
db 1,0,0,0,0,0,0,0,0,1,2
db 1,0,1,1,0,0,1,1,0,1,2
db 1,0,0,0,0,0,0,0,0,1,2
db 1,0,1,1,0,0,1,1,0,1,2
db 1,0,0,0,0,0,0,0,0,1,2
db 1,0,0,0,0,0,0,0,0,1,2
db 1,1,1,1,1,1,1,1,1,1,3

fnfspr:
db 0,0,0,0,0,0,0,0,0,0,2
db 0,0,0,0,1,1,0,0,0,0,2
db 0,0,0,1,0,0,1,0,0,0,2
db 0,0,0,1,1,1,1,0,0,0,2
db 0,0,1,0,1,1,0,1,0,0,2
db 0,0,1,0,1,1,0,1,0,0,2
db 0,1,0,0,0,0,0,0,1,0,2
db 0,1,0,0,1,1,0,0,1,0,2
db 1,0,0,0,0,0,0,0,0,1,2
db 1,1,1,1,1,1,1,1,1,1,3