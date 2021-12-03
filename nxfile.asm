;Doors NX File Manager Made by David Badiei
use32
org 50000h
%include 'nxapi.inc'

mov esi,titleString
call sys_setupScreen

call drawfirstscreen

call sys_getoldlocation

mainLoop:
mov dword [mouseaddress],lbuttonclick
mov dword [keybaddress],sys_windowloop
mov dword [bgtaskaddress],sys_nobgtasks
jmp sys_windowloop

doneprog:
ret

titleString db 'Doors NX File Manager',0
optionString db 'Please choose an option below:',0
fileSize dw 0

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
cmp word [mouseX],99
jle s2
cmp word [mouseX],150
jg s2
cmp word [mouseY],149
jle s2
cmp word [mouseY],200
jg s2
jmp listsub
s2:
cmp word [mouseX],199
jle s3
cmp word [mouseX],250
jg s3
cmp word [mouseY],149
jle s3
cmp word [mouseY],200
jg s3
jmp delsub
s3:
cmp word [mouseX],299
jle s4
cmp word [mouseX],350
jg s4
cmp word [mouseY],149
jle s4
cmp word [mouseY],200
jg s4
jmp rensub
s4:
cmp word [mouseX],399
jle s5
cmp word [mouseX],450
jg s5
cmp word [mouseY],149
jle s5
cmp word [mouseY],200
jg s5
jmp viewsub
s5:
jmp mainLoop

viewsub:
cmp byte [keyormouse],1
je skipresetview
mov esi,titleString
call sys_setupScreen
call drawfirstscreen
skipresetview:
mov esi,filenamestr
mov edi,filename
mov al,13
call sys_singleLineEntry
cmp byte [entrysuccess],1
je skipload
mov esi,titleString
call sys_setupScreen
call sys_getoldlocation
mov esi,filename
mov edi,60000h
call sys_loadfile
cmp byte [loadsuccess],1
je skipload
mov word [fileSize],ax
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
mov byte [buttonornot],0
mov esi,dword [viewerpos]
mov word [Color],0
mov word [X],1
mov word [Y],15
call sys_printString
viewloop:
call sys_mouseemudisable
mov dword [mouseaddress],lbuttonclick4
mov dword [keybaddress],viewercontrols
mov dword [bgtaskaddress],sys_nobgtasks
jmp sys_windowloop

viewerpos dd 60000h

viewercontrols:
cmp byte [keydata],1
je goup
cmp byte [keydata],2
je godown
cmp byte [keydata],6
je doneview
jmp viewloop
goup:
mov byte [downornot],0
mov esi,dword [viewerpos]
cmp esi,60000h
je viewloop
mov word [Color],0xffff
mov word [X],1
mov word [Y],15
call sys_printString
mov esi,dword [viewerpos]
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
jmp viewloop
godown:
mov esi,dword [viewerpos]
mov word [Color],0xffff
mov word [X],1
mov word [Y],15
call sys_printString
cmp byte [esi],0
je endofdown
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
jmp viewloop
endofdown:
cmp byte [downornot],1
je donedownloop
mov byte [downornot],1
jmp continuedown
downornot db 0

lbuttonclick4:
cmp word [mouseX],619
jle s41
cmp word [mouseX],636
jg s41
cmp word [mouseY],1
jle s41
cmp word [mouseY],13
jg s41
doneview:
mov esi,titleString
call sys_setupScreen
call drawfirstscreen
call sys_getoldlocation
mov byte [state],0
mov dword [viewerpos],60000h
call sys_mouseemuenable
jmp mainLoop
s41:
cmp word [mouseX],602
jle s42
cmp word [mouseX],618
jg s42
cmp word [mouseY],1
jle s42
cmp word [mouseY],13
jg s42
jmp godown
s42:
cmp word [mouseX],584
jle s43
cmp word [mouseX],600
jg s43
cmp word [mouseY],1
jle s43
cmp word [mouseY],13
jg s43
jmp goup
s43:
jmp viewloop


listsub:
mov esi,titleString
call sys_setupScreen
call sys_getoldlocation
call sys_getrootdirectory
mov word [X],1
mov word [Y],20
mov word [Color],0
mov esi,disk_buffer
mov cx,0
readroot:
lodsb
cmp al,229
je skipfn
cmp al,0fh
je skipfn
cmp cx,8
je adddot
cmp byte [yesorno],0
jne skipaheaddir
add si,10 ;KEEP THIS!!!
lodsb
cmp al,0fh
je skipsvi
cmp al,18h
je skipsvi
cmp al,16h
je skipsvi
sub si,0ch
lodsb
skipaheaddir:
cmp al,0
je exitdir
drawlist:
mov dl,al
xor dh,dh
call sys_printChar
inc cx
cmp cx,11
je donereadfn
mov byte [yesorno],1
jmp readroot
exitdir:
listloop:
mov dword [mouseaddress],lbuttonclick2
mov dword [keybaddress],sys_windowloop
mov dword [bgtaskaddress],sys_nobgtasks
jmp sys_windowloop
skipsvi:
add si,14h
mov byte [yesorno],0
jmp readroot
skipfn:
add si,31
jmp readroot
adddot:
mov dl,'.'
xor dh,dh
call sys_printChar
jmp drawlist
donereadfn:
add si,21
push ax
mov ax,0e20h
mov dl,' '
xor dh,dh
call sys_printChar
call sys_printChar
call sys_printChar
pop ax
mov cx,0
mov byte [yesorno],0
inc byte [filelisted]
inc byte [totalfilelisted]
cmp byte [filelisted],7
je nextlistline
jmp readroot
nextlistline:
mov word [X],1
add word [Y],8
mov byte [filelisted],0
jmp readroot
filelisted db 0
totalfilelisted db 0
yesorno db 0

