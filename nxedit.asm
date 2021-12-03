;Doors NX Text editor Made by David Badiei
use32
org 50000h
%include 'nxapi.inc'

mov esi,titleString
call sys_setupScreen
mov esi,filenamestr
mov edi,filename
mov al,13
call sys_singleLineEntry
cmp byte [entrysuccess],1
je doneprog
mov esi,titleString
call sys_setupScreen
mov word [X],125
mov word [Y],3
mov word [Color],0xffff
mov dh,0
mov dl,'-'
call sys_printChar
call drawtitlebuttons
mov edi,0x5ffff
mov al,0x0a
stosb
call sys_getrootdirectory
mov esi,filename
mov edi,fat12fn
call sys_makefnfat12
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
jae newfile
foundfn1:
mov ax,32
mul bx
mov edi,disk_buffer
and eax,0xffff
add edi,eax
continueloadfile:
mov esi,filename
mov edi,60000h
call sys_loadfile
cmp byte [loadsuccess],1
je doneprog
mov word [X],135
mov word [Y],3
mov word [Color],0xffff
mov esi,filename
call sys_printString
mov esi,dword [viewerpos]
mov word [X],1
mov word [Y],15
mov word [Color],0
call sys_printString
mov dword [lastbyte],esi
mov esi,60000h
filesizeloop:
lodsb
cmp al,0
jne filesizeloop
sub esi,60002h
mov dword [fileSize],esi
mov ax,0
mov bx,0
call sys_term_movecursor
call sys_mouseemudisable
mainloop:
mov dword [mouseaddress],lbuttonclick
mov dword [keybaddress],keyinput
mov dword [bgtaskaddress],sys_nobgtasks
jmp sys_windowloop

doneprog:
ret

titleString db 'Doors NX Text Editor',0
filenamestr db 'Enter file name:',0
filename times 13 db 0
fat12fn times 13 db 0
viewerpos dd 60000h
lastbyte dd 0
curByte dd 0
curX db 0
curY db 0
eofbyte db 0
fileSize dd 0

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
cmp word [mouseX],602
jle s2
cmp word [mouseX],618
jg s2
cmp word [mouseY],1
jle s2
cmp word [mouseY],13
jg s2
jmp downkey
s2:
cmp word [mouseX],584
jle s3
cmp word [mouseX],600
jg s3
cmp word [mouseY],1
jle s3
cmp word [mouseY],13
jg s3
jmp upkey
s3:
cmp word [mouseX],566
jle s4
cmp word [mouseX],582
jg s4
cmp word [mouseY],1
jle s4
cmp word [mouseY],13
jg s4
mov byte [keydata],6
jmp keyinput
s4:
jmp sys_windowloop

newfile:
mov edi,60000h
mov ecx,0xffff
xor al,al
repe stosb
mov dword [fileSize],1
mov ebx,60000h
mov byte [ebx],0ah
inc ebx
mov dword [lastbyte],ebx
mov ecx,0
mov dword [curByte],0
mov esi,filename
mov ebx,60000h
call sys_writefile
jmp continueloadfile

drawtitlebuttons:
mov byte [buttonornot],1
mov ax,603
mov bx,2
mov cx,618
mov dx,11
mov word [Color],0x079F
call sys_drawbox
mov ax,585
mov bx,2
mov cx,600
mov dx,11
call sys_drawbox
mov ax,567
mov bx,2
mov cx,582
mov dx,11
mov word [Color],0x0FE0
call sys_drawbox
mov word [X],606
mov word [Y],3
mov esi,upspr
mov bl,1
call sys_dispsprite
mov word [X],588
mov word [Y],3
mov esi,downspr
mov bl,1
call sys_dispsprite
mov word [X],570
mov word [Y],3
mov esi,savespr
mov bl,1
call sys_dispsprite
mov byte [buttonornot],0
ret

savefile:
cli
mov esi,filename
mov ebx,60000h
mov eax,dword [fileSize]
call sys_overwrite
sti
mov byte [state],0
jmp mainloop

