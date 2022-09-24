.model small
.data

nameFile db 100 dup('$')
nameFileKrp db 100 dup('$')
txt db ".txt", 0
krp db ".krp", 0
lenght dw 0
Handle DW ?             ; para guardar o manipulador do arquivo
OpenError DB "Ocorreu um erro (abrindo)!$"
ReadError DB "Ocorreu um erro (lendo)!$"

messageGetFile DB 'INSIRA O NOME DO ARQUIVO DE LEITURA: ', '$'
messageGetCripto DB 'INSIRA O TEXTO A SER CRIPTOGRAFADO: ', '$'
messageNameFile DB 'INPUT: ','$'
messageNameFileKrp DB 'OUTPUT: ','$'
messageTest DB 'aconteceu algo','$'
menTeste DB 'teste 123', '$'

alBuffer DW 0

stringCripto db 100 dup('$')
caractereTxt db 0

caractereKrp db 0
filename db "aarquivo.krp",0
handler dw ?

BytesLidos  DW 0                ; Bytes lidos do arquivo
Buffer      DB 4096 dup (?)     ; buffer para armazenar dados
indexTxt dw 0
FimBuffer   DW $-Buffer         ; Endereço do fim do buffer

.code
main proc
    mov ax,@data
    mov ds,ax

;--- mensagem de leitura ---;
    lea dx, messageGetCripto ; load address of the string  
    mov ah, 09H ;output the string
    int 21H

;--- pega a string q sera criptografada ---;
    mov bl, 0
    mov si, offset stringCripto ; si point the array
getNameCripto:
    mov ah, 1
    int 21h
    cmp al, 13
    je continua
    mov [si], al    ; armazena
    inc si          ; incrementa index 
    jmp getNameCripto

continua:    
;--- quebra linha ---;
    mov ah,2
    mov dl,0dh
    int 21h
    mov dl,0ah
    int 21h
    
;--- mensagem de leitura ---;
    lea dx, messageGetFile ; load address of the string  
    mov ah, 09H ;output the string
    int 21H
;---------------------------;    
    
;--- leitura do nome do arquivo ---;    
    mov bl, 0
    mov si, offset nameFile ; si point the array
getNameFile:
    mov ah, 1
    int 21h
    cmp al, 13
    je strCopy
    mov [si], al    ; armazena 
    inc si          ; incrementa index
    mov lenght, si     ; armazena o tamanho da string
    jmp getNameFile
    
strCopy:
    cld
    mov     ax  , data
    mov     DS  , ax
    mov     ES  , ax
    mov cx, lenght
    lea si, nameFile
    lea di, nameFileKrp
    rep movsb
    
concatena_txt:
    cld
    mov     ax  , data
    mov     DS  , ax
    mov     ES  , ax
    mov     SI  , offset txt    ; ponteiro para txt
    mov     DI  , offset nameFile  ; ponteiro para o array
    add     DI  , lenght
    mov     cx  , 5
    rep movsb ; This should concat two strings
    
concatena_krp:
    cld
    mov     ax  , data
    mov     DS  , ax
    mov     ES  , ax
    mov     SI  , offset krp    ; ponteiro para txt
    mov     DI  , offset nameFileKrp  ; ponteiro para o array
    add     DI  , lenght
    mov     cx  , 5
    rep movsb ; This should concat two strings

;--- quebra linha ---;
    mov ah,2
    mov dl,0dh
    int 21h
    mov dl,0ah
    int 21h

;--- mensagem de leitura ---;
    lea dx, messageNameFile   
    mov ah, 09H 
    int 21H
    lea dx, nameFile 
    mov ah, 09H 
    int 21H

;--- quebra linha ---;
    mov ah,2
    mov dl,0dh
    int 21h
    mov dl,0ah
    int 21h
    
;--- mensagem de leitura ---;
    lea dx, messageNameFileKrp   
    mov ah, 09H 
    int 21H
    lea dx, nameFileKrp 
    mov ah, 09H 
    int 21H
    
;--- quebra linha ---;
    mov ah,2
    mov dl,0dh
    int 21h
    mov dl,0ah
    int 21h

;--- inicia leitura do arquivo .txt ---;    
    mov dx,offset nameFile  ; coloca o endereço do nome do arquivo em dx
    mov al,2        ; modo de acesso - leitura e escrita
    mov ah,3Dh      ; função 3Dh - abre um arquivo
    int 21h         ; chama serviço do DOS
    
    mov Handle,ax       ; guarda o manipulador do arquivo para mais tarde
    jc ErrorOpening     ; desvia se carry flag estiver ligada - erro!
    
    mov dx,offset Buffer    ; endereço do buffer em dx

LerBloco:
    cmp al, 0
    je theEnd
    mov bx,Handle       ; manipulador em bx
    mov cx,512      ; quantidade de bytes a serem lidos
    mov ah,3Fh      ; função 3Fh - leitura de arquivo
    int 21h         ; chama serviço do DOS
    
    jc ErrorReading     ; desvia se carry flag estiver ligada - erro!

Continuar:
    mov bx,Handle           ; coloca manipulador do arquivo em bx
    mov ah,3Eh              ; função 3Eh - fechar um arquivo
    int 21h                 ; chama serviço do DOS
    
    mov cx,[BytesLidos]     ; comprimento da string (Ler o valor da variável BytesLidos)
    mov si,OFFSET Buffer    ; DS:SI - endereço da string
    xor bh,bh               ; página de vídeo - 0
    mov ah,0Eh              ; função 0Eh - escrever caracter
    

NextChar:
    mov si,OFFSET Buffer
    inc indexTxt
    add si, indexTxt
    lodsb           ; al = proximo caracter do texto
    cmp al, 0     ; final do arquivo
    je endProgram
    mov caractereTxt, al
    
    mov si, offset stringCripto   ; carrega o ponteiro para a string
 
LOOP1:
    mov ax, [si]
    cmp al, caractereTxt
    je escreveKrp 
    cmp al, '$'          ; significa fim da string
    je NextChar
 
    inc si  ; incrementa o ponteiro
 
    jmp LOOP1
    
segue:
    
    jmp NextChar

endProgram: 
    mov ax,4C00h    ; termina programa
    int 21h
      
escreveKrp:
    mov caractereKrp, al
    
    ;CREATE FILE.
    mov  ah, 3ch
    mov  cx, 0
    mov  dx, offset nameFileKrp
    int  21h  
    
    ;PRESERVE FILE HANDLER RETURNED.
    mov  handler, ax
    
    ;WRITE 
    mov  ah, 40h
    mov  bx, handler
    mov  cx, 2  ;STRING LENGTH.
    mov  dx, offset indexTxt
    int  21h
    
    ;CLOSE FILE (OR DATA WILL BE LOST).
    mov  ah, 3eh
    mov  bx, handler
    int  21h
    jmp  NextChar


ErrorOpening:
    mov dx,offset OpenError ; exibe um erro
    mov ah,09h      ; usando a função 09h
    int 21h         ; chama serviço do DOS
    mov ax,4C01h        ; termina programa com um errorlevel =1 
    int 21h 

ErrorReading:
    mov dx,offset ReadError ; exibe um erro
    mov ah,09h      ; usando a função 09h
    int 21h         ; chama serviço do DOS
    mov ax,4C02h        ; termina programa com um errorlevel =2
    int 21h

quebraLinha:
;--- quebra linha ---;
    mov ah,2
    mov dl,0dh
    int 21h
    mov dl,0ah
    int 21h
        
theEnd:
    main endp
end main