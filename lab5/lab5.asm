;.MODEL LARGE, C 
; СЕГМЕНТ ДАННЫХ
DTSEG SEGMENT PARA 'DATA' 
    ; Справочные сообщения для пользователя
    msg_menu db "==Меню==", 0Dh, 0Ah, 
                db "1 - ЛР5", 0Dh, 0Ah, 
                db "2 - Доп задание", 0Dh, 0Ah, 
                db "3 - Завершить программу", 0Dh, 0Ah,'$'
    msg_menu_error db "Введен неверный символ...", 0Dh, 0Ah,'$'
    msg_apndx db "Введите значение в сантимерах = $"
    msg_apndx_res db "Значение в дюймах = $"
    MES0 DB "Максимальное кол-во символов в строке - 20", 0Dh, 0Ah, '$' 
    MES1 DB "Символ окончания ввода строки - `знак доллара`", 0Dh, 0Ah, '$' 
    MES2 DB "Максимальное кол-во строк - 10", 0Dh, 0Ah, '$' 
    MES3 DB "Символ окончания ввода строк - *", 0Dh, 0Ah, '$' 
    BUF_SYMBS DB 40 DUP(?)          ; Буфер для введенной строки
    HEX_TABLE DB '0123456789ABCDEF' ; Таблица перекодировки
    BUF_CX DW ?                     ; Буфер для счетчика цикла
    ROW_SYMBS DW 40                 ; Макс. символов в строке
    ROWS DW 10                      ; Макс. количество строк
DTSEG ENDS

STSEG SEGMENT PARA 'STACK' 
    DB 200 DUP(0) 
STSEG ENDS 


;PUBLIC _CALCULATE

CDSEG SEGMENT PARA 'CODE' 
    ASSUME DS:DTSEG, SS:STSEG, CS:CDSEG 
    EXTRN _calculate:NEAR  ; Импортируем функцию из C++
MAIN PROC 
    ; Инициализация сегмента данных в коде
    mov AX, DTSEG 
    mov DS, AX 

    ;--- Меню
    ; 1 - Запуск 5 ЛР
    ; 2 - Запуск допа
    ; 3 - Прервать программу
    ;;;;;;;;;;;;;;;;
menu:
    call CLRF
    call CLRSCR
    mov DX, OFFSET msg_menu
    call PUTMES
    call GETCHECHO
    cmp al, '1'
    je lab5
    cmp al, '2'
    je appendix
    cmp al, '3'
    db 0Fh, 84h             ; Код операции для JE near (вручную)
    dw offset END_PROG - ($ + 2)  ; 16-битное смещение
    call CLRF
    mov DX, OFFSET msg_menu_error
    call PUTMES
    call GETCH
    jmp menu

appendix:
    call _calculate  
    db 0Fh, 84h             ; Код операции для JE near (вручную)
    dw offset END_PROG - ($ + 2)  ; 16-битное смещение

lab5:
    call CLRF
    call CLRSCR
    ; Вывод справочных сообщений
    mov DX, OFFSET MES0 
    call PUTMES 
    mov DX, OFFSET MES1 
    call PUTMES 
    mov DX, OFFSET MES2 
    call PUTMES 
    mov DX, OFFSET MES3 
    call PUTMES 
    call CLRF 

    mov BX, OFFSET HEX_TABLE 
    mov CX, ROWS  ; Счетчик для цикла LOOP0
    ; ЦИКЛ ПО СТРОКАМ
    LOOP0: 
    ; Ввод строки
    mov BUF_CX, CX 
    mov CX, ROW_SYMBS  ; Счетчик для LOOP1
    mov SI, 0  ; Индекс буфера
    
    LOOP1: 
        call GETCH  ; Ввод символа
        mov dl, al
        cmp al, '$'
        je GO0
        cmp al, '*' 
        jne not_sys
        cmp si, 0
        je GO1
        
    not_sys:
        call PUTCH
        mov BUF_SYMBS[SI], AL  ; Запись в буфер
        inc SI 
        LOOP LOOP1 
    GO0: 
    ; Проверка на пустую строку
    cmp SI, 0 
    JE GO1 

    ; Вывод " = "
    call PUTSPACE 
    mov DL, '=' 
    call PUTCH 
    call PUTSPACE 

    mov CX, SI  ; Длина строки (служит длиной цикла)
    mov SI, 0 
    ; Преобразование в HEX
    LOOP2: 
        mov AL, BUF_SYMBS[SI] 
        inc SI 
        call HEX 
        call PUTSPACE 
        LOOP LOOP2 
    GO1: 
    ; Проверка на конец ввода
    cmp AL, '*' 
    JE END_PROG 
    call CLRF 
    mov CX, BUF_CX 
    LOOP LOOP0 
    
END_PROG: 
    mov AH, 4Ch 
    int 21h 
MAIN ENDP 

; Процедуры
PUTCH PROC ; процедура вывода символа
    mov AH, 02h 
    int 21h 
    ret 
PUTCH ENDP 

PUTSPACE PROC 
    mov DL, ' ' 
    mov AH, 02h 
    int 21h 
    ret 
PUTSPACE ENDP 

PUTMES PROC ; процедура вывода массива
    mov AH, 09h 
    int 21h 
    ret 
PUTMES ENDP 

CLRF PROC 
    mov DL, 0Ah 
    call PUTCH 
    mov DL, 0Dh 
    call PUTCH 
    ret 
CLRF ENDP 

CLRSCR proc near ; процедура очистки экрана
    mov ax, 0600h
    mov bh, 07h
    mov cx, 0000h
    mov dx, 184Fh
    int 10h
    ret
CLRSCR endp

GETCH PROC 
    mov AH, 07h ; вывод без эха
    int 21h 
    ret 
GETCH ENDP 

GETCHECHO PROC 
    mov AH, 01h 
    int 21h 
    ret 
GETCHECHO ENDP 

HEX PROC 
    push AX 
    mov DL, AL 
    SHR DL, 4 
    mov AL, DL 
    XLAT 
    mov DL, AL 
    call PUTCH 
    pop AX 
    mov DL, AL 
    AND DL, 0Fh 
    mov AL, DL 
    XLAT 
    mov DL, AL 
    call PUTCH 
    ret 
HEX ENDP  

OUTPUT PROC near
    pop ax
    
    ret 
OUTPUT ENDP 

CDSEG ENDS 
END MAIN