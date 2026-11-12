# Portal de Leilões

> Protótipo de plataforma de leilões online desenvolvido com **Flutter e Dart**. Projeto de estudo e portfólio, em evolução incremental.

![Status](https://img.shields.io/badge/status-em%20desenvolvimento-blue) ![Flutter](https://img.shields.io/badge/Flutter-Web-02569B?logo=flutter) ![Versão](https://img.shields.io/badge/vers%C3%A3o-0.1.0-informational)

## Visão geral

O Portal de Leilões tem como objetivo conectar **leiloeiros verificados** a **arrematantes habilitados**, permitindo a divulgação de leilões, organização de lotes e participação em disputas online. A aplicação está na fase de **protótipo de interface** e **não aceita lances nem pagamentos reais**.

## Funcionalidades disponíveis — v0.1.0

- Listagem de lotes demonstrativos.
- Filtros por situação: **aberto**, **em andamento** e **encerrado**.
- Visualização de detalhes: descrição, lance inicial, incremento mínimo, próximo lance estimado, local de retirada e encerramento previsto.
- Painel demonstrativo do leiloeiro.
- Formulário de cadastro de lotes com validação básica de valores.
- Navegação entre listagem e painel.

> **Limitação:** os dados são mantidos apenas na memória do aplicativo e desaparecem quando a aplicação é reiniciada. Não há autenticação, banco de dados nem controle de permissões nesta versão.

## Regras de negócio planejadas

1. Apenas leiloeiros **verificados e aprovados** poderão publicar leilões e lotes.
2. Arrematantes precisarão de **habilitação pelo leiloeiro** para ofertar lances.
3. Cada lote terá descrição, lance inicial, incremento mínimo, condições e local de retirada.
4. Um lance válido nos **últimos dois minutos** prorrogará o encerramento em **dois minutos** (regra inicial a validar e implementar no servidor).
5. Pagamentos via **Pix e cartão** serão integrados em uma etapa futura.
6. Validação de lances, permissões e pagamentos será feita no **backend**, não apenas na interface.

## Tecnologias

- **Flutter / Dart** — interface e lógica do protótipo.
- **Flutter Web / Chrome** — ambiente de testes atual.
- **Git e GitHub** — versionamento e documentação.
- **Supabase** — opção planejada para autenticação, dados e armazenamento; **ainda não integrado**.

## Executar localmente

Pré-requisitos: Flutter SDK instalado e Google Chrome disponível.

```bash
flutter pub get
flutter run -d chrome
```

Para conferir o ambiente:

```bash
flutter doctor -v
```

O Android SDK **não é necessário** para executar esta versão no Chrome.

## Estrutura atual

```text
portal_leiloes/
├── lib/
│   └── main.dart       # Interface e dados demonstrativos
├── web/                # Configuração Flutter Web
├── test/               # Testes do projeto Flutter
├── pubspec.yaml        # Dependências e configuração
└── README.md           # Documentação
```

## Roadmap

- [x] **v0.1.0** — Protótipo de interface e lotes demonstrativos.
- [ ] **v0.2.0** — Cadastro, login e perfis de usuário.
- [ ] **v0.3.0** — Verificação de leiloeiros.
- [ ] **v0.4.0** — Leilões e lotes persistidos no banco de dados.
- [ ] **v0.5.0** — Habilitação de arrematantes.
- [ ] **v0.6.0** — Lances em tempo real e prorrogação automática.
- [ ] **v0.7.0** — Integração segura de pagamentos.
- [ ] **v1.0.0** — Lançamento condicionado a testes, segurança e requisitos legais.

## Capturas de tela

As capturas do protótipo serão adicionadas em uma próxima atualização.

## Segurança e conformidade

Este é um **projeto educacional e demonstrativo**. Antes de operar leilões reais, será necessário validar requisitos jurídicos aplicáveis, privacidade e LGPD, prevenção de fraude, verificação de identidade, registro auditável de lances e integração de pagamentos segura.

## Autor

**Jonatas Lima** — Projeto de portfólio em desenvolvimento Flutter/Dart.

## Histórico de versões

Consulte [CHANGELOG.md](CHANGELOG.md).
