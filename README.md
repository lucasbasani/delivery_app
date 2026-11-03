# PedeAi

Aplicativo mobile de restaurante desenvolvido em Flutter para a disciplina de Desenvolvimento Mobile.

## Integrantes

| Integrante | GitHub |
|---|---|
| Lucas Monteiro Ribas | Lucas Monteiro Ribas |
| Matheus Galvão Vieira | MatheusGalvao |
| _(nome do 3º integrante)_ | lucasbasani |

## Objetivo

O PedeAi permite que clientes criem uma conta, vejam o cardápio de um restaurante, pesquisem e filtrem produtos, montem a sacola e finalizem o pedido informando endereço de entrega e forma de pagamento. Os pedidos ficam salvos e podem ser consultados no histórico.

## Tecnologias

- Flutter e Dart
- Provider (gerenciamento de estado)
- Firebase Authentication (login com e-mail e senha)
- Cloud Firestore (banco de dados online)
- SharedPreferences (dados locais do aparelho)

## Funcionalidades

### Parte 1
- Login e cadastro com validação dos formulários
- Cardápio com pesquisa e filtro por categoria
- Sacola: adicionar, alterar quantidade, remover e ver total
- Navegação entre telas e mensagens de feedback

### Parte 2
- **Autenticação real (Firebase Auth):** cadastro, login, logout, sessão mantida ao reabrir o app, recuperação de senha por e-mail e troca de senha com confirmação da senha atual. Nenhuma tela de cliente abre sem login (`AuthGate`).
- **Banco de dados (Cloud Firestore):** perfil do usuário, cardápio, endereços salvos e pedidos. As regras de segurança (`firestore.rules`) impedem que um usuário acesse dados de outro.
- **Checkout com formulário:** dados de quem recebe, endereço de entrega (CEP, rua, número, complemento, bairro, cidade e UF), escolha de endereço salvo, forma de pagamento (Pix, cartão na entrega ou dinheiro com troco) e observações, tudo com validação.
- **Meus pedidos:** histórico com itens, endereço, pagamento e valores.
- **Meus endereços:** CRUD completo de endereços.
- **Minha conta:** edição de nome e telefone e alteração de senha.
- **SharedPreferences:** lembra o e-mail no login e a última forma de pagamento usada.

## Melhorias em relação à Parte 1

- Mais formulários, conforme o feedback do professor: checkout, endereços, perfil, troca de senha e recuperação de senha.
- Validações centralizadas em `lib/utils/validators.dart`.
- Produtos saíram de dentro da `HomeScreen` e passaram para o banco (`ProductService` e `ProductProvider`).
- Corrigido o login, que antes não conferia a senha de contas cadastradas.
- Corrigido o logout com verificação duplicada.
- Criada a pasta `assets/images/`, declarada no `pubspec.yaml`, que impedia o build.

## Arquitetura

```
lib/
  data/        cardápio inicial gravado no Firestore (seed)
  models/      modelos de dados (usuário, produto, endereço, pedido)
  services/    acesso ao Firebase e ao SharedPreferences
  providers/   gerenciamento de estado (Provider)
  utils/       validações e formatações
  views/       telas (auth e client)
  widgets/     componentes reutilizáveis
```

As telas só conversam com os **providers**, que usam os **services** para acessar o Firebase.

## Estrutura do banco (Cloud Firestore)

| Coleção | Conteúdo |
|---|---|
| `users/{uid}` | nome, e-mail e telefone do usuário |
| `users/{uid}/addresses/{id}` | endereços salvos do usuário |
| `products/{id}` | cardápio (criado automaticamente na primeira execução) |
| `orders/{id}` | pedidos com `userId`, itens, endereço, pagamento, valores e data |

A senha **não** fica no Firestore: ela é gerenciada pelo Firebase Authentication.

## Instalação e execução

### Pré-requisitos
- Flutter SDK instalado (`flutter doctor` sem erros)
- Emulador Android ou celular com depuração USB

### Rodar o projeto
O projeto já está conectado ao Firebase (`lib/firebase_options.dart` e `android/app/google-services.json` estão no repositório). Basta rodar:

```bash
git clone https://github.com/lucasbasani/delivery_app.git
cd delivery_app
flutter pub get
flutter run
```

Na primeira execução, crie uma conta pela tela **Criar conta**. O cardápio é gravado no banco automaticamente.

### Conta de teste
- E-mail: _(preencher)_
- Senha: _(preencher)_

### Usar um projeto Firebase próprio (opcional)
1. Crie um projeto no [Firebase Console](https://console.firebase.google.com).
2. Ative **Authentication > E-mail/senha** e crie o **Firestore Database**.
3. Cole o conteúdo de `firestore.rules` em **Firestore > Regras** e publique.
4. Instale as ferramentas e conecte o app:
   ```bash
   npm install -g firebase-tools
   firebase login
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

## Atividades de cada integrante

| Integrantes |
|---|
| Lucas Monteiro Ribas |
| Matheus Galvão Vieira |

## Particularidades e limitações

- Pagamentos com cartão são feitos na entrega; o app não coleta dados de cartão.
- O status do pedido é sempre "Recebido", pois não há painel do restaurante.
- A taxa de entrega é fixa (R$ 6,00).
- A regra de escrita em `products` deve ser trocada para `false` depois que o cardápio for criado.
