.MODEL small
.STACK 100h

.DATA
  prompt_cm  DB '������ ���祭�� � ᠭ⨬����: $'
  prompt_inch DB '���祭�� � ���: $'
  newline    DB 13, 10, '$'
  buffer     DB 10 DUP('$') ; ���� ��� ����� ᠭ⨬��஢ (9 ��� + Enter)
  cm         DW 0         ; ���⨬���� (楫�� �᫮)
  inches     DW 0        ; �� (楫�� �᫮)
  fraction   DW 0      ; ��⠢���� �஡��� ���� (��� ����� �筮�� �뢮��)

  divisor    DW 254        ; ����⥫� ��� �८�ࠧ������ (2.54 * 100)

  err_msg  DB '�訡�� �����! ������ 楫�� �᫮.$'

.CODE
  MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; �뢮� �ਣ��襭�� ��� ����� ᠭ⨬��஢
    MOV AH, 09h
    LEA DX, prompt_cm
    INT 21h

    ; ���� ᠭ⨬��஢
    CALL read_number
    call CLRF
    ; �஢�ઠ �� �訡�� �����
    CMP AX, -1
    db 0Fh, 84h                   ; ��� ����樨 ��� JE near (������)
    dw offset handle_input_error - ($ + 2)  ; 16-��⭮� ᬥ饭��
    ;JE handle_input_error

    MOV cm, AX      ; ���࠭塞 ���祭�� ᠭ⨬��஢

    ; �८�ࠧ������ ᠭ⨬��஢ � ��
    CALL convert_cm_to_inches

    ; �뢮� ���
    CALL print_inches

    ; �����襭�� �ணࠬ��
    MOV AH, 4Ch
    INT 21h

  MAIN ENDP

;-----------------------------------------------------------------------------
; read_number - ��⠥� �᫮ � ���������� � �����頥� ��� � AX.
;               �����頥� -1 � AX, �᫨ �ந��諠 �訡�� �����.
;-----------------------------------------------------------------------------
read_number PROC
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    ; �⥭�� ��ப�
    MOV AH, 0Ah
    LEA DX, buffer
    MOV buffer+0, 9 ; ���ᨬ��쭠� ����� �����
    INT 21h

    ; �८�ࠧ������ ��ப� � �᫮
    LEA SI, buffer+2 ; ����뢠�� �� ��砫� ��������� ��ப�
    MOV AX, 0      ; ���樠�����㥬 �᫮
    MOV CX, 0       ; ���� �訡�� (0 - ��� �訡��, 1 - �訡��)

convert_loop:
    MOV BL, [SI]
    CMP BL, 13      ; �஢�ઠ �� Enter
    JE conversion_done

    SUB BL, '0'     ; �८�ࠧ㥬 ᨬ��� � �᫮
    CMP BL, 0
    JL number_input_error  ; �᫨ ᨬ��� ����� '0', � �訡��
    CMP BL, 9
    JG number_input_error  ; �᫨ ᨬ��� ����� '9', � �訡��

    MOV DX, 0       ; DX ������ ���� 0 ��। 㬭�������
    MOV BX, 10
    MUL BX          ; �������� AX �� 10
    JO number_input_error   ; ��९�������
    ADD AL, BL      ; ������塞 ����� ����
    JO number_input_error  ; ��९�������
    INC SI          ; ���室�� � ᫥���饬� ᨬ����
    JMP convert_loop

conversion_done:
    JMP number_cleanup

number_input_error:
    MOV AX, -1      ; �����頥� -1, �᫨ �ந��諠 �訡�� �����

number_cleanup:
    POP SI
    POP DX
    POP CX
    POP BX
    RET
read_number ENDP

;-----------------------------------------------------------------------------
; convert_cm_to_inches - �८�ࠧ�� ᠭ⨬���� (cm) � ��.
;                         cm - ���祭�� � ᠭ⨬���� (� ��६����� cm)
;                         inches - ���祭�� � ��� (� ��६����� inches)
;-----------------------------------------------------------------------------
convert_cm_to_inches PROC
    PUSH AX
    PUSH DX

    MOV AX, cm     ; ����㦠�� ᠭ⨬���� � AX
    MOV DX, 0      ; ����塞 DX (��� �������)
    MOV BX, divisor     ; ����㦠�� ����⥫� (254)
    DIV BX          ; AX = 楫�� ���� ���, DX = ���⮪

    MOV inches, AX    ; ���࠭塞 楫�� ���� ���
    MOV fraction, DX  ; ���࠭塞 �஡��� ����

    POP DX
    POP AX
    RET
convert_cm_to_inches ENDP


CLRF PROC 
    mov DL, 0Ah 
    call PUTCH 
    mov DL, 0Dh 
    call PUTCH 
    ret 
CLRF ENDP


;-----------------------------------------------------------------------------
; print_inches - �뢮��� ���祭�� ��� �� �࠭.
;-----------------------------------------------------------------------------
print_inches PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    ; �뢮� �ਣ��襭�� ��� �뢮�� ���
    MOV AH, 09h
    LEA DX, prompt_inch
    INT 21h

    ; �८�ࠧ������ 楫�� ��� ��� � ��ப�
    MOV AX, inches    ; ����㦠�� 楫�� ���� ���
    LEA DI, buffer + 9  ; ����뢠�� �� ����� ���� (��� �ନ஢���� ��ப� � ���⭮� ���浪�)
    MOV BYTE PTR [DI], '$' ; �����蠥� ��ப� ᨬ����� '$'
    DEC DI

to_string_loop:
    MOV DX, 0       ; DX ������ ���� 0 ��। ��������
    MOV BX, 10
    DIV BX          ; AX = ��⭮�, DX = ���⮪

    ADD DL, '0'     ; �८�ࠧ㥬 ���� � ᨬ���
    MOV [DI], DL    ; ���࠭塞 ᨬ��� � ����
    DEC DI          ; ���室�� � ᫥���饬� ᨬ����
    CMP AX, 0       ; �஢�ઠ, �᫨ ��⭮� ࠢ�� 0
    JNE to_string_loop

    ; �뢮� ��ப� � ����
    MOV AH, 09h
    INC DI          ; ����뢠�� �� ��砫� ��ப�
    MOV DX, DI
    INT 21h
    MOV AH, 09h
        LEA DX, newline
        INT 21h

print_cleanup:
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
print_inches ENDP

;-----------------------------------------------------------------------------
; handle_input_error - �뢮��� ᮮ�饭�� �� �訡�� �����.
;-----------------------------------------------------------------------------
handle_input_error PROC
    MOV AH, 09h
    LEA DX, err_msg
    INT 21h
    MOV AH, 09h
        LEA DX, newline
        INT 21h
    RET
handle_input_error ENDP

END MAIN