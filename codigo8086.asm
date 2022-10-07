.model small
.data

;--- variaveis de arquivo ---;
nameFile db 15 dup('$')
nameFileKrp db 15 dup('$')
stringCripto db 105 dup('$')
Handle DW ?                  ; guarda o manipulador do arquivo
Buffer DB 4096 dup (?)       ; buffer para armazenar dados
handler dw ?

;--- variaveis de auxilio/logica/iteracao ---;
caractereStr db 0               ; guarda caractere da string
txt db ".txt", '$'                ; sera concatenado
krp db ".krp", '$'                ; sera concatenado
lenght dw 0                     ; guarda o tamanho da string
indexTxt dw 0                   ; guarda posicao do txt
indexString dw 0                ; guarda posicao da string
lenghtArray dw 0                ; guarda o tamanho do vetor de posicoes
iteracaoArray dw 0              ; usado para terminar o loop de comparacoes com o vetor de posicoes
indicadorArray dw 0             ; indica quantos bytes deve ser pulado desde o inicio do vetor de posicoes
indicadorPosicao dw 0           ; indica os bytes a serem pulados no vetor de posicao
flagCharFrase db 0
lenghtFrase db '0', '0', '0', 0
errorProgram db 0
zero dw 0
flagFraseProblem db 0
arrayPosicao dw 105 dup (?)   ; guarda em um vetor as posicoes ja usadas do .txt

;--- mensagens ao user ---;
OpenError DB 'OCORREU UM ERRO NA ABERTURA DO ARQUIVO!', '$'
ReadError DB 'OCORREU UM ERRO NA LEITURA DO ARQUIVO', '$'
messageCriaco db 'OCORREU UM ERRO NA CRIACAO DO ARQUIVO .krp', '$'
messageGetFile DB 'INSIRA O NOME DO ARQUIVO DE LEITURA: ', '$'
messageGetCripto DB 'INSIRA O TEXTO A SER CRIPTOGRAFADO: ', '$'
messageNameFile DB 'INPUT: ','$'
messageNameFileKrp DB 'OUTPUT: ','$'
messageVazio db 'ARQUIVO (.txt) DE LEITURA VAZIO', '$'
messageInvalido db 'CARACTERE DA FRASE INVALIDO!', '$'
messageCharFrase db 'CARACTERE DA FRASE NAO ENCONTRADO NO ARQUIVO', '$'
messageSize db 'TAMANHO DA FRASE: ', '$'
messageSizeMax db 'TAMANHO DA FRASE EXCEDEU O LIMITE', '$'
messageFraseVazia db 'FRASE VAZIA (NAO POSSUI CARACTERE)', '$'
messageBytes db ' bytes', '$'
messageFalseError db 'PROCESSAMENTO REALIZADO SEM ERROS', '$'
messageTrueError db 'PROCESSAMENTO REALIZADO COM ERROS', '$'
 

.code
main proc
    mov ax,@data
    mov ds,ax

;--- mensagem de leitura ---;
    lea dx, messageGetCripto    ; carrega endereco da string  
    mov ah, 09H                 ; printa string
    int 21H

;--- pega a string q sera criptografada ---;
    mov bl, 0
    mov si, offset stringCripto ; ponteiro para o array
    mov di, offset lenghtFrase
getNameCripto:
    mov ah, 1
    int 21h
    cmp al, 13
    je continua
    inc flagFraseProblem
    mov [si], al                ; armazena
    inc si                      ; incrementa index  

 ;--- armazena em um array o numero de bytes da frase ---;                         
    mov al, [di+2]
    cmp al,'9'
    je incrementaDecimos
    inc al
    mov [di+2],al
loopContador:
    jmp getNameCripto

incrementaDecimos:
    mov al, '0'
    mov [di+2], al
    mov al, [di+1]
    cmp al,'9'
    je incrementaCentesimos
    inc al
    mov [di+1],al
    jmp loopContador
incrementaCentesimos:
    mov al, '0'
    mov [di+1], al
    mov al, [di]
    cmp al,'1'
    je tratarCentesimo
    mov al, '1'
    mov [di],al
    jmp loopContador