delsub:
cmp byte [keyormouse],1
je skipresetview2
mov esi,titleString
call sys_setupScreen
call drawfirstscreen
skipresetview2:
mov esi,filenamestr
mov edi,filename
mov al,13
call sys_singleLineEntry
cmp byte [entrysuccess],1
je skipload
mov esi,titleString
call sys_setupScreen
call drawfirstscreen
call sys_getoldlocation
mov esi,filename
call sys_deletefile
skipload:
mov esi,titleString
call sys_setupScreen
call drawfirstscreen
call sys_getoldlocation
jmp mainLoop
filenamestr db 'Enter file name:',0
filename times 13 db 0

rensub:
cmp byte [keyormouse],1
je skipresetview3
mov esi,titleString
call sys_setupScreen
call drawfirstscreen
skipresetview3:
mov esi,origPrompt
mov edi,filename
mov al,13
call sys_singleLineEntry
cmp byte [entrysuccess],1
je skipload
mov byte [state],9
call sys_getoldlocation
mov esi,newPrompt
mov edi,filename2
mov al,13
call sys_singleLineEntry
cmp byte [entrysuccess],1
je skipload
mov esi,filename
mov edi,filename2
call sys_renamefile
mov esi,titleString
call sys_setupScreen
call drawfirstscreen
call sys_getoldlocation
jmp mainLoop
origPrompt db 'Enter old file name:',0
newPrompt db 'Enter new file name:',0
filename2 times 13 db 0

lbuttonclick2:
cmp word [mouseX],619
jle s21
cmp word [mouseX],636
jg s21
cmp word [mouseY],1
jle s21
cmp word [mouseY],13
jg s21
mov byte [state],0
mov esi,titleString
call sys_setupScreen
call sys_getoldlocation
call drawfirstscreen
call sys_getoldlocation
mov byte [state],0
mov byte [filelisted],0
jmp mainLoop
s21:
jmp listloop

drawfirstscreen:
mov word [X],213
mov word [Y],100
mov word [Color],0
mov esi,optionString
call sys_printString
mov ax,100
mov bx,150
mov cx,150
mov dx,200
call sys_drawbox
mov word [X],115
mov word [Y],165
mov esi,listspr
call sys_dispsprite
mov word [X],96
mov word [Y],210
mov esi,liststr
call sys_printString
mov ax,200
mov bx,150
mov cx,250
mov dx,200
call sys_drawbox
mov word [X],215
mov word [Y],165
mov esi,delspr
call sys_dispsprite
mov word [X],207
mov word [Y],210
mov esi,delstr
call sys_printString
mov ax,300
mov bx,150
mov cx,350
mov dx,200
call sys_drawbox
mov word [X],315
mov word [Y],165
mov esi,renspr
call sys_dispsprite
mov word [X],307
mov word [Y],210
mov esi,renstr
call sys_printString
mov ax,400
mov bx,150
mov cx,450
mov dx,200
call sys_drawbox
mov word [X],415
mov word [Y],170
mov esi,vwrspr
call sys_dispsprite
mov word [X],407
mov word [Y],210
mov esi,vwrstr
call sys_printString
ret
liststr db 'List files',0
delstr db 'Delete',0
renstr db 'Rename',0
vwrstr db 'Viewer',0

listspr:
db 0,1,1,1,1,1,1,1,0,0,2
db 0,1,0,0,0,0,1,0,1,0,2
db 0,1,0,0,0,0,1,0,0,1,2
db 0,1,0,0,0,0,1,1,1,1,2
db 0,1,0,0,0,0,0,0,0,1,2
db 0,1,0,0,0,0,0,0,0,1,2
db 0,1,0,0,0,0,0,0,0,1,2
db 0,1,0,0,0,0,0,0,0,1,2
db 0,1,0,0,0,0,0,0,0,1,2
db 0,1,1,1,1,1,1,1,1,1,3

delspr:
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

renspr:
db 1,1,1,1,0,1,1,1,1,0,2
db 1,0,0,1,0,1,0,0,1,0,2
db 1,1,1,1,0,1,1,1,0,0,2
db 1,0,0,1,0,1,0,0,1,0,2
db 1,0,0,1,0,1,1,1,1,0,2
db 0,1,1,1,1,0,1,1,1,1,2
db 0,1,0,0,1,0,1,0,0,0,2
db 0,1,1,1,1,0,1,0,0,0,2
db 0,1,0,0,1,0,1,0,0,0,2
db 0,1,0,0,1,0,1,1,1,1,3

vwrspr:
db 1,1,0,0,0,0,0,0,1,1,2
db 1,1,0,0,0,0,0,0,1,1,2
db 1,1,1,1,0,0,1,1,1,1,2
db 1,0,0,1,1,1,1,0,0,1,2
db 1,0,0,1,1,1,1,0,0,1,2
db 1,1,1,1,0,0,1,1,1,1,2
db 0,0,0,0,0,0,0,0,0,0,2
db 0,0,0,0,0,0,0,0,0,0,2
db 0,0,0,0,0,0,0,0,0,0,2
db 0,0,0,0,0,0,0,0,0,0,3

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