.MODEL SMALL
.STACK 100H

.DATA
    MESSAGE DB "жопа$"

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    MOV AH, 09H      ; Функция для вывода строки
    MOV DX, OFFSET MESSAGE
    INT 21H          ; Вызов прерывания DOS

    MOV AH, 4CH      ; Функция для завершения программы
    INT 21H          ; Вызов прерывания DOS
MAIN ENDP
END MAIN