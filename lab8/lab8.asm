.MODEL SMALL
stack segment
        db 100h dup(?) 
stack ends

data segment
    input_msg db "Enter the number in a 16th SS: $"
data ends

code segment
    assume cs:code, ds:data, ss:stack

MAIN PROC
    ; Инициализация сегментных регистров
    mov ax, data
    mov ds, ax

    call CLRSCR
    call CLRF

    ; Вывод приглашения
    mov ah, 09h
    lea dx, input_msg
    int 21h

    ; Ввод символа
    call GETCH      ; символ в AL
    mov ah, al      ; сохраняем в AH

    ; Проверка диапазона
    cmp ah, '0'
    jb error
    cmp ah, '9'
    jbe digit       ; если цифра 0-9
    cmp ah, 'A'
    jb error
    cmp ah, 'F'
    jbe letter      ; если буква A-F
    jmp error       ; иначе ошибка

digit:
    sub ah, '0'     ; преобразуем ASCII в число
    jmp print

letter:
    sub ah, 'A'     ; A -> 0, B -> 1, ..., F -> 5
    add ah, 10      ; A -> 10, B -> 11, ..., F -> 15
    jmp print

error:
    mov al, '?'     ; вывод символа ошибки
    call PUTCH
    jmp finish

print:
    ; Вывод знака равенства
    mov al, '='
    call PUTCH
    
    ; Преобразуем число в AH в двухзначное десятичное
    mov al, ah      ; число для вывода (0-15)
    xor ah, ah      ; очищаем AH

convertion:
    mov bl, 254
    mul bl
    
    mov bl, 100
    div bl
    push ax
    xor ah, ah

int_print:
    mov bl, 10
    div bl          ; AL = частное, AH = остаток
    
    ; Сохраняем остаток
    push ax
    
    ; Выводим десятки (если они есть)
    cmp al, 0
    je skip_tens
    call PRINT_NIBBLE
    
int_skip_tens:
    ; Выводим единицы
    pop ax
    mov al, ah
    call PRINT_NIBBLE

    ;===space
    mov al, ','
    call putch

float_print:
    ;===floating
    pop ax
    mov al, ah
    xor ah, ah
    mov bl, 10
    div bl          ; AL = частное, AH = остаток
    
    ; Сохраняем остаток
    push ax
    
    ; Выводим десятки (если они есть)
    cmp al, 0
    je skip_tens_1
    call PRINT_NIBBLE
    
float_skip_tens:
    ; Выводим единицы
    pop ax
    mov al, ah
    call PRINT_NIBBLE
    ;=======
    ; Переводим строку
    call CLRF
finish:
    mov ax, 4C00h
    int 21h
MAIN ENDP

; Остальные процедуры остаются без изменений
PUTCH proc near
    push ax
    push dx

    mov ah, 2h
    mov dl, al
    int 21h
    
    pop dx
    pop ax
    ret
PUTCH endp

GETCH proc near
    mov AH, 01h
    int 21h
    ret
GETCH ENDP

CLRF proc near
    mov al, 13
    call PUTCH
    mov al, 10
    call PUTCH
    ret
CLRF endp

CLRSCR proc near
    mov ax, 0600h
    mov bh, 07h
    mov cx, 0000h
    mov dx, 184Fh
    int 10h
    ret
CLRSCR endp

PRINT_NIBBLE PROC near
    cmp AL, 10
    jl is_digit
    add AL, 'A'-10
    jmp print_it
is_digit:
    add AL, '0'
print_it:
    mov DL, AL
    mov AH, 02h
    int 21h
    ret
PRINT_NIBBLE ENDP

code ends
END MAIN