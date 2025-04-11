.MODEL SMALL
.STACK 100h

.DATA
    prompt db 'Enter the first russian letter (uppercase): $'
    newline db 13, 10, '$' ; Перевод строки
    space   db ' - ', '$'  ; разделитель " - "
    count   dw 20         ; Количество букв для вывода
    start_char db ?         ; Начальный символ, введенный пользователем

.CODE
    MAIN PROC
        MOV AX, @DATA
        MOV DS, AX

        ; 1. Ввод начальной буквы

        ; Вывод приглашения
        LEA DX, prompt
        MOV AH, 09h
        INT 21h

        ; Чтение символа с клавиатуры (без эха)
        MOV AH, 07h
        INT 21h
        MOV start_char, AL  ; Сохраняем введенную букву

        ; 2. Основной цикл

        MOV CX, count    ; Счетчик цикла (20 букв)
        MOV AL, start_char  ; Загружаем начальную букву в AL
next_letter:

        ; Вывод символа (прописной буквы)
        MOV DL, AL
        MOV AH, 02h
        INT 21h

        ; Вывод разделителя " - "
        LEA DX, space
        MOV AH, 09h
        INT 21h

        ; Преобразование символа в шестнадцатеричное представление
        PUSH AX          ; Сохраняем AL (значение символа) для преобразования
        MOV AH, 0       ; Обнуляем AH, чтобы получить полное 16-битное значение
        MOV BX, AX       ; Сохраняем в BX для преобразования
        ; Преобразование
        CALL print_hex

        POP AX          ; Восстанавливаем AL (значение символа)
        ; Перевод строки
        LEA DX, newline
        MOV AH, 09h
        INT 21h

        ; Подготовка к следующей букве
        INC AL          ; Переходим к следующей букве
        LOOP next_letter ; Уменьшаем счетчик и переходим к следующей букве, если CX > 0

        ; Завершение программы
        MOV AH, 4Ch
        INT 21h
    MAIN ENDP

    ; Процедура для вывода шестнадцатеричного значения
print_hex PROC NEAR
        PUSH CX           ; Сохраняем регистры, которые будут использоваться
        PUSH BX
        PUSH DX

        MOV CX, 4         ; 4 шестнадцатеричные цифры (для 16-битного числа)
hex_loop:
        SHL BX, 4         ; Сдвигаем BX на 4 бита влево (выделяем старшую цифру)
        MOV DX, BX       ;
        AND DX, 0F000h     ; выделяем старшую цифру
        MOV DL, DH            ; Получаем цифру
        SHR DL, 4
        CMP DL, 9
        JLE hex_digit       ; Если цифра <= 9, то отображаем как есть
        ADD DL, 7           ; Если цифра > 9, то добавляем 7 для букв A-F (10-15)
hex_digit:
        ADD DL, '0'         ; Преобразуем цифру в ASCII-код
        MOV AH, 02h
        INT 21h
        LOOP hex_loop       ; Повторяем для всех 4 цифр

        POP DX           ; Восстанавливаем регистры
        POP BX
        POP CX
        RET
print_hex ENDP

END MAIN