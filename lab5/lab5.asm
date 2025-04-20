; Пример программы ЛР5
; СЕГМЕНТ ДАННЫХ
DTSEG SEGMENT PARA 'DATA' 
    ; Справочные сообщения для пользователя
    MES0 DB "Максимальное кол-во символов в строке - 20", 0Dh, 0Ah, '$' 
    MES1 DB "Символ окончания ввода строки - `знак доллара`", 0Dh, 0Ah, '$' 
    MES2 DB "Максимальное кол-во строк - 10", 0Dh, 0Ah, '$' 
    MES3 DB "Символ окончания ввода строк - *", 0Dh, 0Ah, '$' 
    BUF_SYMBS DB 40 DUP(?)  ; Буфер для введенной строки
    HEX_TABLE DB '0123456789ABCDEF'  ; Таблица перекодировки
    BUF_CX DW ?  ; Буфер для счетчика цикла
    ROW_SYMBS DW 40  ; Макс. символов в строке
    ROWS DW 10  ; Макс. количество строк
DTSEG ENDS

STSEG SEGMENT PARA 'STACK' 
    DB 200 DUP(0) 
STSEG ENDS 

CDSEG SEGMENT PARA 'CODE' 
    ASSUME DS:DTSEG, SS:STSEG, CS:CDSEG 

MAIN PROC 
    ; Инициализация сегмента данных в коде
    mov AX, DTSEG 
    mov DS, AX 
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
        cmp AL, '*' 
        JE GO0 
        cmp AL, '$' 
        JE GO0 
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

GETCH PROC 
    mov AH, 01h 
    int 21h 
    ret 
GETCH ENDP 

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

CDSEG ENDS 
END MAIN