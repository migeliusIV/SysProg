TITLE  �ணࠬ�� ������୮� ࠡ��� 5
; ����: ��.48�

DATASG SEGMENT 'DATA'
    TABLHEX DB '0123456789ABCDEF'  ; ������ ��� HEX-�८�ࠧ������
    MSG DB '������ ��⭠����筮� �᫮(HHHH, * - ����� �ணࠬ��):$'
    MSGI DB '�뢮� ��᫥ ����� 4-� ��⭠��. ���: <HHHH>=<HHHH> <DDDDD>$'
    BUF    DB  100 DUP(0)         ; ���� ��� �����
    DECW   DW  0                  ; ��६����� ��� �����筮�� ���祭��
    MSGERR DB '�訡�� ᨬ����!$'  ; ����饭�� �� �訡��
DATASG ENDS

STSEG SEGMENT STACK 'STACK'
    DW 256 DUP(0)                ; �⥪ 256 ᫮�
STSEG ENDS

MYCODE SEGMENT 'CODE'
    ASSUME CS:MYCODE, DS:DATASG, SS:STSEG
    
START:
    ; ���樠������ ᥣ������ ॣ���஢
    MOV AX, DATASG
    MOV DS, AX
    
    ; ���⪠ �࠭�
    MOV AH, 00H
    MOV AL, 03H
    INT 10H
    
    ; �뢮� �ਣ��襭�� ��� �����
    MOV AH, 9H
    LEA DX, MSG
    INT 21h
    CALL LFCR
    
    ; �뢮� �ଠ� १����
    MOV AH,09H
    LEA DX, MSGI
    INT 21H
    CALL LFCR 

    ; �᭮���� 横� �ணࠬ�� (10 ���権)
    MOV CX, 10
METLOOP:
    ; ���� HEX-�᫠
    CALL HEXADR
    
    ; �뢮� ࠧ����⥫��
    MOV DL, ' '
    CALL PUTCH
    MOV DL, '='
    CALL PUTCH
    MOV DL, ' '
    CALL PUTCH
    
    ; �뢮� HEX-�᫠
    CALL PRINTHEX
    MOV DL, ' '
    CALL PUTCH
    MOV DL, ' '
    CALL PUTCH
    
    ; �८�ࠧ������ � �뢮� � �����筮� �ଠ�
    CALL DECPRINT
    
    ; ���室 �� ����� ��ப�
    CALL LFCR
    LOOP METLOOP

MEND:
    ; ���⪠ �࠭� ��। �����襭���
    MOV AH, 00H
    MOV AL, 03H
    INT 10H

    ; �����襭�� �ணࠬ��
    MOV AH, 4Ch
    MOV AL, 0
    INT 21H

; ��楤�� ����� HEX-�᫠
HEXADR PROC
    ; �����⮢�� 横�� ����� (4 ᨬ����)
    MOV SI, OFFSET BUF
    MOV CX, 4
    
MVVOD:
    CALL GETSIMB
    CMP AL, '*'          ; �஢�ઠ �� �����襭��
    JE MEND
    
    ; �஢�ઠ �� �����⨬� HEX-ᨬ���
    CMP AL, '0'
    JB ERROR
    CMP AL, '9'
    JBE MBUF             ; ���� 0-9
    CMP AL, 'A'
    JB ERROR
    CMP AL, 'F'
    JBE MBUF             ; �㪢� A-F
    CMP AL, 'a'
    JB ERROR
    CMP AL, 'f'
    JA ERROR
    
MBUF:
    ; ���࠭���� ᨬ���� � ���� � �뢮�
    MOV [SI], AL
    INC SI
    MOV DL, AL
    CALL PUTCH
    LOOP MVVOD
    
    ; �����襭�� ��ப�
    MOV BYTE PTR [SI], '$'
    RET
    
ERROR:
    ; ��ࠡ�⪠ �訡�� �����
    MOV AL,'#'
    MOV DX, OFFSET MSGERR
    MOV AH, 09H
    INT 21H
    CALL GETSIMB
    JMP MEND 
HEXADR ENDP

; ��楤�� �뢮�� HEX-�᫠
PRINTHEX PROC
    MOV DX, OFFSET BUF
    MOV AH, 09H
    INT 21h
    RET
PRINTHEX ENDP

; ��楤�� �८�ࠧ������ ᨬ���� � �᫮
SIMPER PROC
    CMP AL, '9'
    JG MS1
    SUB AL, '0'       ; ���� 0-9
    JMP MSE
MS1:
    CMP AL, 'F'
    JG MS2
    SUB AL, 'A'-10    ; �㪢� A-F
    JMP MSE
MS2:
    SUB AL, 'a'-10    ; �㪢� a-f
MSE:
    RET
SIMPER ENDP

; ��楤�� �८�ࠧ������ � �뢮�� � �����筮� �ଠ�
DECPRINT PROC
    ; �८�ࠧ������ � ��設��� �।�⠢�����
    MOV SI, OFFSET BUF
    MOV BX, 4096       ; ��� ���襣� ࠧ�鸞 (16^3)
    MOV DECW, 0
    MOV CX, 4
    
CPER:
    MOV AL, [SI]
    CALL SIMPER        ; �८�ࠧ������ ᨬ���� � �᫮
    MOV AH, 0
    MUL BX             ; ��������� �� ��� ࠧ�鸞
    MOV DX, DECW
    ADD DX, AX         ; �㬬�஢���� १���⮢
    MOV DECW, DX
    SHR BX, 4          ; ���室 � ᫥���饬� ࠧ���
    INC SI
    LOOP CPER
    
    ; �८�ࠧ������ � �����筮� �।�⠢�����
    MOV CX, 5          ; ���ᨬ� 5 �������� ���
    MOV BX, 10000      ; ��稭��� � 10000
    
MDEC:
    MOV AX, DECW
    MOV DX, 0
    DIV BX             ; �뤥�塞 ����
    MOV DECW, DX       ; ���⮪ ��� ᫥����� ࠧ�冷�
    ADD AL, '0'        ; �८�ࠧ������ � ᨬ���
    MOV DL, AL
    CALL PUTCH         ; �뢮� ����
    
    ; �����蠥� ����⥫� � 10 ࠧ
    MOV AX, BX
    MOV DX, 0
    MOV BX, 10
    DIV BX
    MOV BX, AX
    LOOP MDEC
    
    RET
DECPRINT ENDP

; ��楤�� �뢮�� ᨬ���� (DL)
PUTCH PROC
    MOV AH, 2
    INT 21H
    RET
PUTCH ENDP

; ��楤�� ��ॢ��� ��ப�
LFCR PROC
    MOV DL, 10
    CALL PUTCH
    MOV DL, 13
    CALL PUTCH
    RET
LFCR ENDP

; ��楤�� ����� ᨬ���� (१���� � AL)
GETSIMB PROC
    MOV AH, 08H
    INT 21H
    RET
GETSIMB ENDP

MYCODE ENDS
END START