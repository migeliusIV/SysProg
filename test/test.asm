; Тестовый пример ЛР5 
;СЕГМЕНТ ДАННЫХ
DTSEG SEGMENT PARA 'DATA' 
; Справочные сообщения для пользователя. 
    MES0 DB "Максимальное кол-во символов в строке - 20", 0Dh, 0Ah, '$' 
    MES1 DB "Символ окончание ввода строки - `знак доллара`", 0Dh, 0Ah, '$' 
    MES2 DB "Максимальное кол-во строк - 10", 0Dh, 0Ah, '$' 
    MES3 DB "Символ окончания ввода строк - *", 0Dh, 0Ah, '$' 
    BUF_SYMBS DB 40 DUP(?)  ; Символьный буфер для введенной строки. 
    HEX_TABLE DB '0123456789ABCDEF'  ; Таблица перекодировки для процедуры 
    BUF_CX DW ? ; Буфер для счетчика внешнего цикла. 
    ROW_SYMBS DW 40  ; Максимальное кол-во символов в одной строке. 
    ROWS DW 10  ; Максимальное кол-во вводимых строк. 
DTSEG ENDS

STSEG SEGMENT PARA 'STACK' 
    DB 200 DUP(0) 
STSEG ENDS 
; СЕГМЕНТ КОДА
CDSEG SEGMENT PARA 'CODE' 
    ASSUME DS:DTSEG, SS:STSEG, CS:CDSEG 
; СЕГМЕНТ КОДА
; Вход в прСограмму 
MAIN PROC 
    MOV AX, DTSEG 
    MOV DS, AX 
    ; Вывод справочных сообщений. 
    MOV DX, OFFSET MES0 
    CALL PUTMES 
    MOV DX, OFFSET MES1 
    CALL PUTMES 
    MOV DX, OFFSET MES2 
    CALL PUTMES 
    MOV DX, OFFSET MES3 
    CALL PUTMES 
    CALL CLRF 
    MOV BX, OFFSET HEX_TABLE 
    MOV CX, ROWS  ; Счетчик для цикла LOOP0. 
    ; ЦИКЛ ПО СТРОКАМ
    LOOP0: 
    ; Цикл ввода строк. 
    MOV BUF_CX, CX 
    MOV CX, ROW_SYMBS  ; Счетчик для цикла LOOP1. 
    MOV SI, 0  ; Счетчик символьного буфера. 
    
LOOP1: 
; Цикл ввода одной строки. 
    CALL GETCH  ; Ввод символа. 
    ; Проверка окончания ввода строк. 
    CMP AL, '*' 
    JE GO0 
    ; Проверка окончания ввода строки. 
    CMP AL, '$' 
    JE GO0 
    MOV BUF_SYMBS[SI], AL  ; Запись считанного символа в символьный буфер. 
    INC SI 
    LOOP LOOP1 
GO0: 
; 
; Проверка, что строка пустая или является конечной (введен символ "*" 
    CMP SI, 0 
    JE GO1 
    ; Ввывод строки " = ". 
    CALL PUTSPACE 
    MOV DL, 3DH 
    ; вывод символа пробела 
    CALL PUTCH 
    CALL PUTSPACE 
    MOV CX, SI  ; Счетчик для цикла LOOP2 (равен кол-во введенных ;символов). 
    MOV SI, 0  ; Счетчик символьного буфера. 

;ЦИКЛ чтения и преобразования 
LOOP2: 
    ; Цикл преобразования символов введеной строки. 
    MOV AL, BUF_SYMBS[SI]  ; Чтение символа из символьного буфера. 
    INC SI 
    CALL HEX  ; Перекодировка и печать
    ;Пробел 
    CALL PUTSPACE 
    ; Конец цикла вывода из буфера
    LOOP LOOP2 

GO1: 
    ; Проверка, что введенная строка является конечной. 
    CMP AL, '*' 
    JE END_PROG 
    
    CALL CLRF 
    ; для цикла ввода строки 
    MOV CX, BUF_CX 
    ; Конец цмкла ввода строк
    LOOP LOOP0 
    
END_PROG: 
    ; Завершение работы программы. 
    
    MOV AH, 4CH 
    INT 21H 
MAIN ENDP 
;ПРОЦЕДУРЫ ПРОГРАММЫ
PUTCH PROC 
    ; Процедура вывода символа. 
    MOV AH, 02H 
    INT 21H 
    RET 
PUTCH ENDP 

PUTSPACE PROC 
    ; Процедура вывода пробела. 
    MOV DL, 20H 
    MOV AH, 02H 
    INT 21H 
    RET 
PUTSPACE ENDP 

PUTMES PROC 
    ; Процедура вывода текстового сообщения. 
    MOV AH, 09H 
    INT 21H 
    RET 
PUTMES ENDP 

CLRF PROC 
    ; Процедура перевода строки и возврата каретки. 
    MOV AH, 02H 
    MOV DL, 0AH 
    INT 21H 
    MOV DL, 0DH 
    INT 21H 
    RET 
CLRF ENDP 

GETCH PROC 
    ; Процедура ввода символа. 
    MOV AH, 01H 
    INT 21H 
    RET 
GETCH ENDP 

HEX PROC 
    ; Процедура перекадировки 
    PUSH AX 
    ; Получаем значение старшего полубайта. 
    MOV DL, AL 
    SHR DL, 4 
    MOV AL, DL 
    XLAT 
    ; Выводим значение старшего полубайта. 
    MOV DL, AL 
    CALL PUTCH 
    ; Получаем значение младшего полубайта. 
    POP AX 
    MOV DL, AL 
    SHL DL, 4 
    SHR DL, 4 
    MOV AL, DL 
    XLAT 
    ; Выводим значение младшего полубайта. 
    MOV DL, AL 
    CALL PUTCH 
    RET 
HEX ENDP  

CDSEG ENDS 
 
END MAIN