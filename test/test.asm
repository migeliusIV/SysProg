data segment
    msg_prompt db 'Введите число$'
    msg_in_error db 'Ошибка! Введен неправильный символ! $'
    msg_stat db 'Успех! Введено число = $'
    int_input dd 12
    post db 0 ; количество чисел после запятой
    flg db 0 ; 0 - int, 1 - float
data ends

stack segment
    ? db 200 DUP(0) ; dup - однотипные данные
stack ends

EXTERN print_float:PROC  

code segment
    assume ds:data, ss:stack, cs:code

main proc
menu:
    call CLRSCR
    mov dl, msg_prompt
    call putmes
    call CLRF
    push 0

int_input:
    call getchecho
    cmp al, '0'
    jl not_digit
    cmp al, '9'
    jg not_digit
    ; proces
    mov dh, al  ; перенос в верхний подрегистр  
    pop ax      ; то, что прежде введено
    sub dh, '0' ; перевод из ASCII в число
    add ah, dh  ; суммирование старого и нового числа 
    mov bl, 10  ; 
    mul bl      ; умножение результата на 10
    push ax     ; сохранение промежуточного результата

not_digit:
    cmp al, '.'
    jne input_error
    flg = 1
    push 0
    jmp fraction_input

input_error:
    call CLRF
    mov dl, msg_in_error
    call putmes
    jmp menu
    
fraction_input:
    call getchecho
    cmp al, '0'
    jl input_error
    cmp al, '9'
    jg input_error
    ; proces
    mov dl, al  ; перенос в верхний подрегистр  
    pop ax      ; то, что прежде введено
    sub dl, '0' ; перевод из ASCII в число
    add al, dl  ; суммирование старого и нового числа 
    mov bl, 10  ; 
    mul bl      ; умножение результата на 10
    push ax     ; сохранение промежуточного результата

    ; process
    cmp flg, 1
    je fraction_proc
int_proc:
    mov ax, ax ; обнуляем ax
    pop ax     ; считы
    mov bl, 5
    mul bl
    mul bl, 2
    div bl
    ; ...
    call print

fraction_proc:
    mov ax, ax ; обнуляем ax
    pop ax     ; считываем дробную часть
    mov bl, 2
    mul bl
    mul bl, 5
    div bl
    
    call int_proc
    
print:
    call digitOut
    
end:
    mov AH, 4Ch 
    int 21h 
main endp

;---- Вспомогательные процедуры ----
digitOut proc
while:
    cmp ax, 9
    ;j
    call putch
    ret
digitOut endp

putch proc
    mov AH, 02h ; или AL
    int 21h
    ret
putch endp

PUTMES PROC ; процедура вывода массива
    mov AH, 09h 
    int 21h 
    ret 
PUTMES ENDP

GETCHECHO PROC 
    mov AH, 01h 
    int 21h 
    ret 
GETCHECHO ENDP 

CLRF PROC 
    mov DL, 0Ah 
    call PUTCH 
    mov DL, 0Dh 
    call PUTCH 
    ret 
CLRF ENDP 

CLRSCR proc near ; процедура очистки экрана
    mov ax, 0600h
    mov bh, 07h
    mov cx, 0000h
    mov dx, 184Fh
    int 10h
    ret
CLRSCR endp
code ends
end main 
; Можно ли сохранить на стек вызовов (?) посчитанные прошлым сегментом кода.
; Т.е. можно ли запустить две подряд программы на одном сегменте данных.