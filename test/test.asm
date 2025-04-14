.MODEL SMALL
stack segment
    db 100h dup(?) 
stack ends

data segment
    ; Начальный символ, введенный пользователем
data ends

code segment
    assume cs:code, ds:data, ss:stack  ; Указываем сегменты

MAIN PROC
    call GETCH   
    call GETCH  
    call GETCH  
    call GETCH  
    call GETCH  
; Завершение программы
    mov ax, 4C00h ; код завершения программы
    int 21h 
MAIN endp

GETCH proc near
        mov AH, 01h
        int 21h
        ret
GETCH ENDP

code ends
END MAIN