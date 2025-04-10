data segment 
    fio db 'Sorokin Mikhail', '$' 
    text db 'Press any button', '$'
data ends 

stack segment 
    db 100h dup(?) 
stack ends

CODE SEGMENT
    assume cs:code, ds:data, ss:stack  ; Указываем сегменты

main PROC
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
    mov ah, 9h ; команда вывода строки
    int 21h
    call CLRF

    lea dx, text
    mov ah, 9h
    int 21h

    mov ah, 07h 
    int 21h

    mov ax, 4C00h ; код завершения программы
    int 21h
main ENDP

GETCH proc near 
    mov ah, 01h 
    int 21h 
    ret 
GETCH endp 

PUTCH proc near ; вывод символа на экран
    mov ah, 2h ; указание функции - вывода 1-го символа
    int 21h ; прерывание, вызов DOS
    ret
PUTCH endp

CLRF proc near ; перевод курсора на новую строку
    mov dl, 13
    call PUTCH
    mov dl, 10
    call PUTCH
    ret
CLRF endp

CLRSCR proc near ; процедура очистки экрана
    mov ax, 0600h
    mov bh, 07h
    mov cx, 0000h
    mov dx, 184Fh
    int 10h
    ret
CLRSCR endp
CODE ENDS

END main ; указатель на точку входа в программу