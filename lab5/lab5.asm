; ’Ґбв®ўл© ЇаЁ¬Ґа ‹ђ5 
;‘…ѓЊ…Ќ’ „ЂЌЌ›•
DTSEG SEGMENT PARA 'DATA' 
; ‘Їа ў®з­лҐ б®®ЎйҐ­Ёп ¤«п Ї®«м§®ў вҐ«п. 
    MES0 DB "Њ ЄбЁ¬ «м­®Ґ Є®«-ў® бЁ¬ў®«®ў ў бва®ЄҐ - 20", 0Dh, 0Ah, '$' 
    MES1 DB "‘Ё¬ў®« ®Є®­з ­ЁҐ ўў®¤  бва®ЄЁ - `§­ Є ¤®«« а `", 0Dh, 0Ah, '$' 
    MES2 DB "Њ ЄбЁ¬ «м­®Ґ Є®«-ў® бва®Є - 10", 0Dh, 0Ah, '$' 
    MES3 DB "‘Ё¬ў®« ®Є®­з ­Ёп ўў®¤  бва®Є - *", 0Dh, 0Ah, '$' 
    BUF_SYMBS DB 40 DUP(?)  ; ‘Ё¬ў®«м­л© ЎгдҐа ¤«п ўўҐ¤Ґ­­®© бва®ЄЁ. 
    HEX_TABLE DB '0123456789ABCDEF'  ; ’ Ў«Ёж  ЇҐаҐЄ®¤Ёа®ўЄЁ ¤«п Їа®жҐ¤гал 
    BUF_CX DW ? ; ЃгдҐа ¤«п бзҐвзЁЄ  ў­Ґи­ҐЈ® жЁЄ« . 
    ROW_SYMBS DW 40  ; Њ ЄбЁ¬ «м­®Ґ Є®«-ў® бЁ¬ў®«®ў ў ®¤­®© бва®ЄҐ. 
    ROWS DW 10  ; Њ ЄбЁ¬ «м­®Ґ Є®«-ў® ўў®¤Ё¬ле бва®Є. 
DTSEG ENDS

STSEG SEGMENT PARA 'STACK' 
    DB 200 DUP(0) 
STSEG ENDS 
; ‘…ѓЊ…Ќ’ ЉЋ„Ђ
CDSEG SEGMENT PARA 'CODE' 
    ASSUME DS:DTSEG, SS:STSEG, CS:CDSEG 
; ‘…ѓЊ…Ќ’ ЉЋ„Ђ
; ‚е®¤ ў Їа‘®Ја ¬¬г 
MAIN PROC 
    MOV AX, DTSEG 
    MOV DS, AX 
    ; ‚лў®¤ бЇа ў®з­ле б®®ЎйҐ­Ё©. 
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
    MOV CX, ROWS  ; ‘зҐвзЁЄ ¤«п жЁЄ«  LOOP0. 
    ; –€Љ‹ ЏЋ ‘’ђЋЉЂЊ
    LOOP0: 
    ; –ЁЄ« ўў®¤  бва®Є. 
    MOV BUF_CX, CX 
    MOV CX, ROW_SYMBS  ; ‘зҐвзЁЄ ¤«п жЁЄ«  LOOP1. 
    MOV SI, 0  ; ‘зҐвзЁЄ бЁ¬ў®«м­®Ј® ЎгдҐа . 
    
LOOP1: 
; –ЁЄ« ўў®¤  ®¤­®© бва®ЄЁ. 
    CALL GETCH  ; ‚ў®¤ бЁ¬ў®« . 
    ; Џа®ўҐаЄ  ®Є®­з ­Ёп ўў®¤  бва®Є. 
    CMP AL, '*' 
    JE GO0 
    ; Џа®ўҐаЄ  ®Є®­з ­Ёп ўў®¤  бва®ЄЁ. 
    CMP AL, '$' 
    JE GO0 
    MOV BUF_SYMBS[SI], AL  ; ‡ ЇЁбм бзЁв ­­®Ј® бЁ¬ў®«  ў бЁ¬ў®«м­л© ЎгдҐа. 
    INC SI 
    LOOP LOOP1 