keyinput:
cmp byte [keydata],1
je upkey
cmp byte [keydata],2
je downkey
cmp byte [keydata],3
je leftkey
cmp byte [keydata],4
je rightkey
cmp byte [keydata],6
je savefile
cmp byte [keydata],7
je doneprog
jmp keypress
downkey:
mov esi,60000h
add esi,dword [curByte]
downbyteloop:
lodsb
cmp al,0
je sys_windowloop
cmp al,0x0a
je donedownbyteloop
jmp downbyteloop
donedownbyteloop:
mov dword [curByte],esi
sub dword [curByte],60000h
cmp byte [curY],57
je godown
continuedown2:
mov ah,byte [curX]
mov bh,byte [curY]
inc byte [curY]
mov al,0
mov byte [curX],al
mov bl,byte [curY]
call sys_term_movecursor
mov byte [state],0
jmp sys_windowloop
upkey:
mov esi,60000h
mov ecx,dword [curByte]
add esi,ecx
cmp esi,60000h
je startoffile
mov al,byte [esi]
cmp al,0ah
je startonnewline
jmp goback2
startonnewline:
cmp esi,60001h
je startoffile
mov al,byte [esi-1]
cmp al,0ah
je anothernewlinebefore
dec esi
dec ecx
jmp goback2
anothernewlinebefore:
mov al,byte [esi-2]
cmp al,0ah
je gotostartline
dec dword [curByte]
jmp displaymove
gotostartline:
dec ecx
dec esi
cmp esi,60000h
je startoffile
dec ecx
dec esi
cmp esi,60000h
je startoffile
jmp loop2
goback2:
cmp esi,60000h
je startoffile
mov al,byte [esi]
cmp al,0ah
je foundnewline
dec ecx
dec esi
jmp goback2
foundnewline:
dec esi
dec ecx
loop2:
cmp esi,60000h
je startoffile
mov al,byte [esi]
cmp al,0ah
je founddone
dec ecx
dec esi
jmp loop2
founddone:
inc ecx
mov dword [curByte],ecx
jmp displaymove
startoffile:
mov dword [curByte],0
mov byte [curX],0
displaymove:
cmp byte [curY],0
je goup
mov ah,byte [curX]
mov bh,byte [curY]
dec byte [curY]
mov al,0
mov byte [curX],al
mov bl,byte [curY]
call sys_term_movecursor
mov byte [state],0
jmp sys_windowloop
rightkey:
cmp byte [curX],105
je sys_windowloop
mov esi,60000h
add esi,dword [curByte]
cmp esi,dword [lastbyte]
je sys_windowloop
mov al,byte [esi]
cmp al,0ah
je sys_windowloop
inc dword [curByte]
mov ah,byte [curX]
mov bh,byte [curY]
inc byte [curX]
mov al,byte [curX]
mov bl,bh
call sys_term_movecursor
jmp sys_windowloop
leftkey:
cmp byte [curX],0
je sys_windowloop
mov esi,60000h
add esi,dword [curByte]
dec esi
dec dword [curByte]
mov ah,byte [curX]
mov bh,byte [curY]
dec byte [curX]
mov al,byte [curX]
mov bl,bh
call sys_term_movecursor
jmp sys_windowloop
goup:
mov byte [eofbyte],0
mov esi,dword [viewerpos]
cmp esi,60000h
je sys_windowloop
mov word [Color],0xffff
mov word [X],1
mov word [Y],15
call sys_printString
mov esi,dword [viewerpos]
mov bl,0
std
uploop:
lodsb
cmp esi,5ffffh
je doneuploop
dec dword [viewerpos]
cmp al,0x0a
je doneuploop
jmp uploop
doneuploop:
cld
mov esi,dword [viewerpos]
mov word [Color],0
mov word [X],1
mov word [Y],15
call sys_printString
mov byte [state],0
jmp sys_windowloop
hitnewline:
inc bl
cmp bl,1
je uploop
cmp bl,2
je doneuploop
godown:
mov esi,dword [viewerpos]
mov word [Color],0xffff
mov word [X],1
mov word [Y],15
call sys_printString
continuedown:
mov esi,dword [viewerpos]
downloop:
lodsb
inc dword [viewerpos]
cmp al,0x0a
je donedownloop
jmp downloop
donedownloop:
mov esi,dword [viewerpos]
mov word [Color],0
mov word [X],1
mov word [Y],15
call sys_printString
mov byte [state],0
jmp sys_windowloop
keypress:
cmp byte [keydata],0
je sys_windowloop
cmp byte [keydata],0x08
je backspace
cmp byte [keydata],0dh
je enterkey
cmp byte [keydata],5
je deletekey
cmp byte [curX],106
je sys_windowloop
mov al,byte [keydata]
push ax
mov esi,dword [viewerpos]
mov word [Color],0xffff
mov word [X],1
mov word [Y],15
call sys_printString
mov esi,60000h
add esi,dword [curByte]
mov ebx,fileSize
mov ecx,lastbyte
call sys_charforward
pop ax
mov byte [esi],al
inc dword [curByte]
mov ah,byte [curX]
mov bh,byte [curY]
inc byte [curX]
mov al,byte [curX]
mov bl,bh
call sys_term_movecursor
mov esi,dword [viewerpos]
mov word [Color],0
mov word [X],1
mov word [Y],15
call sys_printString
jmp sys_windowloop
backspace:
cmp dword [curByte],0
je sys_windowloop
cmp byte [curX],0
je sys_windowloop
mov esi,dword [viewerpos]
mov word [Color],0xffff
mov word [X],1
mov word [Y],15
call sys_printString
mov esi,60000h
add esi,dword [curByte]
mov ebx,fileSize
mov ecx,lastbyte
call sys_charbackward
dec dword [curByte]
mov esi,dword [viewerpos]
mov word [Color],0
mov word [X],1
mov word [Y],15
call sys_printString
mov ah,byte [curX]
mov bh,byte [curY]
dec byte [curX]
mov al,byte [curX]
mov bl,bh
call sys_term_movecursor
jmp sys_windowloop
enterkey:
mov esi,dword [viewerpos]
mov word [Color],0xffff
mov word [X],1
mov word [Y],15
call sys_printString
mov esi,60000h
add esi,dword [curByte]
mov ebx,fileSize
mov ecx,lastbyte
call sys_charforward
mov byte [esi],0ah
inc dword [curByte]
mov ah,byte [curX]
mov bh,byte [curY]
mov al,0
mov byte [curX],0
mov bl,bh
call sys_term_movecursor
cmp byte [curY],57
je godown
mov ah,byte [curX]
mov bh,byte [curY]
inc byte [curY]
mov al,0
mov byte [curX],0
mov bl,byte [curY]
call sys_term_movecursor
mov esi,dword [viewerpos]
mov word [Color],0
mov word [X],1
mov word [Y],15
call sys_printString
jmp sys_windowloop
deletekey:
mov esi,60001h
add esi,dword [curByte]
cmp esi,dword [lastbyte]
je sys_windowloop
pusha
mov esi,dword [viewerpos]
mov word [Color],0xffff
mov word [X],1
mov word [Y],15
call sys_printString
popa
mov al,byte [esi]
cmp al,0ah
je atnewline1
mov ebx,fileSize
mov ecx,lastbyte
call sys_charbackward
jmp redrawdeletekey
atnewline1:
mov ebx,fileSize
mov ecx,lastbyte
call sys_charbackward
call sys_charbackward
redrawdeletekey:
mov esi,dword [viewerpos]
mov word [Color],0
mov word [X],1
mov word [Y],15
call sys_printString
jmp sys_windowloop

