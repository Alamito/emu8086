# 📝 Esteganografia x86 🖥️
[![NPM](https://img.shields.io/github/license/Alamito/esteganografia-x86)](https://github.com/Alamito/esteganografia-x86/blob/main/LICENCE)

# Sobre o projeto

Esse projeto foi desenvolvido como trabalho final na disciplina de Arquitetura de Computadores I (Engenharia da Computação, UFRGS) sobre a arquitetura x86 da intel.

Há diversas maneiras de criptografar uma mensagem utilizando esteganografia e nesse projeto foi utilizado a maneira onde a mensagem a ser criptograda é passada pelo usuário através do teclado e a escrita responsável pela criptografação está previamente inclusa em um documento ".txt". A partir disso, o programa verifica os caracteres correspondentes/iguais entre a mensagem e a escrita, após camufla criando outro arquivo ".krp" e nele escrevendo as posições onde foram encontrados caracteres iguais. Além disso, são escritos no ".krp" o valor das posições com 2 bytes em Little-Endian. Por exemplo:

![esteganografia](https://user-images.githubusercontent.com/102616676/196831242-c64efee9-1a45-4b8a-b58f-ebe0b4489a9c.png)

Obs: 0A 00, 04 00, 06 00, etc. significa 10, 4 e 6, respectivamente em decimal, e tais valores estão escritos em hexadecimal formado por 2 bytes.

Ainda há outras ocasiões onde os caracteres da mensagem não é criptografada:
- caso não haja correspondência no arquivo .txt.
- caso a posição de criptografia foi ocupada anteriormente por outro caractere. Por exemplo, no exemplo anterior caso a mensagem fosse "strings", o último "s" não seria criptograda, porque a posição (10 ou 0A 00) de criptografio foi ocupada pelo primeiro "s" da palavra "strings".
- a posição 0 do .txt não faz parte da criptografia, no caso a criptografia começa a partir da posição 1.

Obs:
- não importa se os caracteres são minusculos ou maiusculos, eles são tratados como iguais.
- a mensagem tem que possuir no máximo 100 caracteres.
- o arquivo .txt tem que possuir um tamanho máximo de 64Kb.
- no final do arquivo .krp é inserido o valor 0 para indicar o final do arquivo.

# Apresentação do projeto

Mais informações em breve.

# Tecnologias utilizadas

Mais informações em breve.

# Como executar o projeto

Mais informações em breve.

# Autor
Alamir Bobroski Filho 
- www.linkedin.com/in/alamirdev

<p align = "center"><em>"O poder não vem do conhecimento mantido, mas do conhecimento compartilhado"</em></p> <p align = "center">Bill Gates</p>
