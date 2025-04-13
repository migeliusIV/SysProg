.MODEL SMALL
stack segment
        db 100h dup(?) 
stack ends

data segment
    prompt  db 'Enter the first russian letter (uppercase): $'
    end_option db 'Enter symbol * to stop programm. $'
    flag db 'They not$'
    ;newline db 13, 10, '$' ; Перевод строки
    space   db ' - ', '$'  ; разделитель " - "
    counter_outer dw 20
    counter_inner dw 20    ; Количество букв для вывода
    start_char db ?        ; Начальный символ, введенный пользователем
data ends

code segment
        assume cs:code, ds:data, ss:stack  ; Указываем сегменты

MAIN PROC
        mov AX, stack      ; Загружаем адрес сегмента стека в AX
        mov SS, AX         ; Устанавливаем SS на сегмент стека
        mov SP, 100h       ; Устанавливаем указатель стека (SP) в конец стека

        mov AX, data
        mov DS, AX
        ; подготовка цикла
        ;mov CX, counter_outer    ; Счетчик цикла (20 повторений)
; Главное меню
;menu:
        mov ax, 0  
        ; Вывод приглашения
        lea DX, prompt
        mov AH, 09h
        int 21h
        
        ; Чтение символа с клавиатуры (без эха)
        call GETCH
        mov start_char, AL  ; Сохраняем введенную букву

        ; Основной цикл
        mov CX, counter_inner    ; Счетчик цикла (20 букв)
        mov AL, start_char  ; Загружаем начальную букву в AL

        next_letter:
                ; Вывод символа (прописной буквы)
                mov DL, AL
                call PUTCH
                
                ; Вывод разделителя " - "
                lea DX, space
                mov AH, 09h
                int 21h

                ; Преобразование символа в шестнадцатеричное представление
                push AX          ; Сохраняем AL (значение символа) для преобразования
                mov AH, 0        ; Обнуляем AH, чтобы получить полное 16-битное значение
                mov BX, AX       ; Сохраняем в BX для преобразования
                ; Преобразование
                call print_hex

                pop AX          ; Восстанавливаем AL (значение символа)
                call CLRF       ; Перевод строки

                ; Подготовка к следующей букве
                inc start_char          ; Переходим к следующей букве
                mov al, start_char
                LOOP next_letter ; Уменьшаем счетчик и переходим к следующей букве, если CX > 0
        end_next_letter:

        ; пауза
        lea DX, end_option
        mov AH, 09h
        int 21h
        call GETCH
begin_if:
        cmp AL, 2Ah
        jne end_if   ; установить метку меню
        lea DX, flag ; это просто убрать
        mov AH, 09h
        int 21h
end_if:
        ; Завершение программы
        mov ax, 4C00h ; код завершения программы
        int 21h
MAIN ENDP

    ; Процедура для вывода шестнадцатеричного значения
print_hex proc NEAR
        push CX           ; Сохраняем регистры, которые будут использоваться
        push BX
        push DX
        mov CX, 4         ; 4 шестнадцатеричные цифры (для 16-битного числа)
        
hex_loop:
        shl BX, 4         ; Сдвигаем BX на 4 бита влево (выделяем старшую цифру)
        mov DX, BX       ;
        and DX, 0F000h     ; выделяем старшую цифру
        mov DL, DH            ; Получаем цифру
        shr DL, 4
        cmp DL, 9
        JLE hex_digit       ; Если цифра <= 9, то отображаем как есть
        add DL, 7           ; Если цифра > 9, то добавляем 7 для букв A-F (10-15)
        
hex_digit:
        add DL, '0'         ; Преобразуем цифру в ASCII-код
        mov ah, 2h
        int 21h
        LOOP hex_loop       ; Повторяем для всех 4 цифр

        pop DX           ; Восстанавливаем регистры
        pop BX
        pop CX
        ret
print_hex ENDP

PUTCH proc near
    mov ah, 2h
    int 21h
    ret
PUTCH endp

GETCH proc near
        mov AH, 07h
        int 21h
        ret
GETCH ENDP

CLRF proc near ; перевод курсора на новую строку
    mov dl, 13
    call PUTCH
    mov dl, 10
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

code ends
END MAIN