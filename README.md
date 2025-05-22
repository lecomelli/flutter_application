# Projeto: Laço – CRM Pessoal com Privacidade e Inteligência

Este é um projeto Flutter chamado **Laço**, um CRM pessoal mobile-first, privado e offline-first, com o objetivo de ajudar pessoas a manterem relacionamentos interpessoais ativos e saudáveis (amigos, família, networking, etc).

---

## 🧠 Objetivo do Projeto

Criar uma aplicação Flutter moderna e modular com as seguintes características:

### 🔍 Diferenciais
- Armazenamento **local e criptografado**
- Totalmente **mobile-first**
- Interface moderna baseada em **Material 3**
- Funciona **offline**, com **sincronização futura**
- Controle completo sobre dados (foco em **privacidade**, estilo Monica)
- Integrações futuras com **WhatsApp**, **Telegram** e **LinkedIn**
- Suporte a **notificações push** e **lembretes inteligentes**
- Estrutura escalável para uso pessoal e opcionalmente colaborativo

---

## ✨ Funcionalidades MVP

- Cadastro de **pessoas** com:
  - Nome, data de nascimento, foto (opcional)
  - Tags e categorias (ex: Família, Networking, Amigos)
  - Notas pessoais (ex: “gosta de vinho italiano”)
- Registro de **interações**:
  - Canal (WhatsApp, ligação, e-mail, presencial)
  - Data e observações
- **Lembretes** com notificações:
  - Push locais (ex: “Faz 30 dias sem falar com João”)
  - Frequência personalizada por pessoa
- Interface com **BottomNavigationBar** (3 abas):
  - Contatos
  - Interações
  - Lembretes

---

## 📦 Estrutura de Código Sugerida

lib/
├── main.dart
├── core/ # Tema, rotas, helpers globais
├── features/
│ ├── contacts/ # Modelos, controller, telas de contato
│ ├── interactions/ # Registro e listagem de interações
│ └── reminders/ # Lembretes e notificações locais
├── services/ # Banco local, notificações, sincronização futura
├── data/ # Modelos persistentes, repositórios
└── widgets/ # Componentes reutilizáveis

---

## 🧰 Tecnologias e Bibliotecas

| Função | Biblioteca |
|--------|------------|
| Armazenamento local criptografado | `drift + sqlite3_flutter_libs` ou `sqflite_sqlcipher` |
| Injeção de dependência e estado | `flutter_riverpod` |
| Roteamento | `go_router` |
| Notificações locais | `flutter_local_notifications` |
| UI Material 3 | `flutter_material_3`, `flutter_hooks` |
| Imagens (perfil) | `image_picker`, `cached_network_image` |

---

## 🔐 Segurança

- Todos os dados são armazenados **localmente e com criptografia AES**
- App pode rodar em modo **offline completo**
- Autenticação biométrica local planejada para v1.1
- Integração com backend é opcional (sincronização via API própria futura)

---

## 📈 Futuro

- Integração com **WhatsApp Cloud API** para extrair conversas autorizadas
- Enriquecimento automático via LinkedIn/Telegram (com opt-in)
- Visualização em **mapa de rede** (grafos de relacionamento)
- App PWA + publicação Android/iOS (Flutter multiplataforma)

---

## 🚀 Início Rápido

```bash
flutter create laco
cd laco
# Adicione as dependências no pubspec.yaml conforme acima
# Estruture os módulos conforme indicado
# Use este README como referência de prompt para GitHub Copilot