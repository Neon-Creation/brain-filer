# POC: [Foundation Model e RAG]

Prova de conceito para testar a aplicação da IA local, Foundation Model, no dispositivo iOS e suas limitações.

## Objetivo da POC
* Testar o limite e como o Foundation Model funciona.
* Aplicar o RAG com o Natural Language para ajudar o prompt.

## Tecnologias Utilizadas
* Foundation Model
* Natural Language
* Textual

## Pré-requisitos
É necessário para a execução desse projeto o XCode para buildar corretamente o projeto.
Certifique-se de ter o Apple Intelligence ativado no dispotivo que irá buildar
## Como Executar
Passo a passo direto para rodar o projeto localmente.

1. Clone o repositório: `git clone https://github.com/Neon-Creation/brain-filer.git`
2. Abra o POCFoundationModel.xcodeproj
3. Buildar o projeto em um iPhone ou usando o simulator

## Resultados e Conclusões
### O que funcionou bem:
A aplicação do Foundation Models funcionou bem, a sua implementação é simples e percebe-se bem claro seus limites
### O que não funcionou:
O uso no Natural Language para fazer o RAG para tokenizar os arquivos pre-mockados no projeto. O seu embedding não foi tão desejável.
### Veredito:
O uso dele deve ser considerado um uso bem especifico. O Foundation Models como é um modelo que possui somente 2B de parametros e não possui uma memória tão elevada, chats prolongados ou interações muito frequentes não são recomendadas, mas para o uso de categorização dos arquivos, ele serve muito bem. Já o uso do Natural Language para RAG de leitura de arquivos fica descartável, os resultados do embedding não foram nada satisfatórios, Ex: prompt pergunta sobre animais e ele vai linkar um trecho que fala sobre plantas sendo o mais significativo para responder o prompt inicial 

## Próximos Passos 
1. Usar outro modelo para fazer embedding
2. Melhorar os prompts passados para o Foundation Model
