; Сегмент кода
MYCODE SEGMENT 'CODE'
    ASSUME CS:MYCODE
    PUBLIC LET
    
; Данные программы
LET  DB 'A'                  ; Символ-маркер
HEXTAB DB '0123456789ABCDEF' ; Таблица для HEX-вывода
msg1 db 'Число байт параметров в строке:$'
msg2 DB 'Число параметров в командной строке:$'
msg3 DB 'Параметры:$'
msg4 DB 'Параметры отсутствуют$'
adrPSP dw 0                  ; Адрес PSP
bufpar DB 128 DUP ('$')      ; Буфер для параметров
Counter DB 0                 ; Счетчик байт параметров
CounterPar db 0              ; Счетчик параметров

START:
    ; Инициализация сегментного регистра DS
    PUSH CS
    POP DS
    
    ; Получение адреса PSP
    MOV AH, 51h
    INT 21H
    MOV adrPSP, BX           ; Сохраняем адрес PSP
    MOV ES, BX               ; ES указывает на PSP
    
    ; Получение длины параметров
    MOV BX, 128              ; Смещение длины параметров в PSP
    MOV BL, ES:[BX]          ; Читаем длину параметров
    MOV Counter, BL          ; Сохраняем счетчик
    
    ; Проверка наличия параметров
    CMP BL, 00H
    JE FIN0                  ; Если параметров нет - завершаем
    
    ; Вывод сообщения о числе байт параметров
    MOV AH, 09h
    MOV DX, OFFSET msg1
    INT 21H
    
    ; Вывод числа байт в HEX
    MOV DL, Counter
    CALL HEXPR
    CALL CRLF
    
    ; Копирование параметров в буфер
    MOV SI, 0                ; Индекс в буфере
    MOV BX, 129              ; Начало параметров в PSP
    XOR CX, CX
    MOV CL, Counter          ; Счетчик байт
    
    ; Цикл копирования параметров
savepar:
    MOV DL, ES:[BX]          ; Читаем символ из PSP
    MOV bufpar[SI], DL       ; Сохраняем в буфер
    
    ; Проверка на разделитель (пробел)
    CMP DL, ' '
    JNE S2
    INC CounterPar           ; Увеличиваем счетчик параметров
S2:
    INC SI                   ; Следующая позиция в буфере
    INC BX                   ; Следующий символ в PSP
    LOOP savepar
    
    ; Завершение строки параметров
    MOV bufpar[SI], '$'
    
    ; Вывод параметров
    MOV DX, OFFSET msg3
    MOV AH, 09H
    INT 21H
    MOV DX, OFFSET bufpar
    INT 21H 
    CALL CRLF
    
    ; Вывод числа параметров
    MOV DX, OFFSET msg2
    MOV AH, 09H
    INT 21H
    MOV DL, CounterPar
    CALL HEXPR
    CALL CRLF
    JMP FIN
    
; Обработка отсутствия параметров
FIN0:
    MOV DX, OFFSET msg4
    MOV AH, 09H
    INT 21H
    CALL CRLF
    
; Завершение программы
FIN:
    MOV AH, 4CH
    INT 21H

; Процедура вывода символа
PUTC PROC
    MOV AH, 02
    INT 21H
    RET
PUTC ENDP

; Процедура перевода строки
CRLF PROC
    MOV DL, 10
    CALL PUTC
    MOV DL, 13
    CALL PUTC
    RET
CRLF ENDP

; Процедура вывода числа в HEX
HEXPR PROC
    MOV BX, OFFSET HEXTAB
    PUSH DX
    MOV AL, DL
    SHR AL, 4
    XLAT
    MOV DL, AL
    CALL PUTC
    POP DX
    MOV AL, DL
    AND AL, 0FH
    XLAT
    MOV DL, AL
    CALL PUTC
    MOV DL, 'H'
    CALL PUTC
    RET
HEXPR ENDP

MYCODE ENDS
END START