GO0: 
; 
; Џа®ўҐаЄ , зв® бва®Є  Їгбв п Ё«Ё пў«пҐвбп Є®­Ґз­®© (ўўҐ¤Ґ­ бЁ¬ў®« "*" 
    CMP SI, 0 
    JE GO1 
    ; ‚ўлў®¤ бва®ЄЁ " = ". 
    CALL PUTSPACE 
    MOV DL, 3DH 
    ; ўлў®¤ бЁ¬ў®«  Їа®ЎҐ«  
    CALL PUTCH 
    CALL PUTSPACE 
    MOV CX, SI  ; ‘зҐвзЁЄ ¤«п жЁЄ«  LOOP2 (а ўҐ­ Є®«-ў® ўўҐ¤Ґ­­ле ;бЁ¬ў®«®ў). 
    MOV SI, 0  ; ‘зҐвзЁЄ бЁ¬ў®«м­®Ј® ЎгдҐа . 

;–€Љ‹ звҐ­Ёп Ё ЇаҐ®Ўа §®ў ­Ёп 
LOOP2: 
    ; –ЁЄ« ЇаҐ®Ўа §®ў ­Ёп бЁ¬ў®«®ў ўўҐ¤Ґ­®© бва®ЄЁ. 
    MOV AL, BUF_SYMBS[SI]  ; —вҐ­ЁҐ бЁ¬ў®«  Ё§ бЁ¬ў®«м­®Ј® ЎгдҐа . 
    INC SI 
    CALL HEX  ; ЏҐаҐЄ®¤Ёа®ўЄ  Ё ЇҐз вм
    ;Џа®ЎҐ« 
    CALL PUTSPACE 
    ; Љ®­Ґж жЁЄ«  ўлў®¤  Ё§ ЎгдҐа 
    LOOP LOOP2 

GO1: 
    ; Џа®ўҐаЄ , зв® ўўҐ¤Ґ­­ п бва®Є  пў«пҐвбп Є®­Ґз­®©. 
    CMP AL, '*' 
    JE END_PROG 
    
    CALL CLRF 
    ; ¤«п жЁЄ«  ўў®¤  бва®ЄЁ 
    MOV CX, BUF_CX 
    ; Љ®­Ґж ж¬Є«  ўў®¤  бва®Є
    LOOP LOOP0 
    
END_PROG: 
    ; ‡ ўҐаиҐ­ЁҐ а Ў®вл Їа®Ја ¬¬л. 
    
    MOV AH, 4CH 
    INT 21H 
MAIN ENDP 
;ЏђЋ–…„“ђ› ЏђЋѓђЂЊЊ›
PUTCH PROC 
    ; Џа®жҐ¤га  ўлў®¤  бЁ¬ў®« . 
    MOV AH, 02H 
    INT 21H 
    RET 
PUTCH ENDP 

PUTSPACE PROC 
    ; Џа®жҐ¤га  ўлў®¤  Їа®ЎҐ« . 
    MOV DL, 20H 
    MOV AH, 02H 
    INT 21H 
    RET 
PUTSPACE ENDP 

PUTMES PROC 
    ; Џа®жҐ¤га  ўлў®¤  вҐЄбв®ў®Ј® б®®ЎйҐ­Ёп. 
    MOV AH, 09H 
    INT 21H 
    RET 
PUTMES ENDP 

CLRF PROC 
    ; Џа®жҐ¤га  ЇҐаҐў®¤  бва®ЄЁ Ё ў®§ўа в  Є аҐвЄЁ. 
    MOV AH, 02H 
    MOV DL, 0AH 
    INT 21H 
    MOV DL, 0DH 
    INT 21H 
    RET 
CLRF ENDP 

GETCH PROC 
    ; Џа®жҐ¤га  ўў®¤  бЁ¬ў®« . 
    MOV AH, 01H 
    INT 21H 
    RET 
GETCH ENDP 

HEX PROC 
    ; Џа®жҐ¤га  ЇҐаҐЄ ¤Ёа®ўЄЁ 
    PUSH AX 
    ; Џ®«гз Ґ¬ §­ зҐ­ЁҐ бв аиҐЈ® Ї®«гЎ ©в . 
    MOV DL, AL 
    SHR DL, 4 
    MOV AL, DL 
    XLAT 
    ; ‚лў®¤Ё¬ §­ зҐ­ЁҐ бв аиҐЈ® Ї®«гЎ ©в . 
    MOV DL, AL 
    CALL PUTCH 
    ; Џ®«гз Ґ¬ §­ зҐ­ЁҐ ¬« ¤иҐЈ® Ї®«гЎ ©в . 
    POP AX 
    MOV DL, AL 
    SHL DL, 4 
    SHR DL, 4 
    MOV AL, DL 
    XLAT 
    ; ‚лў®¤Ё¬ §­ зҐ­ЁҐ ¬« ¤иҐЈ® Ї®«гЎ ©в . 
    MOV DL, AL 
    CALL PUTCH 
    RET 
HEX ENDP  

CDSEG ENDS 
 
END MAIN