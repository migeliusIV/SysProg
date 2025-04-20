; �ਬ�� �ணࠬ�� ��5
; ������� ������
DTSEG SEGMENT PARA 'DATA' 
    ; ��ࠢ��� ᮮ�饭�� ��� ���짮��⥫�
    MES0 DB "���ᨬ��쭮� ���-�� ᨬ����� � ��ப� - 20", 0Dh, 0Ah, '$' 
    MES1 DB "������ ����砭�� ����� ��ப� - `���� ������`", 0Dh, 0Ah, '$' 
    MES2 DB "���ᨬ��쭮� ���-�� ��ப - 10", 0Dh, 0Ah, '$' 
    MES3 DB "������ ����砭�� ����� ��ப - *", 0Dh, 0Ah, '$' 
    BUF_SYMBS DB 40 DUP(?)  ; ���� ��� ��������� ��ப�
    HEX_TABLE DB '0123456789ABCDEF'  ; ������ ��४���஢��
    BUF_CX DW ?  ; ���� ��� ���稪� 横��
    ROW_SYMBS DW 40  ; ����. ᨬ����� � ��ப�
    ROWS DW 10  ; ����. ������⢮ ��ப
DTSEG ENDS

STSEG SEGMENT PARA 'STACK' 
    DB 200 DUP(0) 
STSEG ENDS 

CDSEG SEGMENT PARA 'CODE' 
    ASSUME DS:DTSEG, SS:STSEG, CS:CDSEG 

MAIN PROC 
    ; ���樠������ ᥣ���� ������ � ����
    mov AX, DTSEG 
    mov DS, AX 
    ; �뢮� �ࠢ���� ᮮ�饭��
    mov DX, OFFSET MES0 
    call PUTMES 
    mov DX, OFFSET MES1 
    call PUTMES 
    mov DX, OFFSET MES2 
    call PUTMES 
    mov DX, OFFSET MES3 
    call PUTMES 
    call CLRF 

    mov BX, OFFSET HEX_TABLE 
    mov CX, ROWS  ; ���稪 ��� 横�� LOOP0
    ; ���� �� �������
    LOOP0: 
    ; ���� ��ப�
    mov BUF_CX, CX 
    mov CX, ROW_SYMBS  ; ���稪 ��� LOOP1
    mov SI, 0  ; ������ ����
    
    LOOP1: 
        call GETCH  ; ���� ᨬ����
        cmp AL, '*' 
        JE GO0 
        cmp AL, '$' 
        JE GO0 
        mov BUF_SYMBS[SI], AL  ; ������ � ����
        inc SI 
        LOOP LOOP1 
    GO0: 
    ; �஢�ઠ �� ������ ��ப�
    cmp SI, 0 
    JE GO1 

    ; �뢮� " = "
    call PUTSPACE 
    mov DL, '=' 
    call PUTCH 
    call PUTSPACE 

    mov CX, SI  ; ����� ��ப� (�㦨� ������ 横��)
    mov SI, 0 
    ; �८�ࠧ������ � HEX
    LOOP2: 
        mov AL, BUF_SYMBS[SI] 
        inc SI 
        call HEX 
        call PUTSPACE 
        LOOP LOOP2 
    GO1: 
    ; �஢�ઠ �� ����� �����
    cmp AL, '*' 
    JE END_PROG 
    call CLRF 
    mov CX, BUF_CX 
    LOOP LOOP0 
    
    END_PROG: 
    mov AH, 4Ch 
    int 21h 
MAIN ENDP 

; ��楤���
PUTCH PROC ; ��楤�� �뢮�� ᨬ����
    mov AH, 02h 
    int 21h 
    ret 
PUTCH ENDP 

PUTSPACE PROC 
    mov DL, ' ' 
    mov AH, 02h 
    int 21h 
    ret 
PUTSPACE ENDP 

PUTMES PROC ; ��楤�� �뢮�� ���ᨢ�
    mov AH, 09h 
    int 21h 
    ret 
PUTMES ENDP 

CLRF PROC 
    mov DL, 0Ah 
    call PUTCH 
    mov DL, 0Dh 
    call PUTCH 
    ret 
CLRF ENDP 

GETCH PROC 
    mov AH, 01h 
    int 21h 
    ret 
GETCH ENDP 

HEX PROC 
    push AX 
    mov DL, AL 
    SHR DL, 4 
    mov AL, DL 
    XLAT 
    mov DL, AL 
    call PUTCH 
    pop AX 
    mov DL, AL 
    AND DL, 0Fh 
    mov AL, DL 
    XLAT 
    mov DL, AL 
    call PUTCH 
    ret 
HEX ENDP  

CDSEG ENDS 
END MAIN