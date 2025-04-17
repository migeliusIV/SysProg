; ���⮢� �ਬ�� ��5 
;������� ������
DTSEG SEGMENT PARA 'DATA' 
; ��ࠢ��� ᮮ�饭�� ��� ���짮��⥫�. 
    MES0 DB "���ᨬ��쭮� ���-�� ᨬ����� � ��ப� - 20", 0Dh, 0Ah, '$' 
    MES1 DB "������ ����砭�� ����� ��ப� - `���� ������`", 0Dh, 0Ah, '$' 
    MES2 DB "���ᨬ��쭮� ���-�� ��ப - 10", 0Dh, 0Ah, '$' 
    MES3 DB "������ ����砭�� ����� ��ப - *", 0Dh, 0Ah, '$' 
    BUF_SYMBS DB 40 DUP(?)  ; �������� ���� ��� ��������� ��ப�. 
    HEX_TABLE DB '0123456789ABCDEF'  ; ������ ��४���஢�� ��� ��楤��� 
    BUF_CX DW ? ; ���� ��� ���稪� ���譥�� 横��. 
    ROW_SYMBS DW 40  ; ���ᨬ��쭮� ���-�� ᨬ����� � ����� ��ப�. 
    ROWS DW 10  ; ���ᨬ��쭮� ���-�� �������� ��ப. 
DTSEG ENDS

STSEG SEGMENT PARA 'STACK' 
    DB 200 DUP(0) 
STSEG ENDS 
; ������� ����
CDSEG SEGMENT PARA 'CODE' 
    ASSUME DS:DTSEG, SS:STSEG, CS:CDSEG 
; ������� ����
; �室 � �����ࠬ�� 
MAIN PROC 
    MOV AX, DTSEG 
    MOV DS, AX 
    ; �뢮� �ࠢ���� ᮮ�饭��. 
    MOV DX, OFFSET MES0 
    CALL PUTMES 
    MOV DX, OFFSET MES1 
    CALL PUTMES 
    MOV DX, OFFSET MES2 
    CALL PUTMES 
    MOV DX, OFFSET MES3 
    CALL PUTMES 
    CALL CLRF 
    MOV BX, OFFSET HEX_TABLE 
    MOV CX, ROWS  ; ���稪 ��� 横�� LOOP0. 
    ; ���� �� �������
    LOOP0: 
    ; ���� ����� ��ப. 
    MOV BUF_CX, CX 
    MOV CX, ROW_SYMBS  ; ���稪 ��� 横�� LOOP1. 
    MOV SI, 0  ; ���稪 ᨬ���쭮�� ����. 
    
LOOP1: 
; ���� ����� ����� ��ப�. 
    CALL GETCH  ; ���� ᨬ����. 
    ; �஢�ઠ ����砭�� ����� ��ப. 
    CMP AL, '*' 
    JE GO0 
    ; �஢�ઠ ����砭�� ����� ��ப�. 
    CMP AL, '$' 
    JE GO0 
    MOV BUF_SYMBS[SI], AL  ; ������ ��⠭���� ᨬ���� � ᨬ����� ����. 
    INC SI 
    LOOP LOOP1 
GO0: 
; 
; �஢�ઠ, �� ��ப� ����� ��� ���� ����筮� (������ ᨬ��� "*" 
    CMP SI, 0 
    JE GO1 
    ; ��뢮� ��ப� " = ". 
    CALL PUTSPACE 
    MOV DL, 3DH 
    ; �뢮� ᨬ���� �஡��� 
    CALL PUTCH 
    CALL PUTSPACE 
    MOV CX, SI  ; ���稪 ��� 横�� LOOP2 (ࠢ�� ���-�� ��������� ;ᨬ�����). 
    MOV SI, 0  ; ���稪 ᨬ���쭮�� ����. 

;���� �⥭�� � �८�ࠧ������ 
LOOP2: 
    ; ���� �८�ࠧ������ ᨬ����� �������� ��ப�. 
    MOV AL, BUF_SYMBS[SI]  ; �⥭�� ᨬ���� �� ᨬ���쭮�� ����. 
    INC SI 
    CALL HEX  ; ��४���஢�� � �����
    ;�஡�� 
    CALL PUTSPACE 
    ; ����� 横�� �뢮�� �� ����
    LOOP LOOP2 

GO1: 
    ; �஢�ઠ, �� ��������� ��ப� ���� ����筮�. 
    CMP AL, '*' 
    JE END_PROG 
    
    CALL CLRF 
    ; ��� 横�� ����� ��ப� 
    MOV CX, BUF_CX 
    ; ����� 欪�� ����� ��ப
    LOOP LOOP0 
    
END_PROG: 
    ; �����襭�� ࠡ��� �ணࠬ��. 
    
    MOV AH, 4CH 
    INT 21H 
MAIN ENDP 
;��������� ���������
PUTCH PROC 
    ; ��楤�� �뢮�� ᨬ����. 
    MOV AH, 02H 
    INT 21H 
    RET 
PUTCH ENDP 

PUTSPACE PROC 
    ; ��楤�� �뢮�� �஡���. 
    MOV DL, 20H 
    MOV AH, 02H 
    INT 21H 
    RET 
PUTSPACE ENDP 

PUTMES PROC 
    ; ��楤�� �뢮�� ⥪�⮢��� ᮮ�饭��. 
    MOV AH, 09H 
    INT 21H 
    RET 
PUTMES ENDP 

CLRF PROC 
    ; ��楤�� ��ॢ��� ��ப� � ������ ���⪨. 
    MOV AH, 02H 
    MOV DL, 0AH 
    INT 21H 
    MOV DL, 0DH 
    INT 21H 
    RET 
CLRF ENDP 

GETCH PROC 
    ; ��楤�� ����� ᨬ����. 
    MOV AH, 01H 
    INT 21H 
    RET 
GETCH ENDP 

HEX PROC 
    ; ��楤�� ��४���஢�� 
    PUSH AX 
    ; ����砥� ���祭�� ���襣� ���㡠��. 
    MOV DL, AL 
    SHR DL, 4 
    MOV AL, DL 
    XLAT 
    ; �뢮��� ���祭�� ���襣� ���㡠��. 
    MOV DL, AL 
    CALL PUTCH 
    ; ����砥� ���祭�� ����襣� ���㡠��. 
    POP AX 
    MOV DL, AL 
    SHL DL, 4 
    SHR DL, 4 
    MOV AL, DL 
    XLAT 
    ; �뢮��� ���祭�� ����襣� ���㡠��. 
    MOV DL, AL 
    CALL PUTCH 
    RET 
HEX ENDP  

CDSEG ENDS 
 
END MAIN