tratarCentesimo:
    mov al,[di+2]
    cmp al, '1'
    je erroFraselonga
    jmp loopContador

continua:
    cmp flagFraseProblem, 0
    je erroFraseVazia
    cmp flagFraseProblem, 100
    jnl erroFraselonga

    call quebraLinha

;--- mensagem de leitura ---;
    lea dx, messageGetFile   
    mov ah, 09H 
    
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
    jmp getNameFile
    
strCopy:
    
;--- concatena .txt ---;
    lea si, nameFile
    lea di, nameFileKrp
    call CopyString
    
    lea si, nameFile
    lea di, txt
    call concatena
   
    lea si, nameFileKrp
    lea di, krp
    call concatena

    call quebraLinha
    call quebraLinha

;--- mensagem de leitura ---;
    lea dx, messageNameFile   
    mov ah, 09H 
    int 21H
    lea dx, nameFile 
    mov ah, 09H 
    int 21H

    call quebraLinha
    
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
    lea  dx, nameFileKrp
    int  21h
    mov  bx, ax
    jc erroCriacao
    
    call quebraLinha

;--- inicia leitura do arquivo .txt ---;    
    mov dx,offset nameFile  ; coloca o endereco do nome do arquivo em dx
    mov al,2                ; modo de acesso - leitura e escrita
    mov ah,3Dh              ; funcao 3Dh - abre um arquivo
    int 21h                 ; chama servi�o do DOS
    
    mov Handle,ax           ; guarda o manipulador do arquivo para mais tarde
    jc ErrorOpening         ; desvia se carry flag estiver ligada - erro!
    
    mov dx,offset Buffer    ; endere�o do buffer em dx

LerBloco:
    cmp al, 0
    je theEnd
    mov bx,Handle       ; manipulador em bx
    mov cx,65535        ; quantidade de bytes a serem lidos
    mov ah,3Fh          ; funcao 3Fh - leitura de arquivo
    int 21h             ; chama servi�o do DOS
    
    jc ErrorReading     ; desvia se carry flag estiver ligada - erro!

nextString:
    mov flagCharFrase, 0
    
    mov si, offset stringCripto ; ponteiro para o inicio da string
    add si, indexString         ; pula para a letra da string
    mov ax, [si]                ; al fica com o valor do char da string
    cmp al, '$'                 ; fim da string
    je endProgram               ; pula para o fim do programa (chegou no final da string)
    mov caractereStr, al        ; coloca char em outra variavel para cmp com char do txt
    inc indexString             ; incrementa o index para iterar entre a string
    
    cmp caractereStr, 020h      
    jle charInvalido            ; menor ou igual a 20 (space) em hexa
    
    cmp caractereStr, 041h
    jnl toLowerStr              ; maior ou igual a 41 (a) em hexa
    
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
    je TestaCharFrase           ; vai para o proximo char da string
 
    jmp nextTxt
      
escreveKrp:

    mov indicadorPosicao, 0
    mov iteracaoArray, 0 
    cmp lenghtArray, 0
    je armazenaPosicao           ; vetor de posicoes vazio... pula direto para o armazenamento
comparaPosicao:                  ; descobre se a posicao atual do .txt ja foi utilizada
    inc iteracaoArray
    mov si, offset arrayPosicao  ; ponteiro para o inicio do vetor
    add si, indicadorPosicao
    mov ax, [si]
    cmp indexTxt, ax             ;   
    je  retornaValor             ; posicao ja utilizada... pula para retornar os valores na memoria
    mov ax, lenghtArray
    cmp ax, iteracaoArray
    je armazenaPosicao           ; posicao nao utilizada... armazena a posicao
    add indicadorPosicao, 2      ; proximo valor do vetor
    jmp comparaPosicao
    
armazenaPosicao:                 ; armazena a posicao do .txt no vetor
    mov si, offset arrayPosicao
    add si, indicadorArray
    mov ax, indexTxt
    mov [si], ax
    add indicadorArray, 2        ; proximo espaco vazio do vetor
    inc lenghtArray              ; conta o tamanho do vetor
    
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
    mov dx, offset indexTxt
    mov cx, 2
    mov ah, 40h
    int 21h 

