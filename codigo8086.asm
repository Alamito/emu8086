.model small
.data

;--- variaveis de arquivo ---;
nameFile db 105 dup('$')
nameFileKrp db 105 dup('$')
stringCripto db 105 dup('$')
Handle DW ?                  ; guarda o manipulador do arquivo
Buffer DB 4096 dup (?)       ; buffer para armazenar dados
handler dw ?

;--- variaveis de auxilio/logica/iteracao ---;
caractereStr db 0            ; guarda caractere da string
txt db ".txt", 0             ; sera concatenado
krp db ".krp", 0             ; sera concatenado
lenght dw 0                  ; guarda o tamanho da string
indexTxt dw 0                ; guarda posicao do txt
indexString dw 0             ; guarda posicao da string
aux_indexTxt db 0            ; auxilio na transformacao para little endian
le_indexTxt dw 0             ; guarda o valor em little endian

;--- mensagens ao user ---;
OpenError DB "Ocorreu um erro (abrindo)!$"
ReadError DB "Ocorreu um erro (lendo)!$"
messageGetFile DB 'INSIRA O NOME DO ARQUIVO DE LEITURA: ', '$'
messageGetCripto DB 'INSIRA O TEXTO A SER CRIPTOGRAFADO: ', '$'
messageNameFile DB 'INPUT: ','$'
messageNameFileKrp DB 'OUTPUT: ','$'
messageVazio db 'ARQUIVO (.txt) DE LEITURA VAZIO', '$'
messageInvalido db 'CARACTERE INVALIDO!', '$'
 

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
    
;--- concatena .txt ---;
    cld
    mov     ax  , data
    mov     DS  , ax
    mov     ES  , ax
    mov     SI  , offset txt    ; ponteiro para txt
    mov     DI  , offset nameFile  ; ponteiro para o array
    add     DI  , lenght
    mov     cx  , 5
    rep movsb                   ; concatena as string
    
;--- concatena .krp ---;
    cld
    mov     ax  , data
    mov     DS  , ax
    mov     ES  , ax
    mov     SI  , offset krp    ; ponteiro para txt
    mov     DI  , offset nameFileKrp  ; ponteiro para o array
    add     DI  , lenght
    mov     cx  , 5
    rep movsb                   ; concatena as string

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
    
;--- cria arquivo .krp ---;
    mov  ah, 3ch
    mov  cx, 0
    mov  dx, offset nameFileKrp
    int  21h
    
;--- quebra linha ---;
    mov ah,2
    mov dl,0dh
    int 21h
    mov dl,0ah
    int 21h

;--- inicia leitura do arquivo .txt ---;    
    mov dx,offset nameFile  ; coloca o endereco do nome do arquivo em dx
    mov al,2                ; modo de acesso - leitura e escrita
    mov ah,3Dh              ; funcao 3Dh - abre um arquivo
    int 21h                 ; chama serviço do DOS
    
    mov Handle,ax           ; guarda o manipulador do arquivo para mais tarde
    jc ErrorOpening         ; desvia se carry flag estiver ligada - erro!
    
    mov dx,offset Buffer    ; endereço do buffer em dx

LerBloco:
    cmp al, 0
    je theEnd
    mov bx,Handle       ; manipulador em bx
    mov cx,65535        ; quantidade de bytes a serem lidos
    mov ah,3Fh          ; funcao 3Fh - leitura de arquivo
    int 21h             ; chama serviço do DOS
    
    jc ErrorReading     ; desvia se carry flag estiver ligada - erro!

nextString:
    mov si, offset stringCripto ; ponteiro para o inicio da string
    add si, indexString         ; pula para a letra da string
    mov ax, [si]                ; al fica com o valor do char da string
    cmp al, '$'                 ; fim da string
    je endProgram               ; pula para o fim do programa (chegou no final da string)
    mov caractereStr, al        ; coloca char em outra variavel para cmp com char do txt
    inc indexString             ; incrementa o index para iterar entre a string
    
    cmp caractereStr, 020h      
    jle charInvalido            ; menor ou igual a 20 em hexa
    
    cmp caractereStr, 041h
    jnl toLowerStr              ; maior ou igual a 61 em hexa
    
segue:
    mov si, offset Buffer
    lodsb                   ; evita cmp com o 1 caractere
    mov indexTxt, 0         ; reset da posicao no txt
    
nextTxt:
    inc indexTxt            ; salva valor da posicao no txt
    lodsb
    
    cmp al, 041h
    jnl toLowerTxt          ; maior ou igual a 61 em hexa
    
avante:    
    cmp al, caractereStr    ; comparacao char txt Vs char string
    je escreveKrp           ; se forem iguais escreve no .krp
    cmp al, 0               ; fim do txt
    je nextString             ; vai para a proximo char da string
 
    jmp nextTxt
      
escreveKrp:
;--- transforma indexTxt em little endian ---;
    mov dx, indexTxt
    mov dh, aux_indexTxt
    mov dh, dl
    mov dl, aux_indexTxt
    mov le_indexTxt, dx
    
;--- abre arquivo para escrita ---;  
    mov ah, 3dh
    mov al, 1
    mov dx, offset nameFileKrp
    int 21h
   
    mov [handle], ax

;--- coloca o file pointer para o final do arquivo ---;    
    mov bx, ax
    mov ah, 42h  ; "lseek"
    mov al, 2    ; position relative to end of file
    mov cx, 0    ; offset MSW
    mov dx, 0    ; offset LSW
    int 21h

;--- escreve no arquivo ---;   
    mov bx, [handle]
    mov dx, offset le_indexTxt
    mov cx, 2
    mov ah, 40h
    int 21h 

;--- fecha o arquivo ---;    
    mov bx, [handle]
    mov ah, 3eh
    int 21h 
    
    jmp  nextString

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
    
charInvalido:
    lea dx, messageInvalido ; load address of the string  
    mov ah, 09H ;output the string
    int 21H
;--- quebra linha ---;
    mov ah,2
    mov dl,0dh
    int 21h
    mov dl,0ah
    int 21h
    jmp nextString

toLowerStr:
    cmp caractereStr, 05Bh
    jnl segue               ; nao precisa transformar
    add caractereStr, 020h  ; transforma em um char minusculo
    jmp segue               

toLowerTxt:
    cmp al, 05Bh
    jnl avante              ; nao precisa transformar
    add al, 020h            ; transforma em um char minusculo
    jmp avante
    
endProgram: 
    mov ax,4C00h    ; termina programa
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