.model small
.data

nameFile db 100 dup('$')
txt db ".txt", 0
lenght dw 0
Handle DW ?             ; para guardar o manipulador do arquivo
OpenError DB "Ocorreu um erro (abrindo)!$"
ReadError DB "Ocorreu um erro (lendo)!$"

messageGetFile DB 'INSIRA O NOME DO ARQUIVO DE LEITURA: ', '$'
messageNameFile DB 'O NOME DO SEU ARQUIVO Eh: ','$'
menTeste DB 'teste 123', '$'

alBuffer DW 0

BytesLidos  DW 0                ; Bytes lidos do arquivo
Buffer      DB 4096 dup (?)     ; buffer para armazenar dados
FimBuffer   DW $-Buffer         ; Endereço do fim do buffer

.code
main proc
    mov ax,@data
    mov ds,ax
    
;--- mensagem de leitura ---;
    lea dx, messageGetFile ; load address of the string  
    mov ah, 09H ;output the string
    int 21H
;---------------------------;    
    
;--- inicia leitura do nome do arquivo ---;    
    mov bl, 0
    mov si, offset nameFile ; si point the array
getNameFile:
    mov ah, 1
    int 21h
    cmp al, 13
    je concatena_txt
    mov [si], al    ; armazena 
    inc si          ; incrementa index
    mov lenght, si     ; armazena o tamanho da string
    jmp getNameFile
    
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
    
    add [BytesLidos], cx    ; adiciona a quantidade de bytes lidos
    cmp ax, cx              ; compara quantos bytes foram lidos com a quantidade solicitada na função            
    jb  Continuar           ; sair da leitura, caso seja menor (final do arquivo encontrado!)
    
    
    add dx,512              ; avança o buffer de leitura
    cmp dx, FimBuffer       ; verifica se chegou no final do buffer
    jae Continuar           ; se dx for maior ou igual ao final, sair da leitura
    
    
    jmp LerBloco

Continuar:
    mov bx,Handle           ; coloca manipulador do arquivo em bx
    mov ah,3Eh              ; função 3Eh - fechar um arquivo
    int 21h                 ; chama serviço do DOS
    
    mov cx,[BytesLidos]     ; comprimento da string (Ler o valor da variável BytesLidos)
    mov si,OFFSET Buffer    ; DS:SI - endereço da string
    xor bh,bh               ; página de vídeo - 0
    mov ah,0Eh              ; função 0Eh - escrever caracter
    

NextChar:
    lodsb           ; AL = próximo caracter da string
    
    mov alBuffer, ax; guarda ax para implementacoes (isso foi usado de teste, serve pra nada)
    cmp al, 32      ; linha de teste
    je quebra       ; linha de teste
    
segue:
    cmp ax, 0e00h   ; se chegar no fim da leitura do arquivo
    je endProgram
    
    int 10h         ; chama serviço da BIOS
    loop NextChar

endProgram: 
    mov ax,4C00h    ; termina programa
    int 21h
      

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

quebra:
;--- quebra linha ---;
    mov ah,2
    mov dl,0dh
    int 21h
    mov dl,0ah
    int 21h
    mov ax, alBuffer    ; devolve o ax para seguir normalmente
    jmp segue 
        
theEnd:
    main endp
end main