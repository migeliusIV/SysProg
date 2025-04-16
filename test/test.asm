.MODEL SMALL
.STACK 100h

.DATA
    prompt      db 'Enter first Russian letter (uppercase): $'
    newline     db 13, 10, '$'
    separator   db ' - $'
    count       dw 20
    
    ; Таблица русских букв А-Я в CP866
    alphabet    db 80h,81h,82h,83h,84h,85h,86h,87h,88h,89h,8Ah,8Bh,8Ch,8Dh,8Eh,8Fh
                db 90h,91h,92h,93h,94h,95h,96h,97h,98h,99h,9Ah,9Bh,9Ch,9Dh,9Eh,9Fh
    
    start_index db ?
    error_msg   db 13,10,'Error: Not Russian uppercase letter!',13,10,'$'
    repeat_msg  db 13,10,'Press * to repeat, any other key to exit: $'

.CODE
START:
    mov ax, @data
    mov ds, ax
    
main_loop:
    ; Очистка экрана
    mov ax, 0600h
    mov bh, 07h
    xor cx, cx
    mov dx, 184Fh
    int 10h
    
    ; Установка курсора
    mov ah, 02h
    xor bh, bh
    xor dx, dx
    int 10h
    
    ; Вывод приглашения
    mov ah, 09h
    lea dx, prompt
    int 21h
    
    ; Ввод символа
    mov ah, 01h
    int 21h
    
    ; Проверка что это русская буква в CP866
    cmp al, 80h
    jb not_russian
    cmp al, 9Fh
    ja not_russian
    
    ; Вычисляем стартовый индекс
    sub al, 80h
    mov start_index, al
    
    ; Настройка для цикла
    mov cx, count
    mov si, offset alphabet
    
    ; Новая строка
    mov ah, 09h
    lea dx, newline
    int 21h
    
print_loop:
    ; Получаем текущий символ
    mov bl, start_index
    xor bh, bh
    mov al, [si+bx]
    
    ; Сохраняем символ
    push ax
    
    ; Выводим символ
    mov dl, al
    mov ah, 02h
    int 21h
    
    ; Выводим разделитель
    mov ah, 09h
    lea dx, separator
    int 21h
    
    ; Восстанавливаем символ
    pop ax
    
    ; Выводим HEX код
    call PRINT_HEX
    
    ; Новая строка
    mov ah, 09h
    lea dx, newline
    int 21h
    
    ; Увеличиваем индекс
    inc start_index
    cmp start_index, 32
    jb next_char
    mov start_index, 0
    
next_char:
    loop print_loop
    
    ; Запрос на повтор
    mov ah, 09h
    lea dx, repeat_msg
    int 21h
    
    mov ah, 01h
    int 21h
    cmp al, '*'
    je main_loop
    
    ; Выход
    mov ax, 4C00h
    int 21h
    
not_russian:
    mov ah, 09h
    lea dx, error_msg
    int 21h
    
    ; Запрос на повтор
    mov ah, 09h
    lea dx, repeat_msg
    int 21h
    
    mov ah, 01h
    int 21h
    cmp al, '*'
    je main_loop
    
    ; Выход
    mov ax, 4C00h
    int 21h

; Процедура вывода HEX-кода символа
; Вход: AL = символ
PRINT_HEX PROC
    push ax
    push bx
    push cx
    push dx
    
    ; Сохраняем символ
    mov bl, al
    
    ; Выводим префикс
    mov dl, '0'
    mov ah, 02h
    int 21h
    mov dl, 'x'
    int 21h
    
    ; Старший ниббл
    mov al, bl
    mov cl, 4
    shr al, cl
    call PRINT_NIBBLE
    
    ; Младший ниббл
    mov al, bl
    and al, 0Fh
    call PRINT_NIBBLE
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
PRINT_HEX ENDP

; Процедура вывода ниббла
; Вход: AL = ниббл (0-15)
PRINT_NIBBLE PROC
    cmp al, 10
    jb digit
    add al, 'A'-10
    jmp print
digit:
    add al, '0'
print:
    mov dl, al
    mov ah, 02h
    int 21h
    ret
PRINT_NIBBLE ENDP

END START