upspr:
db 0,0,0,0,1,0,0,0,0,0,2
db 0,0,0,0,1,0,0,0,0,0,2
db 0,0,0,0,1,0,0,0,0,0,2
db 0,0,0,0,1,0,0,0,0,0,2
db 0,0,1,1,1,1,1,0,0,0,2
db 0,0,0,1,1,1,0,0,0,0,2
db 0,0,0,0,1,0,0,0,0,0,2
db 0,0,0,0,0,0,0,0,0,0,2
db 0,0,0,0,0,0,0,0,0,0,2
db 0,0,0,0,0,0,0,0,0,0,3

downspr:
db 0,0,0,0,1,0,0,0,0,0,2
db 0,0,0,1,1,1,0,0,0,0,2
db 0,0,1,1,1,1,1,0,0,0,2
db 0,0,0,0,1,0,0,0,0,0,2
db 0,0,0,0,1,0,0,0,0,0,2
db 0,0,0,0,1,0,0,0,0,0,2
db 0,0,0,0,1,0,0,0,0,0,2
db 0,0,0,0,0,0,0,0,0,0,2
db 0,0,0,0,0,0,0,0,0,0,2
db 0,0,0,0,0,0,0,0,0,0,3

savespr:
db 0,1,1,1,1,1,1,1,0,0,2
db 0,1,0,1,1,1,1,0,1,0,2
db 0,1,0,1,1,1,1,0,1,0,2
db 0,1,0,0,0,0,0,0,1,0,2
db 0,1,0,1,1,1,1,0,1,0,2
db 0,1,0,1,0,0,1,0,1,0,2
db 0,1,1,1,1,1,1,1,1,0,2
db 0,0,0,0,0,0,0,0,0,0,2
db 0,0,0,0,0,0,0,0,0,0,2
db 0,0,0,0,0,0,0,0,0,0,3
