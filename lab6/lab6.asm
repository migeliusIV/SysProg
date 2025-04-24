; ������� ����
MYCODE SEGMENT 'CODE'
    ASSUME CS:MYCODE
    PUBLIC LET
    
; ����� �ணࠬ��
LET  DB 'A'                  ; ������-��થ�
HEXTAB DB '0123456789ABCDEF' ; ������ ��� HEX-�뢮��
msg1 db '��᫮ ���� ��ࠬ��஢ � ��ப�:$'
msg_first DB '���� ��ࠬ���: $'
msg_sec DB '��ࠬ����:$'
msg4 DB '��ࠬ���� ����������$'
msg_sec_true DB '���������$'
msg_sec_false DB '���������$'
my_name DB 'Sorokin'
adrPSP dw 0                  ; ���� PSP
bufpar DB 128 DUP ('$')      ; ���� ��� ��ࠬ��஢
Counter DB 0                 ; ���稪 ���� ��ࠬ��஢
CounterPar db 0              ; ���稪 ��ࠬ��஢

START:
    ; ���樠������ ᥣ���⭮�� ॣ���� DS
    PUSH CS
    POP DS
    
    ; ����祭�� ���� PSP
    MOV AH, 51h
    INT 21H
    MOV adrPSP, BX           ; ���࠭塞 ���� PSP
    MOV ES, BX               ; ES 㪠�뢠�� �� PSP
    
    ; ����祭�� ����� ��ࠬ��஢
    MOV BX, 128              ; ���饭�� ����� ��ࠬ��஢ � PSP
    MOV BL, ES:[BX]          ; ��⠥� ����� ��ࠬ��஢
    MOV Counter, BL          ; ���࠭塞 ���稪
    
    ; �஢�ઠ ������ ��ࠬ��஢
    ;CMP BL, 00H
    ;JE FIN0                  ; �᫨ ��ࠬ��஢ ��� - �����蠥�
    
    ; �뢮� ᮮ�饭�� � �᫥ ���� ��ࠬ��஢
    MOV AH, 09h
    MOV DX, OFFSET msg1
    INT 21H
    
    ; �뢮� �᫠ ���� � HEX
    MOV DL, Counter
    CALL HEXPR
    CALL CRLF
    
    ; ����஢���� ��ࠬ��஢ � ����
    MOV SI, 0                ; ������ � ����
    MOV BX, 129              ; ��砫� ��ࠬ��஢ � PSP
    XOR CX, CX
    MOV CL, Counter          ; ���稪 ����
    
    ; ���� ����஢���� ��ࠬ��஢
savepar:
    MOV DL, ES:[BX]          ; ��⠥� ᨬ��� �� PSP
    MOV bufpar[SI], DL       ; ���࠭塞 � ����
    
    ; �஢�ઠ �� ࠧ����⥫� (�஡��)
    CMP DL, ' '
    JNE S2
    INC CounterPar           ; �����稢��� ���稪 ��ࠬ��஢
    ;jmp sec_task
S2:
    INC SI                   ; �������� ������ � ����
    INC BX                   ; ������騩 ᨬ��� � PSP
    LOOP savepar
    
    ; �����襭�� ��ப� ��ࠬ��஢
    MOV bufpar[SI], '$'
    
    ; �뢮� ��ࠬ��஢
    MOV DX, OFFSET msg_sec
    MOV AH, 09H
    INT 21H
    MOV DX, OFFSET bufpar
    INT 21H 
    CALL CRLF

first_task: 
    MOV DX, OFFSET msg_first
    MOV AH, 09H
    INT 21H
    lea si, my_name
    lea di, bufpar
    mov cx, 7     ; 8 ᫮�
    repe cmpsb     ; �ࠢ������ ᫮��
    je equal
    mov dl, 80h      ; �᫨ ��ப� �� ࠢ��
    jmp first_end
equal:
    mov dl, 81h      ; �᫨ ��ப� ࠢ��

first_end:
    call PUTC
    CALL CRLF

sec_task:
    ; �뢮� �᫠ ��ࠬ��஢
    MOV DX, OFFSET msg_sec
    MOV AH, 09H
    INT 21H
    cmp CounterPar, 2
    jne not_exist_sec
    mov dx, OFFSET msg_sec_true
    mov AH, 09H
    int 21H
    jmp sec_param_proc_end

not_exist_sec:
    mov dx, OFFSET msg_sec_false
    mov AH, 09H
    int 21H
    jmp sec_param_proc_end

sec_param_proc_end:
    call CRLF
    jmp FIN
    
; ��ࠡ�⪠ ������⢨� ��ࠬ��஢
FIN0:
    MOV DX, OFFSET msg4
    MOV AH, 09H
    INT 21H
    CALL CRLF
    
; �����襭�� �ணࠬ��
FIN:
    MOV AH, 4CH
    INT 21H

; ��楤�� �뢮�� ᨬ����
PUTC PROC
    MOV AH, 02
    INT 21H
    RET
PUTC ENDP

; ��楤�� ��ॢ��� ��ப�
CRLF PROC
    MOV DL, 10
    CALL PUTC
    MOV DL, 13
    CALL PUTC
    RET
CRLF ENDP

; ��楤�� �뢮�� �᫠ � HEX
HEXPR PROC
    MOV BX, OFFSET HEXTAB
    PUSH DX
    MOV AL, DL
    SHR AL, 4
    XLAT
    MOV DL, AL
    CALL PUTC
    POP DX
    MOV AL, DL
    AND AL, 0FH
    XLAT
    MOV DL, AL
    CALL PUTC
    MOV DL, 'H'
    CALL PUTC
    RET
HEXPR ENDP

MYCODE ENDS
END START