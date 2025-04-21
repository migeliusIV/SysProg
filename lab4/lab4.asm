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
        ; Инициализация цикла
        ;mov BX, OFFSET alphabet  ; адрес таблицы перекодировки
        mov CX, count            ; счетчик повторений
        sub al, start_char
        push AX

next_letter:
        ; Подготовка к XLAT
        pop bx
        mov ax, bx
        add al, start_char 
        mov DL, AL          ; Символ в DL
        call PUTCH
        inc bl
        push bx
        ; Вывод разделителя
        lea DX, space
        mov AH, 09h
        int 21h
        ; Вывод кода символа (шестнадцатеричное представление)
        ;(start_char + 20 - i)
        pop bx
        mov ax, count
        add al, start_char
        sub al, bl
        push bx
        call HEX

        ; Подготовка к следующей итерации
        call CLRF
        LOOP next_letter
        ;pop bx
        ; inc index           ; инкрементируем index для следующей итерации
        ;inc bx

while_end:
        ; Запрос на повторение
        lea DX, end_option
        mov AH, 09h
        int 21h
        call GETCH
        cmp AL, '*'
        jne finish
        jmp while_start

finish: ; end of program
        mov AX, 4C00h
        int 21h
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
    
    mov AL, BL
    and AL, 0Fh     ; Маскируем старшие биты
    call PRINT_NIBBLE

    ; Преобразуем старший ниббл
    mov AL, BL      ; Восстанавливаем символ
    mov CL, 4       ; Счетчик сдвига
    shr AL, CL      ; Сдвиг вправо на 4 бита
    call PRINT_NIBBLE
    
    ; Восстанавливаем регистры
    pop DX
    pop CX
    pop BX
    pop AX
    ret
HEX ENDP

PRINT_NIBBLE PROC near
    ; Вход: AL - ниббл (0-15) для вывода
    ; Преобразуем ниббл в ASCII-символ
    cmp AL, 10
    jl is_digit     ; Если меньше 10 - это цифра
    add AL, 'A'-10  ; Иначе - буква A-F
    jmp print_it

is_digit:
    add AL, '0'     ; Преобразуем цифру в ASCII 
                    ;(как в cpp, когда мы вычитаем буквы)

print_it:
    mov DL, AL      ; Выводим символ
    mov AH, 02h
    int 21h
    ret
PRINT_NIBBLE ENDP

code ends
END MAIN