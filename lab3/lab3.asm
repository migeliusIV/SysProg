data segment 
    fio db 'Sorokin Mikhail', '$' 
data ends 
 
stack segment stack 
    db 100h dup(?) 
stack ends 
 
code segment 
assume cs:code, ds:data, ss:stack 
 
start: 
    mov ax, data 
    mov ds, ax 
 
    call CLRSCR 
 
    mov dl, 0A0h     
    call PUTCH 
    call CLRF 
 
    mov dl, 0A1h     
    call PUTCH 
    call CLRF 
 
    mov dl, 0A2h     
    call PUTCH 
    call CLRF 
 
    lea dx, fio 
    mov ah, 9h 
    int 21h 
    mov ax, 4C00h 
    int 21h 
 
 
GETCH proc near 
    mov ah, 1h 
    int 21h 
    ret 
GETCH endp 
 
 
PUTCH proc near 
    mov ah, 2h 
    int 21h 
    ret 
PUTCH endp 
 
CLRF proc near 
    mov dl, 13 
    call PUTCH 
    mov dl, 10 
    call PUTCH 
    ret 
CLRF endp 
 
 
CLRSCR proc near 
    mov ax, 0600h 
    mov bh, 07h 
    mov cx, 0000h 
    mov dx, 184Fh 
    int 10h 
    ret 
CLRSCR endp 
 
code ends 
end start