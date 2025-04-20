TITLE  Программа лабораторной работы 5
; Автор: Гр.48Б

DATASG SEGMENT 'DATA'
    TABLHEX DB '0123456789ABCDEF'  ; Таблица для HEX-преобразования
    MSG DB 'Введите шестнадцатеричное число(HHHH, * - конец программы):$'
    MSGI DB 'Вывод после ввода 4-х шестнадц. цифр: <HHHH>=<HHHH> <DDDDD>$'
    BUF    DB  100 DUP(0)         ; Буфер для ввода
    DECW   DW  0                  ; Переменная для десятичного значения
    MSGERR DB 'Ошибка символа!$'  ; Сообщение об ошибке
DATASG ENDS

STSEG SEGMENT STACK 'STACK'
    DW 256 DUP(0)                ; Стек 256 слов
STSEG ENDS

MYCODE SEGMENT 'CODE'
    ASSUME CS:MYCODE, DS:DATASG, SS:STSEG
    
START:
    ; Инициализация сегментных регистров
    MOV AX, DATASG
    MOV DS, AX
    
    ; Очистка экрана
    MOV AH, 00H
    MOV AL, 03H
    INT 10H
    
    ; Вывод приглашения для ввода
    MOV AH, 9H
    LEA DX, MSG
    INT 21h
    CALL LFCR
    
    ; Вывод формата результата
    MOV AH,09H
    LEA DX, MSGI
    INT 21H
    CALL LFCR 

    ; Основной цикл программы (10 итераций)
    MOV CX, 10
METLOOP:
    ; Ввод HEX-числа
    CALL HEXADR
    
    ; Вывод разделителей
    MOV DL, ' '
    CALL PUTCH
    MOV DL, '='
    CALL PUTCH
    MOV DL, ' '
    CALL PUTCH
    
    ; Вывод HEX-числа
    CALL PRINTHEX
    MOV DL, ' '
    CALL PUTCH
    MOV DL, ' '
    CALL PUTCH
    
    ; Преобразование и вывод в десятичном формате
    CALL DECPRINT
    
    ; Переход на новую строку
    CALL LFCR
    LOOP METLOOP

MEND:
    ; Очистка экрана перед завершением
    MOV AH, 00H
    MOV AL, 03H
    INT 10H

    ; Завершение программы
    MOV AH, 4Ch
    MOV AL, 0
    INT 21H

; Процедура ввода HEX-числа
HEXADR PROC
    ; Подготовка цикла ввода (4 символа)
    MOV SI, OFFSET BUF
    MOV CX, 4
    
MVVOD:
    CALL GETSIMB
    CMP AL, '*'          ; Проверка на завершение
    JE MEND
    
    ; Проверка на допустимый HEX-символ
    CMP AL, '0'
    JB ERROR
    CMP AL, '9'
    JBE MBUF             ; Цифра 0-9
    CMP AL, 'A'
    JB ERROR
    CMP AL, 'F'
    JBE MBUF             ; Буква A-F
    CMP AL, 'a'
    JB ERROR
    CMP AL, 'f'
    JA ERROR
    
MBUF:
    ; Сохранение символа в буфер и вывод
    MOV [SI], AL
    INC SI
    MOV DL, AL
    CALL PUTCH
    LOOP MVVOD
    
    ; Завершение строки
    MOV BYTE PTR [SI], '$'
    RET
    
ERROR:
    ; Обработка ошибки ввода
    MOV AL,'#'
    MOV DX, OFFSET MSGERR
    MOV AH, 09H
    INT 21H
    CALL GETSIMB
    JMP MEND 
HEXADR ENDP

; Процедура вывода HEX-числа
PRINTHEX PROC
    MOV DX, OFFSET BUF
    MOV AH, 09H
    INT 21h
    RET
PRINTHEX ENDP

; Процедура преобразования символа в число
SIMPER PROC
    CMP AL, '9'
    JG MS1
    SUB AL, '0'       ; Цифра 0-9
    JMP MSE
MS1:
    CMP AL, 'F'
    JG MS2
    SUB AL, 'A'-10    ; Буква A-F
    JMP MSE
MS2:
    SUB AL, 'a'-10    ; Буква a-f
MSE:
    RET
SIMPER ENDP

; Процедура преобразования и вывода в десятичном формате
DECPRINT PROC
    ; Преобразование в машинное представление
    MOV SI, OFFSET BUF
    MOV BX, 4096       ; Вес старшего разряда (16^3)
    MOV DECW, 0
    MOV CX, 4
    
CPER:
    MOV AL, [SI]
    CALL SIMPER        ; Преобразование символа в число
    MOV AH, 0
    MUL BX             ; Умножение на вес разряда
    MOV DX, DECW
    ADD DX, AX         ; Суммирование результатов
    MOV DECW, DX
    SHR BX, 4          ; Переход к следующему разряду
    INC SI
    LOOP CPER
    
    ; Преобразование в десятичное представление
    MOV CX, 5          ; Максимум 5 десятичных цифр
    MOV BX, 10000      ; Начинаем с 10000
    
MDEC:
    MOV AX, DECW
    MOV DX, 0
    DIV BX             ; Выделяем цифру
    MOV DECW, DX       ; Остаток для следующих разрядов
    ADD AL, '0'        ; Преобразование в символ
    MOV DL, AL
    CALL PUTCH         ; Вывод цифры
    
    ; Уменьшаем делитель в 10 раз
    MOV AX, BX
    MOV DX, 0
    MOV BX, 10
    DIV BX
    MOV BX, AX
    LOOP MDEC
    
    RET
DECPRINT ENDP

; Процедура вывода символа (DL)
PUTCH PROC
    MOV AH, 2
    INT 21H
    RET
PUTCH ENDP

; Процедура перевода строки
LFCR PROC
    MOV DL, 10
    CALL PUTCH
    MOV DL, 13
    CALL PUTCH
    RET
LFCR ENDP

; Процедура ввода символа (результат в AL)
GETSIMB PROC
    MOV AH, 08H
    INT 21H
    RET
GETSIMB ENDP

MYCODE ENDS
END START