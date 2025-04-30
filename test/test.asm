data segment
    msg_prompt db '������ �᫮$'
    msg_in_error db '�訡��! ������ ���ࠢ���� ᨬ���! $'
    msg_stat db '�ᯥ�! ������� �᫮ = $'
    int_input dd 12
    post db 0 ; ������⢮ �ᥫ ��᫥ ����⮩
    flg db 0 ; 0 - int, 1 - float
data ends

stack segment
    ? db 200 DUP(0) ; dup - ����⨯�� �����
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
    mov dh, al  ; ��७�� � ���孨� ���ॣ����  
    pop ax      ; �, �� �०�� �������
    sub dh, '0' ; ��ॢ�� �� ASCII � �᫮
    add ah, dh  ; �㬬�஢���� ��ண� � ������ �᫠ 
    mov bl, 10  ; 
    mul bl      ; 㬭������ १���� �� 10
    push ax     ; ��࠭���� �஬����筮�� १����

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
    mov dl, al  ; ��७�� � ���孨� ���ॣ����  
    pop ax      ; �, �� �०�� �������
    sub dl, '0' ; ��ॢ�� �� ASCII � �᫮
    add al, dl  ; �㬬�஢���� ��ண� � ������ �᫠ 
    mov bl, 10  ; 
    mul bl      ; 㬭������ १���� �� 10
    push ax     ; ��࠭���� �஬����筮�� १����

    ; process
    cmp flg, 1
    je fraction_proc
int_proc:
    mov ax, ax ; ����塞 ax
    pop ax     ; ����
    mov bl, 5
    mul bl
    mul bl, 2
    div bl
    ; ...
    call print

fraction_proc:
    mov ax, ax ; ����塞 ax
    pop ax     ; ���뢠�� �஡��� ����
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

;---- �ᯮ����⥫�� ��楤��� ----
digitOut proc
while:
    cmp ax, 9
    ;j
    call putch
    ret
digitOut endp

putch proc
    mov AH, 02h ; ��� AL
    int 21h
    ret
putch endp

PUTMES PROC ; ��楤�� �뢮�� ���ᨢ�
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

CLRSCR proc near ; ��楤�� ���⪨ �࠭�
    mov ax, 0600h
    mov bh, 07h
    mov cx, 0000h
    mov dx, 184Fh
    int 10h
    ret
CLRSCR endp
code ends
end main 
; ����� �� ��࠭��� �� �⥪ �맮��� (?) ����⠭�� ���� ᥣ���⮬ ����.
; �.�. ����� �� �������� ��� ����� �ணࠬ�� �� ����� ᥣ���� ������.