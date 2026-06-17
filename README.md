#  Caso Clássico: Produtor-Consumidor com Buffer Limitado em Elixir

Projeto acadêmico realizado para a displina de Programação Concorrente da UTFPR-DV, curso de Engenharia de Software

---

## 📋 Sobre o Projeto

Este projeto consiste em uma implementação prática do problema clássico do **Produtor-Consumidor** utilizando a linguagem **Elixir**, demonstrando concorrência nativa baseada no **Modelo de Atores** sem o uso de travas de memória (*Locks* ou *Mutexes*).

---

## 🧠 Explicação do Projeto

O sistema simula um ambiente onde múltiplos processos trabalham em frequências diferentes compartilhando uma zona de armazenamento temporário (o **Buffer**):

* **O Buffer (Ator Central):** Criado via `spawn`, gerencia de forma isolada uma fila interna limitada a **3 itens** (usando o módulo `:queue`). Ele recebe dados dos produtores e os entrega ao consumidor. Como sua caixa de entrada (*Mailbox*) processa apenas uma mensagem por vez, **a exclusão mútua é nativa e os dados nunca são corrompidos**.
* **Produtores (A e B):** Geram itens de forma assíncrona. O Produtor-A envia 5 itens a cada 0.5s e o Produtor-B envia 4 itens a cada 0.7s. Se o Buffer estiver cheio, o item atual dorme por 0.5s e tenta ser enviado novamente.
* **Consumidor:** Retira e processa os itens do Buffer. Ele é propositalmente mais lento (1.1s por item), forçando o acúmulo de dados e o preenchimento total do Buffer.

---

## 🛠️ Ferramentas Utilizadas

* **Linguagem:** Elixir (v1.12 ou superior)
* **Ambiente de Execução:** Erlang/BEAM Virtual Machine (nativo do Elixir)
* **IDE:** Visual Studio Code (VS Code) + Extensão `ElixirLS`

---

## 🚀 Como Rodar o Projeto

1. Certifique-se de ter o **Elixir instalado** no seu sistema operacional.
2. Crie um arquivo chamado `ProdutorConsumidor.exs` e cole o código do projeto nele.
3. Abra o terminal (cmd, PowerShell ou terminal do VS Code) na pasta do arquivo e execute:

```bash
elixir ProdutorConsumidor.exs
