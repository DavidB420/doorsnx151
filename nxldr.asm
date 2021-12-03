;Doors NX loader Made by David Badiei
org 0000h

;Set up real mode segments
mov ax, 2000h
mov ds, ax
mov es, ax
mov ss, ax    
mov sp, 0

;Get drive number from bootsector
mov byte [bootdev],dl

;check disk params
cmp dl,0
je skipcheckdiskparams
mov byte [bootdev],dl
push es
mov ah,8
int 13h
pop es
and cx,3fh
mov word [SectorsPerTrack],cx
mov dl,dh
xor dh,dh
add dx,1
mov word [Sides],dx

skipcheckdiskparams:

;Get PIC values for kernel
call getpicvalues

;Switch to VGA 320x200x256 for prompt
mov ax,0013h
int 10h

;Load prompt image into memory
mov si,promptfn
mov di,fat12fn
mov cx,12
repe movsb
call loadfile

;Print prompt image
call drawprompt

;Give user option between using keyboard or mouse
mov ah,0
int 16h

cmp al,'0'
jne mouseSelect
mov byte [keyormouse],0
jmp doneselection
mouseSelect:
mov byte [keyormouse],1
doneselection:

;Load kernel into memory
mov si,kernelfn
mov di,fat12fn
mov cx,12
repe movsb
call loadfile

;Switch to VESA for kernel
mov di,vesadata
mov cx,0111h
mov ax,4f01h
int 10h

mov eax,dword [vesadata+40]

mov dword [lfbAddress],eax

mov ax,4f02h
mov cx,[vesadata+10h]
mov bx,4111h
int 10h

;Enable A20 gate
in al,0x92
or al,2
out 0x92,al

;Load GDT
cli
mov eax,cs
shl eax,4
mov ebx,eax
add [gdtdescriptor+2],eax
lgdt [gdtdescriptor]

;Give it the key/mouse choice
mov dl,byte [keyormouse]

;Find address of place we are gonna jump to once in protected mode
add ebx,code32bit
push dword 0x08
push ebx
mov bp,sp


;Enter protected mode
mov eax,cr0
or eax,1
mov cr0,eax

jmp dword far [bp]

jmp $

vesadata times 256 db 0
lfbAddress dd 0
disk_buffer equ 1000h
file equ 0
SectorsPerTrack dw 18
Sides dw 2
fileSize dw 0
keyormouse db 0
fat equ 4000h
cluster dw 0
bootdev db 0
fat12fn times 14 db 0
promptfn db 'PRIMG   PCX',0
kernelfn db 'NXOSKRNLSYS',0
picmaster db 0
picslave db 0

align 4
gdtdescriptor:
dw gdtend-gdt-1
dd gdt
gdt:
dq 0
code:
dw 0xffff
dw 0
db 0
db 10011010b
db 11001111b
db 0
data:
dw 0xffff
dw 0
db 0
db 10010010b
db 11001111b
db 0
sixteenbitshit:
dw 0xffff
dw 0
db 0
db 10011010b
db 10001111b
db 0
sixteenbitshit2:
dw 0xffff
dw 0
db 0
db 10010010b
db 10001111b
db 0
gdtend:

getpicvalues:
push ax
in al,0x21
mov byte [picmaster],al
in al,0xa1
mov byte [picslave],al
pop ax
ret

drawprompt:
push es
push ds
mov ax,0A000h
mov es,ax
mov ax,3000h
mov ds,ax
mov si,80h
mov di,0
decode:
mov cx,1
lodsb
cmp al,192
jb single
and al,63
mov cl,al
lodsb
single:
rep stosb
cmp di,64001
jb decode
mov dx,3c8h
mov al,0
out dx,al
inc dx
mov cx,768
setpal:
lodsb
shr al,2
out dx,al
loop setpal
pop ds
pop es
ret

loadfile:
mov ax,19
call twelvehts2
mov dl,byte [bootdev]
mov ah,2
mov al,14
mov si,disk_buffer
mov bx,si
int 13h
mov di,disk_buffer
mov si,fat12fn
mov bx,0
mov ax,0
findfn1:
mov cx,11
cld
repe cmpsb
je foundfn1
inc bx
add ax,32
mov si,fat12fn
mov di,disk_buffer
add di,ax
cmp bx,224
jle findfn1
cmp bx,224
jae filenotfound
foundfn1:
mov ax,32
mul bx
mov di,disk_buffer
add di,ax
push ax
mov ax,word [di+1ch]
mov word [fileSize],ax
pop ax
mov ax,word [di+1Ah]
mov word [cluster],ax
push ax
mov ax,1
call twelvehts2
mov dl,byte [bootdev]
mov ah,2
mov al,9
mov si,fat
mov bx,si
int 13h
pop ax
push ax
mov di,file
mov bx,di
call twelvehts
push es
mov ax,3000h
mov es,ax
mov ax,0201h
int 13h
pop es
mov bp,0
pop ax
loadnextclust:
mov cx,ax
mov dx,ax
shr dx,1
add cx,dx
mov bx,fat
add bx,cx
mov dx,word [bx]
test ax,1
jnz odd1
even1:
and dx,0fffh
jmp end
odd1:
shr dx,4
end:
mov ax,dx
mov word [cluster],dx
call twelvehts
add bp,512
mov si,fat
add si,bp
mov bx,si
sub bx,4000h
push es
mov ax,3000h
mov es,ax
mov ax,0201h
int 13h
pop es
mov dx,word [cluster]
mov ax,dx
cmp dx,0ff0h
jb loadnextclust
ret

filenotfound:
jmp 0xffff:0000h

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

align 4
code32bit:
use32
section protectedmode vstart=0x5000, valign=4
start32:
cld
mov eax,0x10
mov ds,eax
mov es,eax
mov fs,eax
mov gs,eax
mov ss,eax
mov esp,0x1000
mov edi,start32
mov esi,ebx
mov ecx,PMSIZE_LONG
rep movsd
jmp 0x08:continue32
continue32:
mov ebx,20000h
add ebx,lfbAddress
mov eax,dword [ebx]
jmp 030000h
jmp $



PMSIZE_LONG equ ($-$$+3)>>2