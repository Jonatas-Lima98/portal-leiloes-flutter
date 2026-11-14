import 'package:flutter/material.dart';

enum TipoConta { arrematante, leiloeiro }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identificador = TextEditingController();
  final _senha = TextEditingController();
  bool _ocultar = true;

  @override
  void dispose() {
    _identificador.dispose();
    _senha.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Entrar')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.gavel, size: 52),
                    const SizedBox(height: 16),
                    const Text('Acesse sua conta', textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Demonstração: não informe credenciais reais.',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _identificador,
                      decoration: const InputDecoration(
                        labelText: 'E-mail ou nome de usuário',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        final valor = v?.trim() ?? '';
                        if (valor.isEmpty) return 'Informe seu e-mail ou nome de usuário';
                        if (valor.contains('@') &&
                            !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(valor)) {
                          return 'Informe um e-mail válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _senha,
                      obscureText: _ocultar,
                      decoration: InputDecoration(
                        labelText: 'Senha', border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip: _ocultar ? 'Mostrar senha' : 'Ocultar senha',
                          icon: Icon(_ocultar ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _ocultar = !_ocultar),
                        ),
                      ),
                      validator: (v) => (v?.isEmpty ?? true) ? 'Informe a senha' : null,
                    ),
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) return;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Login demonstrativo: autenticação ainda não disponível.'),
                        ));
                      },
                      child: const Text('Entrar (demonstração)'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(context,
                        MaterialPageRoute<void>(builder: (_) => const CadastroScreen())),
                      child: const Text('Ainda não tem conta? Cadastre-se'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});
  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _campos = {};
  TipoConta _tipo = TipoConta.arrematante;
  bool _termos = false;
  bool _informativos = false;
  bool _pj = false;
  bool _mostrarSenha = false;
  String? _sexo;
  String? _estadoCivil;
  String? _uf;

  TextEditingController _ctrl(String chave) =>
      _campos.putIfAbsent(chave, () => TextEditingController());

  @override
  void dispose() {
    for (final c in _campos.values) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _campo(String rotulo, {String? chave, bool opcional = false,
      bool email = false, bool senha = false, bool numero = false,
      int linhas = 1, String? dica}) {
    final id = chave ?? rotulo;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: _ctrl(id),
        maxLines: linhas,
        obscureText: senha && !_mostrarSenha,
        keyboardType: email ? TextInputType.emailAddress :
            numero ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: opcional ? '$rotulo (opcional)' : rotulo,
          helperText: dica,
          border: const OutlineInputBorder(),
        ),
        validator: (v) {
          final valor = v?.trim() ?? '';
          if (valor.isEmpty) return opcional ? null : 'Campo obrigatório';
          if (email && !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(valor)) {
            return 'E-mail inválido';
          }
          if (senha && valor.length < 8) return 'Use pelo menos 8 caracteres';
          if (id == 'CPF' && valor.replaceAll(RegExp(r'\D'), '').length != 11) {
            return 'CPF deve conter 11 dígitos';
          }
          if (id == 'CEP' && valor.replaceAll(RegExp(r'\D'), '').length != 8) {
            return 'CEP deve conter 8 dígitos';
          }
          if (id == 'Data de nascimento' &&
              !RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(valor)) {
            return 'Use DD/MM/AAAA';
          }
          if (id == 'Confirmar senha' && valor != _ctrl('Senha').text) {
            return 'As senhas não coincidem';
          }
          return null;
        },
      ),
    );
  }

  Widget _opcoes(String rotulo, String? valor, List<String> opcoes,
      ValueChanged<String?> onChanged) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DropdownButtonFormField<String>(
      initialValue: valor,
      isExpanded: true,
      decoration: InputDecoration(labelText: rotulo, border: const OutlineInputBorder()),
      items: opcoes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'Selecione uma opção' : null,
    ),
  );

  Widget _secao(String titulo, List<Widget> filhos, {bool aberta = false}) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: ExpansionTile(
      initiallyExpanded: aberta,
      title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
      childrenPadding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      children: filhos,
    ),
  );

  Widget _documentos(String titulo, List<String> nomes) => _secao(titulo, [
    const Text('Documentos exigidos para a análise. O envio de arquivos será '
        'habilitado somente após a integração com armazenamento privado.'),
    const SizedBox(height: 8),
    ...nomes.map((n) => ListTile(
      dense: true, contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.description_outlined),
      title: Text(n),
      trailing: const Text('Pendente', style: TextStyle(fontSize: 12)),
    )),
  ]);

  List<Widget> _acesso() => [
    _campo('Nome de usuário', dica: 'Será usado como alternativa ao e-mail no login'),
    _campo('E-mail', email: true),
    _campo('Senha', senha: true),
    _campo('Confirmar senha', senha: true),
    CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      value: _mostrarSenha,
      onChanged: (v) => setState(() => _mostrarSenha = v ?? false),
      title: const Text('Mostrar senhas'),
      controlAffinity: ListTileControlAffinity.leading,
    ),
  ];

  List<Widget> _contatos() => [
    _campo('Telefone', opcional: true),
    _campo('Celular'),
    _campo('Telefone para recado'),
  ];

  List<Widget> _arrematante() => [
    _secao('1. Dados de acesso', _acesso(), aberta: true),
    _secao('2. Dados pessoais', [
      _campo('Nome completo'),
      _campo('RG'),
      _campo('Órgão expedidor'),
      _campo('CPF'),
      _opcoes('Sexo', _sexo, ['Feminino', 'Masculino', 'Outro', 'Prefiro não informar'],
          (v) => setState(() => _sexo = v)),
      _opcoes('Estado civil', _estadoCivil,
          ['Solteiro(a)', 'Casado(a)', 'Divorciado(a)', 'Viúvo(a)', 'União estável', 'Outro'],
          (v) => setState(() => _estadoCivil = v)),
      _campo('Nacionalidade'),
      _campo('Data de nascimento', dica: 'DD/MM/AAAA'),
      _campo('Nome completo do pai'),
      _campo('Nome completo da mãe'),
      _campo('Profissão'),
    ]),
    _secao('3. Contatos', _contatos()),
    _secao('4. Endereço', [
      _campo('CEP'),
      _campo('Endereço/Rua'),
      _campo('Bairro'),
      _campo('Número'),
      _campo('Complemento', opcional: true),
      _opcoes('Estado', _uf, const [
        'AC','AL','AP','AM','BA','CE','DF','ES','GO','MA','MT','MS','MG',
        'PA','PB','PR','PE','PI','RJ','RN','RS','RO','RR','SC','SP','SE','TO'
      ], (v) => setState(() => _uf = v)),
      _campo('Cidade'),
    ]),
    _documentos('5. Documentos para verificação', const [
      'RG - frente', 'RG - verso', 'CPF', 'Comprovante de residência',
    ]),
    _secao('6. Preferências e condições', [
      CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        value: _informativos,
        onChanged: (v) => setState(() => _informativos = v ?? false),
        title: const Text('Desejo receber informativos por e-mail'),
        subtitle: const Text('Opcional. Não inclui notificações essenciais '
            'sobre arrematações, pagamentos e retirada.'),
        controlAffinity: ListTileControlAffinity.leading,
      ),
      _termosWidget(),
    ]),
  ];

  Widget _termosWidget() => CheckboxListTile(
    contentPadding: EdgeInsets.zero,
    value: _termos,
    onChanged: (v) => setState(() => _termos = v ?? false),
    title: const Text('Li e concordo com as Regras e Condições'),
    subtitle: const Text('O texto oficial dos termos deverá ser disponibilizado '
        'antes do cadastro real.'),
    controlAffinity: ListTileControlAffinity.leading,
  );

  List<Widget> _leiloeiro() => [
    _secao('1. Dados de acesso', _acesso(), aberta: true),
    _secao('2. Identificação e contatos', [
      _campo('Nome completo'),
      _campo('CPF'),
      ..._contatos(),
    ]),
    _secao('3. Registro profissional', [
      _campo('Número da matrícula/registro na Junta Comercial'),
      _opcoes('UF da matrícula', _uf, const [
        'AC','AL','AP','AM','BA','CE','DF','ES','GO','MA','MT','MS','MG',
        'PA','PB','PR','PE','PI','RJ','RN','RS','RO','RR','SC','SP','SE','TO'
      ], (v) => setState(() => _uf = v)),
    ]),
    _documentos('4. Identificação pessoal - documentos', const [
      'RG e CPF ou CNH (frente e verso)',
      'Comprovante de residência atualizado em nome próprio',
      'Foto recente ou selfie com documento',
    ]),
    _documentos('5. Matrícula e certidões', const [
      'Certidão de Matrícula de Leiloeiro Oficial',
      'Certidão Negativa Criminal Federal',
      'Certidão Negativa Criminal Estadual',
      'Certidão Cível dos últimos 5 anos',
      'Certidões negativas ou de quitação de débitos',
    ]),
    _secao('6. Atuação como pessoa jurídica', [
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Atuo por meio de pessoa jurídica'),
        value: _pj,
        onChanged: (v) => setState(() => _pj = v),
      ),
      if (_pj) ...[
        _campo('CNPJ'),
        _campo('Razão social'),
        const Text('Documentos exigidos: cartão CNPJ ativo, contrato social '
            'e última alteração, documentos dos sócios administradores.'),
        const SizedBox(height: 8),
        const Text('Anexos serão habilitados em uma etapa posterior.'),
      ],
    ]),
    _secao('7. Contrato e dados financeiros', [
      const Text('Contrato de prestação de serviços / termo de adesão '
          'assinado: envio pendente de implementação.'),
      const SizedBox(height: 12),
      const Text('Dados bancários para repasses serão coletados '
          'posteriormente em ambiente seguro, após a verificação.'),
      const SizedBox(height: 12),
      _termosWidget(),
    ]),
  ];

  void _validar() {
    final valido = _formKey.currentState?.validate() ?? false;
    if (!_termos) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('É necessário aceitar as Regras e Condições.'),
      ));
      return;
    }
    if (!valido) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Revise os campos obrigatórios. Abra as seções para corrigir os erros.'),
      ));
      return;
    }
    showDialog<void>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Validação demonstrativa'),
      content: const Text('Os campos visíveis foram validados. Nenhuma conta '
          'foi criada e nenhum dado foi salvo ou enviado. O cadastro real '
          'dependerá de autenticação, verificação documental e termos oficiais.'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx),
          child: const Text('Entendi'))],
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Cadastro de usuários')),
    body: Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('Crie sua conta',
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Formulário demonstrativo. Não use dados pessoais reais.'),
          const SizedBox(height: 18),
          SegmentedButton<TipoConta>(
            segments: const [
              ButtonSegment(value: TipoConta.arrematante,
                  label: Text('Arrematante'), icon: Icon(Icons.person_outline)),
              ButtonSegment(value: TipoConta.leiloeiro,
                  label: Text('Leiloeiro'), icon: Icon(Icons.gavel)),
            ],
            selected: {_tipo},
            onSelectionChanged: (v) => setState(() {
              _tipo = v.first;
              _termos = false;
              _uf = null;
            }),
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_tipo == TipoConta.arrematante) ..._arrematante()
                else ..._leiloeiro(),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: _validar,
                  icon: const Icon(Icons.fact_check_outlined),
                  label: const Text('Validar formulário (demonstração)'),
                ),
                const SizedBox(height: 12),
                const Text('Documentos, aprovação, pagamento e notificações '
                    'serão implementados nas próximas etapas.',
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ]),
      ),
    )),
  );
}
