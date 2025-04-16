.MODEL SMALL
stack segment
        db 100h dup(?) 
stack ends

data segment
    prompt  db 'Enter the first russian letter (uppercase): $'
    newline db 13, 10, '$'
    space   db ' - ', '$'
    count   dw 20

    ; Таблица русских букв (А-Я) в кодировке CP866
    alphabet db 80h, 81h, 82h, 83h, 84h, 85h, 86h, 87h, 88h, 89h, 8Ah, 8Bh, 8Ch, 8Dh, 8Eh, 8Fh, 90h, 91h, 92h, 93h, 94h, 95h, 96h, 97h, 98h, 99h, 9Ah, 9Bh, 9Ch, 9Dh, 9Eh, 9Fh

    start_char db ?
    index db ?
    error_message db "Error: Input character out of alphabet range$"
    end_option db "Press * to repeat.$"
data ends

code segment
    assume cs:code, ds:data, ss:stack  ; Указываем сегменты
MAIN PROC
    mov AX, stack      ; Загружаем адрес сегмента стека в AX
    mov SS, AX         ; Устанавливаем SS на сегмент стека
    mov SP, 100h       ; Устанавливаем указатель стека (SP) в конец стека
    mov AX, data
    mov DS, AX

while_start:
        ; consol's prepearing
        call CLRSCR
        call CLRF
        ; start-massege
        lea DX, prompt
        mov AH, 09h
        int 21h
        ; symbol reading
        call GETCH
        mov start_char, AL
        ; Проверяем, что введена русская буква (CP866: 0x80 - 0x9F)
        cmp AL, 80h
        jl error_input
        cmp AL, 9Fh
        jg error_input

        ; Вычисляем индекс в таблице перекодировки (AL - 0x80)
        sub AL, 80h
        mov index, AL
        ; Инициализация цикла
        mov BX, OFFSET alphabet  ; адрес таблицы перекодировки
        mov CX, count            ; счетчик повторений

next_letter:
        ; Подготовка к XLAT
        mov AL, index          ; Получаем текущий индекс
        push AX             ; Сохраняем индекс
        XLAT                 ; AL = alphabet[AL]
        mov DL, AL          ; Символ в DL
        call PUTCH
        ; Сохраняем AX для вывода кода
        ;push AX

        ; Вывод разделителя
        lea DX, space
        mov AH, 09h
        int 21h

        ; Вывод кода символа (шестнадцатеричное представление)
        ;pop AX    ; Retrieve character
        call HEX

        ; Подготовка к следующей итерации
        call CLRF
        ;pop AX              ; Retrieve index
        inc index           ; инкрементируем index для следующей итерации
        cmp index, 32       ; Проверяем, не вышли ли мы за границы алфавита
        jl no_wrap          ; если не вышли - остаемся в цикле
        mov index, 0        ; Сброс индекса, если вышли за границы

no_wrap: ; if alphabet has ended
        mov AL, index          ; Загружаем новый индекс
        LOOP next_letter        ;  LOOP decreases CX by 1

while_end:
        ; Запрос на повторение
        lea DX, end_option
        mov AH, 09h
        int 21h
        call GETCH
        cmp AL, '*'
        jne finish
        jmp while_start

error_input:
    ; end of program with an error
    LEA DX, error_message
    MOV AH, 09h
    INT 21h

finish: ; end of program
    MOV AX, 4C00h
    INT 21h
MAIN ENDP

PUTCH proc near
    mov ah, 2h
    mov dl, al
    int 21h
    ret
PUTCH endp

GETCH proc near
        mov AH, 07h
        int 21h
        ret
GETCH ENDP

CLRF proc near ; перевод курсора на новую строку
    mov al, 13
    call PUTCH
    mov al, 10
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

HEX PROC near
    ; Сохраняем регистры
    push AX
    push BX
    push CX
    push DX
    
    ; Сохраняем символ
    mov BL, AL
    
    ; Выводим префикс "0x"
    mov DL, '0'
    mov AH, 02h
    int 21h
    mov DL, 'x'
    int 21h
    
    ; Преобразуем старший ниббл
    mov AL, BL
    mov CL, 4
    shr AL, CL
    call PRINT_NIBBLE
    
    ; Преобразуем младший ниббл
    mov AL, BL
    and AL, 0Fh
    call PRINT_NIBBLE
    
    ; Восстанавливаем регистры
    pop DX
    pop CX
    pop BX
    pop AX
    ret
HEX ENDP

PRINT_NIBBLE PROC
    ; Вход: AL - ниббл (0-15) для вывода
    ; Преобразуем ниббл в ASCII-символ
    cmp AL, 10
    jl is_digit     ; Если меньше 10 - это цифра
    add AL, 'A'-10  ; Иначе - буква A-F
    jmp print_it
is_digit:
    add AL, '0'     ; Преобразуем цифру в ASCII
print_it:
    mov DL, AL      ; Выводим символ
    mov AH, 02h
    int 21h
    ret
PRINT_NIBBLE ENDP

code ends
END MAIN