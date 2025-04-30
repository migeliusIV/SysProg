.MODEL small
.STACK 100h

.DATA
  prompt_cm  DB 'Введите значение в сантиметрах: $'
  prompt_inch DB 'Значение в дюймах: $'
  newline    DB 13, 10, '$'
  buffer     DB 10 DUP('$') ; Буфер для ввода сантиметров (9 цифр + Enter)
  cm         DW 0         ; Сантиметры (целое число)
  inches     DW 0        ; Дюймы (целое число)
  fraction   DW 0      ; Оставшаяся дробная часть (для более точного вывода)

  divisor    DW 254        ; Делитель для преобразования (2.54 * 100)

  err_msg  DB 'Ошибка ввода! Введите целое число.$'

.CODE
  MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; Вывод приглашения для ввода сантиметров
    MOV AH, 09h
    LEA DX, prompt_cm
    INT 21h

    ; Ввод сантиметров
    CALL read_number
    call CLRF
    ; Проверка на ошибку ввода
    CMP AX, -1
    db 0Fh, 84h                   ; Код операции для JE near (вручную)
    dw offset handle_input_error - ($ + 2)  ; 16-битное смещение
    ;JE handle_input_error

    MOV cm, AX      ; Сохраняем значение сантиметров

    ; Преобразование сантиметров в дюймы
    CALL convert_cm_to_inches

    ; Вывод дюймов
    CALL print_inches

    ; Завершение программы
    MOV AH, 4Ch
    INT 21h

  MAIN ENDP

;-----------------------------------------------------------------------------
; read_number - Читает число с клавиатуры и возвращает его в AX.
;               Возвращает -1 в AX, если произошла ошибка ввода.
;-----------------------------------------------------------------------------
read_number PROC
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    ; Чтение строки
    MOV AH, 0Ah
    LEA DX, buffer
    MOV buffer+0, 9 ; Максимальная длина ввода
    INT 21h

    ; Преобразование строки в число
    LEA SI, buffer+2 ; Указываем на начало введенной строки
    MOV AX, 0      ; Инициализируем число
    MOV CX, 0       ; Флаг ошибки (0 - нет ошибки, 1 - ошибка)

convert_loop:
    MOV BL, [SI]
    CMP BL, 13      ; Проверка на Enter
    JE conversion_done

    SUB BL, '0'     ; Преобразуем символ в число
    CMP BL, 0
    JL number_input_error  ; Если символ меньше '0', то ошибка
    CMP BL, 9
    JG number_input_error  ; Если символ больше '9', то ошибка

    MOV DX, 0       ; DX должен быть 0 перед умножением
    MOV BX, 10
    MUL BX          ; Умножаем AX на 10
    JO number_input_error   ; Переполнение
    ADD AL, BL      ; Добавляем новую цифру
    JO number_input_error  ; Переполнение
    INC SI          ; Переходим к следующему символу
    JMP convert_loop

conversion_done:
    JMP number_cleanup

number_input_error:
    MOV AX, -1      ; Возвращаем -1, если произошла ошибка ввода

number_cleanup:
    POP SI
    POP DX
    POP CX
    POP BX
    RET
read_number ENDP

;-----------------------------------------------------------------------------
; convert_cm_to_inches - Преобразует сантиметры (cm) в дюймы.
;                         cm - значение в сантиметрах (в переменной cm)
;                         inches - значение в дюймах (в переменной inches)
;-----------------------------------------------------------------------------
convert_cm_to_inches PROC
    PUSH AX
    PUSH DX

    MOV AX, cm     ; Загружаем сантиметры в AX
    MOV DX, 0      ; Обнуляем DX (для деления)
    MOV BX, divisor     ; Загружаем делитель (254)
    DIV BX          ; AX = целая часть дюймов, DX = остаток

    MOV inches, AX    ; Сохраняем целую часть дюймов
    MOV fraction, DX  ; Сохраняем дробную часть

    POP DX
    POP AX
    RET
convert_cm_to_inches ENDP


CLRF PROC 
    mov DL, 0Ah 
    call PUTCH 
    mov DL, 0Dh 
    call PUTCH 
    ret 
CLRF ENDP


;-----------------------------------------------------------------------------
; print_inches - Выводит значение дюймов на экран.
;-----------------------------------------------------------------------------
print_inches PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    ; Вывод приглашения для вывода дюймов
    MOV AH, 09h
    LEA DX, prompt_inch
    INT 21h

    ; Преобразование целой части дюймов в строку
    MOV AX, inches    ; Загружаем целую часть дюймов
    LEA DI, buffer + 9  ; Указываем на конец буфера (для формирования строки в обратном порядке)
    MOV BYTE PTR [DI], '$' ; Завершаем строку символом '$'
    DEC DI

to_string_loop:
    MOV DX, 0       ; DX должен быть 0 перед делением
    MOV BX, 10
    DIV BX          ; AX = частное, DX = остаток

    ADD DL, '0'     ; Преобразуем цифру в символ
    MOV [DI], DL    ; Сохраняем символ в буфере
    DEC DI          ; Переходим к следующему символу
    CMP AX, 0       ; Проверка, если частное равно 0
    JNE to_string_loop

    ; Вывод строки с дюймами
    MOV AH, 09h
    INC DI          ; Указываем на начало строки
    MOV DX, DI
    INT 21h
    MOV AH, 09h
        LEA DX, newline
        INT 21h

print_cleanup:
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
print_inches ENDP

;-----------------------------------------------------------------------------
; handle_input_error - Выводит сообщение об ошибке ввода.
;-----------------------------------------------------------------------------
handle_input_error PROC
    MOV AH, 09h
    LEA DX, err_msg
    INT 21h
    MOV AH, 09h
        LEA DX, newline
        INT 21h
    RET
handle_input_error ENDP

END MAIN