;.MODEL LARGE, C 
; ������� ������
DTSEG SEGMENT PARA 'DATA' 
    ; ��ࠢ��� ᮮ�饭�� ��� ���짮��⥫�
    msg_menu db "==����==", 0Dh, 0Ah, 
                db "1 - ��5", 0Dh, 0Ah, 
                db "2 - ��� �������", 0Dh, 0Ah, 
                db "3 - �������� �ணࠬ��", 0Dh, 0Ah,'$'
    msg_menu_error db "������ ������ ᨬ���...", 0Dh, 0Ah,'$'
    msg_apndx db "������ ���祭�� � ᠭ⨬��� = $"
    msg_apndx_res db "���祭�� � ��� = $"
    MES0 DB "���ᨬ��쭮� ���-�� ᨬ����� � ��ப� - 20", 0Dh, 0Ah, '$' 
    MES1 DB "������ ����砭�� ����� ��ப� - `���� ������`", 0Dh, 0Ah, '$' 
    MES2 DB "���ᨬ��쭮� ���-�� ��ப - 10", 0Dh, 0Ah, '$' 
    MES3 DB "������ ����砭�� ����� ��ப - *", 0Dh, 0Ah, '$' 
    BUF_SYMBS DB 40 DUP(?)          ; ���� ��� ��������� ��ப�
    HEX_TABLE DB '0123456789ABCDEF' ; ������ ��४���஢��
    BUF_CX DW ?                     ; ���� ��� ���稪� 横��
    ROW_SYMBS DW 40                 ; ����. ᨬ����� � ��ப�
    ROWS DW 10                      ; ����. ������⢮ ��ப
DTSEG ENDS

STSEG SEGMENT PARA 'STACK' 
    DB 200 DUP(0) 
STSEG ENDS 


;PUBLIC _CALCULATE

CDSEG SEGMENT PARA 'CODE' 
    ASSUME DS:DTSEG, SS:STSEG, CS:CDSEG 
    EXTRN _calculate:NEAR  ; �������㥬 �㭪�� �� C++
MAIN PROC 
    ; ���樠������ ᥣ���� ������ � ����
    mov AX, DTSEG 
    mov DS, AX 

    ;--- ����
    ; 1 - ����� 5 ��
    ; 2 - ����� ����
    ; 3 - ��ࢠ�� �ணࠬ��
    ;;;;;;;;;;;;;;;;
menu:
    call CLRF
    call CLRSCR
    mov DX, OFFSET msg_menu
    call PUTMES
    call GETCHECHO
    cmp al, '1'
    je lab5
    cmp al, '2'
    je appendix
    cmp al, '3'
    db 0Fh, 84h             ; ��� ����樨 ��� JE near (������)
    dw offset END_PROG - ($ + 2)  ; 16-��⭮� ᬥ饭��
    call CLRF
    mov DX, OFFSET msg_menu_error
    call PUTMES
    call GETCH
    jmp menu

appendix:
    call _calculate  
    db 0Fh, 84h             ; ��� ����樨 ��� JE near (������)
    dw offset END_PROG - ($ + 2)  ; 16-��⭮� ᬥ饭��

lab5:
    call CLRF
    call CLRSCR
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
        mov dl, al
        cmp al, '$'
        je GO0
        cmp al, '*' 
        jne not_sys
        cmp si, 0
        je GO1
        
    not_sys:
        call PUTCH
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

CLRSCR proc near ; ��楤�� ���⪨ �࠭�
    mov ax, 0600h
    mov bh, 07h
    mov cx, 0000h
    mov dx, 184Fh
    int 10h
    ret
CLRSCR endp

GETCH PROC 
    mov AH, 07h ; �뢮� ��� ��
    int 21h 
    ret 
GETCH ENDP 

GETCHECHO PROC 
    mov AH, 01h 
    int 21h 
    ret 
GETCHECHO ENDP 

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

OUTPUT PROC near
    pop ax
    
    ret 
OUTPUT ENDP 

CDSEG ENDS 
END MAIN