;--- fecha o arquivo ---;    
    mov bx, [handle]
    mov ah, 3eh
    int 21h
    
    mov flagCharFrase, 1
    
    jmp  nextString
    
TestaCharFrase:
    cmp flagCharFrase, 1       
    je  nextString
    
    mov errorProgram, 1
    
;--- mensagem de caractere nao encontrado ---;
    lea dx, messageCharFrase   
    mov ah, 09H 
    int 21H
    
;--- quebra linha ---;
    mov ah,2
    mov dl,0dh
    int 21h
    mov dl,0ah
    int 21h
    
    jmp nextString
    
    
charInvalido:
    mov errorProgram, 1
    lea dx, messageInvalido ; load address of the string  
    mov ah, 09H             ; output the string
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
    
retornaValor:               
    mov si, offset Buffer   ; retorna o ponteiro para o txt
    add si, indexTxt        
    inc si                  ; incrementa para a proxima posicao do .txt
    jmp nextTxt             ; pula para o proximo char dps do que foi recem testado

ErrorOpening:
;--- printa mensagem de erro ---;
    mov dx,offset OpenError ; exibe um erro
    mov ah,09h              ; usando a fun��o 09h
    int 21h                 ; chama servi�o do DOS
    jmp trueError 

ErrorReading:
;--- printa mensagem de erro ---;
    mov dx, offset ReadError ; exibe um erro
    mov ah,09h              ; usando a fun��o 09h
    int 21h                 ; chama servi�o do DOS
    jmp trueError
    
erroCriacao:
;--- printa mensagem de erro ---;
    lea dx, messageCriaco 
    mov ah, 09H 
    int 21H
    jmp trueError

erroFraselonga:
;--- printa mensagem de erro ---;
    lea dx, messageSizeMax
    mov ah, 09H
    int 21h
    jmp trueError

erroFraseVazia:
;--- printa mensagem de erro ---;
    lea dx, messageFraseVazia
    mov ah, 09H
    int 21h
    jmp trueError
    
    
endProgram:
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
    mov dx, offset zero     ; coloca 00 00 no final do arquivo
    mov cx, 2
    mov ah, 40h
    int 21h 

;--- fecha o arquivo ---;    
    mov bx, [handle]
    mov ah, 3eh
    int 21h

    call quebraLinha

;--- mensagem de tamanho ---; 
    lea dx, messageSize   
    mov ah, 09H 
    int 21H

    lea bx, lenghtFrase
    call printf_s
    
    lea dx, messageBytes    ; imprime " bytes"   
    mov ah, 09H 
    int 21H
    
    call quebraLinha
    call quebraLinha
    
    cmp errorProgram, 1
    je trueError
    lea dx, messageFalseError   
    mov ah, 09H 
    int 21H
    jmp theEnd
    
trueError:
    call quebraLinha
    lea dx, messageTrueError   
    mov ah, 09H 
    int 21H
theEnd:
    mov ax,4C00h    ; termina programa
    int 21h
    
main endp



concatena  proc    near
init_concat:
    mov al, '$'
    cmp al, [si]
    je  sai_concat1
    inc si
    jmp init_concat
sai_concat1:
    mov al , '$'
    cmp al, [di]
    je out_loop
    mov dl, [di]
    mov [si], dl
    inc di
    inc si
    jmp sai_concat1
out_loop:
    mov al, 0h
    mov [si], al
    ret
concatena endp

CopyString  proc    near
loop_copy:
    mov al, '$'
    cmp [si], al
    je out_copy
    mov bl,[si]
    mov [di], bl
    inc si
    inc di
    jmp loop_copy
out_copy:
    mov [di], al
    ret
CopyString  endp

;--- printa string de numeros ---;
printf_s	proc	near     
	mov		dl,[bx]
	cmp		dl,0
	je		ps_1

	push	bx
	mov		ah,2
	int		21H
	pop		bx

	inc		bx		
	jmp		printf_s
		
ps_1:
	ret
printf_s	endp

quebraLinha proc near
    mov ah,2
    mov dl,0dh
    int 21h
    mov dl,0ah
    int 21h
    ret
quebraLinha endp

end main