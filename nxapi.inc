;Doors NX 1.51 API table

;sys_plotpixel
;Sets a pixel on the screen
;IN: X word = X coordinate, Y word = Y coordinate,Color word = Color
sys_plotpixel equ 30005h

;sys_setupScreen
;Sets up a basic screen
;IN: ESI = title bar text
sys_setupScreen equ 3000Ah

;sys_drawbox
;Draws a box or button
;IN: buttonornot byte = Use default color or not, AX = first X coord, BX = first Y coord, CX = second X coord, DX = second Y coord, Color word = Color (if default color is not used)
sys_drawbox equ 3000Fh

;sys_printString
;Prints an ASCII string terminated by 0
;IN: ESI = string location, X word = X coordinate, Y word = Y coordinate, Color word = Color
sys_printString equ 30014h

;sys_getpixel
;Gets the color value of a certain pixel 
;IN: X word = X coordinate, Y word = Y coordinate
;OUT: AX = Color
sys_getpixel equ 30019h

;sys_dispsprite
;Displays a 10x10 sprite that can be scaled to a 20x20 sprite
;IN: ESI = sprite location, X word = X coordinate, Y word = Y coordinate
sys_dispsprite equ 3001eh

;sys_singleLineEntry
;Presents a single line entry to the user
;IN: ESI = title string, EDI = entry buffer, AL = buffer length
;OUT: entrysuccess byte = 0 if successful
sys_singleLineEntry equ 30023h

;sys_loadfile
;Load file from disk into memory
;IN: ESI = file name, EDI = memory location
;OUT: loadsuccess = 0 if successful
sys_loadfile equ 30028h

;sys_getoldlocation
;Refresh mouse pointer data
sys_getoldlocation equ 3003bh

;sys_term_setupScreen
;Sets up terminal emulator
sys_term_setupScreen equ 30041h

;sys_term_redrawbuffer
;Redraws terminal buffer
;IN: Color word = Color
sys_term_redrawbuffer equ 30046h

;sys_term_movecursor
;Moves the terminal cursor
;IN: AH = old X position, AL = new X position, BH = old Y position, BL = new Y position
sys_term_movecursor equ 3004bh

;sys_term_printChar
;Print terminal character
;IN: AL = ASCII character
sys_term_printChar equ 30050h

;sys_term_getcursor
;Gets terminal cursor location
;OUT: AL = X position, BL = Y position 
sys_term_getcursor equ 30055h

;sys_term_getkey
;Gets a key press in the terminal
;OUT: keydata byte = ASCII character
sys_term_getkey equ 3005bh

;sys_term_printString
;Prints a string with the terminal emulator
;IN: ESI = string location
sys_term_printString equ 30060h

;sys_term_getString
;Gets user input with the terminal emulator
;IN: EDI = string location, AL = string length
sys_term_getString equ 30065h

;sys_printChar
;Plots a character on the screen
;IN: DX = character, Color word = Color, X word = X coordinate, Y word = Y coordinate
sys_printChar equ 3006ah

;sys_getrootdirectory
;Gets root directory of a disk
;OUT: disk_buffer constant = root directory
sys_getrootdirectory equ 3006fh

;sys_deletefile
;Deletes a file
;IN: ESI = filename
sys_deletefile equ 30074h

;sys_renamefile
;Renames a file
;IN: ESI = original filename, EDI = new filename
sys_renamefile equ 30079h

;sys_charforward
;Shifts a block of text forward
;IN: ESI = location of where you want to shift, EBX = location of file size dword, ECX = location of last byte dword
sys_charforward equ 3007eh

;sys_charbackward
;Shifts a block of text backward
;IN: ESI = location of where you want to shift, EBX = location of file size dword, ECX = location of last byte dword
sys_charbackward equ 30083h

;sys_createfile
;Creates a blank file
;IN: ESI = filename
sys_createfile equ 30088h

;sys_writefile
;Writes a file to the disk
;IN: ESI = filename, EBX = location of file, EAX = file size
sys_writefile equ 3008dh

;sys_makefnfat12
;Converts filename to a FAT12 style filename
;IN: ESI = original filename location, EDI = new filename location
sys_makefnfat12 equ 30092h

;sys_windowloop (DONT CALL, JMP)
;Creates a loop that waits for events
;IN: mouseaddress dword =  mouse event address, keybaddress dword = keyboard event address, bgtaskaddress dword = background task(s) address
sys_windowloop equ 30097h

;sys_nobgtasks
;Placeholder for sys_windowloop if you dont have any background tasks
sys_nobgtasks equ 3009ch

;sys_mouseemuenable
;Enables mouse emulation
sys_mouseemuenable equ 300aeh

;sys_mouseemudisable
;Disables mouse emulation
sys_mouseemudisable equ 300b3h

;sys_overwrite
;Overwrite file
;IN: ESI = filename, EBX = location of file, EAX = file size
sys_overwrite equ 300b8h

;sys_genrandnumber
;Generates a random integer
;IN: EAX = minimum, EBX = maximum
;OUT: EDX = random value
sys_genrandnumber equ 300bdh

;buttonornot byte
buttonornot equ 3002dh

;entrysuccess byte
entrysuccess equ 3002eh

;loadsuccess byte
loadsuccess equ 3002fh

;ioornot byte
ioornot equ 30040h

;state byte
state equ 30030h

;keydata byte
keydata equ 3005ah

;keyormouse byte
keyormouse equ 300adh

;X word
X equ 30031h

;Y word
Y equ 30033h

;Color word
Color equ 30035h

;Mouse X word
mouseX equ 30037h

;Mouse Y word
mouseY equ 30039h

;mouseaddress dword
mouseaddress equ 300a1h

;keybaddress dword
keybaddress equ 300a5h

;bgtaskaddress dword
bgtaskaddress equ 300a9h

;Disk buffer constant
;Location where the root directory or the FAT resides
disk_buffer equ 40000h
