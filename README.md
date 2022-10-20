# 📝 Esteganografia x86 🖥️
[![NPM](https://img.shields.io/github/license/Alamito/esteganografia-x86)](https://github.com/Alamito/esteganografia-x86/blob/main/LICENCE)

# Sobre o projeto

Esse projeto foi desenvolvido como trabalho final na disciplina de Arquitetura de Computadores I (Engenharia da Computação, UFRGS) sobre a arquitetura x86 da intel.

Há diversas maneiras de criptografar uma mensagem utilizando esteganografia e nesse projeto foi utilizado a maneira onde a mensagem a ser criptograda é passada pelo usuário através do teclado e a escrita responsável pela criptografação está previamente inclusa em um documento ".txt". A partir disso, o programa verifica os caracteres correspondentes/iguais entre a mensagem e a escrita, após camufla criando outro arquivo ".krp" e nele escrevendo as posições onde foram encontrados caracteres iguais. Além disso, são escritos no ".krp" o valor das posições com 2 bytes em Little-Endian. Por exemplo:

![esteganografia](https://user-images.githubusercontent.com/102616676/196831242-c64efee9-1a45-4b8a-b58f-ebe0b4489a9c.png)

Obs: 0A 00, 04 00, 06 00, etc. significa 10, 4 e 6, respectivamente em decimal, e tais valores estão escritos em hexadecimal formado por 2 bytes.

Ainda há outras ocasiões onde os caracteres da mensagem não é criptografada:
- caso não haja correspondência no arquivo .txt.
- caso a posição de criptografia foi ocupada anteriormente por outro caractere. Por exemplo, no exemplo anterior caso a mensagem fosse "strings", o último "s" não seria criptograda, porque a posição (10 ou 0A 00) de criptografia foi ocupada pelo primeiro "s" da palavra "strings".
- caso a mensagem possua caracteres menores que 33 ou maiores que 126 (decimal, segundo tabela ASCII).
- a posição 0 do .txt não faz parte da criptografia, no caso a criptografia começa a partir da posição 1.

Obs:
- não importa se os caracteres são minusculos ou maiusculos, eles são tratados como iguais.
- a mensagem tem que possuir no máximo 100 caracteres.
- o arquivo .txt tem que possuir um tamanho máximo de 64Kb.
- no final do arquivo .krp é inserido o valor 0 para indicar o final do arquivo.

# Apresentação do projeto

Executando o programa inserindo os seguintes textos de entrada:
- texto a ser criptogrado (mensagem): Arq intel
- nome de arquivo de leitura (arquivo .txt): cripto

Dessa forma, é gerado um arquivo .krp contendo o seguinte conteúdo: 01 00 12 00 02 00 04 00 05 00 10 00 09 00 0C 00 00 00

### Execução do programa:
![esteganografia](https://user-images.githubusercontent.com/102616676/196962384-9535bc23-dc79-48a9-982f-2eba94cb0a0f.gif)

Obs: o "caractere da frase inválido" do exemplo acima é ocasionado pelo "espaço" da mensagem, que está fora dos caracteres válidos.

### Conteúdo dos arquivos:

cripto.txt:

![txt](https://user-images.githubusercontent.com/102616676/196962860-07baae07-f0ce-4404-a409-91ce1eba60c1.png)

cripto.krp:

![cripto](https://user-images.githubusercontent.com/102616676/196963026-3c304d97-0d51-4afa-a043-577daabb109f.png)

# Tecnologias utilizadas

- Montador MASM611
- DOSBox
- Visual Studio Code (editor de texto)
- File View Pro (visualizador de binário)

# Como executar o projeto

A solução para executar o projeto utilizando o montador MASM611 e o DOSBox é um tanto complexa para o objeto de estudo, portanto a solução mais rápida e simples é utilizar um emulador dos processadores x86 da intel chamado EMU8086. Partindo disso, basta:

```bash
# clonar repositório
git clone https://github.com/Alamito/esteganografia-x86.git
```
Em seguida, abrir o arquivo "codigo8086.asm" utilizado o EMU8086 e dar <em>run</em> no programa. Porém, deve haver um arquivo ".txt" de criptografia dentro da pasta MyBuild dos arquivos do EMU8086, e deve ser colocado o nome desse arquivo após a execução do programa (sem haver a extensão ".txt").

# Autor
Alamir Bobroski Filho 
- www.linkedin.com/in/alamirdev

<p align = "center"><em>"O poder não vem do conhecimento mantido, mas do conhecimento compartilhado"</em></p> <p align = "center">Bill Gates</p>
