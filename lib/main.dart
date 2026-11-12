import 'package:flutter/material.dart';

void main() => runApp(const LeilaoApp());

enum Situacao { aberto, andamento, encerrado }

class Lote {
  Lote({required this.titulo, required this.descricao, required this.inicial, required this.incremento, required this.retirada, required this.fim, required this.situacao, this.maiorLance});
  String titulo, descricao, retirada;
  double inicial, incremento;
  double? maiorLance;
  DateTime fim;
  Situacao situacao;
  double get proximo => maiorLance == null ? inicial : maiorLance! + incremento;
}

class LeilaoApp extends StatelessWidget {
  const LeilaoApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Portal de Leilões',
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF145A76)), useMaterial3: true),
    home: const InicioPage(),
  );
}

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});
  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  int aba = 0;
  Situacao? filtro;
  final lotes = <Lote>[
    Lote(titulo: 'Notebook corporativo', descricao: 'Notebook usado, vendido no estado em que se encontra.', inicial: 800, incremento: 50, retirada: 'São Paulo - SP', fim: DateTime.now().add(const Duration(hours: 4)), situacao: Situacao.andamento),
    Lote(titulo: 'Lote de móveis', descricao: 'Mesa, armário e quatro cadeiras.', inicial: 300, incremento: 25, retirada: 'Osasco - SP', fim: DateTime.now().add(const Duration(days: 2)), situacao: Situacao.aberto),
    Lote(titulo: 'Impressora multifuncional', descricao: 'Equipamento usado, sem garantia.', inicial: 150, incremento: 20, retirada: 'Barueri - SP', fim: DateTime.now().subtract(const Duration(days: 1)), situacao: Situacao.encerrado, maiorLance: 250),
  ];
  String nomeSituacao(Situacao s) => switch(s) {Situacao.aberto => 'Aberto', Situacao.andamento => 'Em andamento', Situacao.encerrado => 'Encerrado'};
  String dinheiro(double v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

  void mostrarLote(Lote lote) {
    showDialog<void>(context: context, builder: (ctx) => AlertDialog(
      title: Text(lote.titulo),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(lote.descricao), const SizedBox(height: 12),
        Text('Situação: ${nomeSituacao(lote.situacao)}'),
        Text('Lance inicial: ${dinheiro(lote.inicial)}'),
        Text('Incremento mínimo: ${dinheiro(lote.incremento)}'),
        Text('Próximo lance: ${dinheiro(lote.proximo)}'),
        Text('Retirada: ${lote.retirada}'),
        Text('Encerramento previsto: ${lote.fim.day}/${lote.fim.month}/${lote.fim.year} às ${lote.fim.hour.toString().padLeft(2, '0')}:${lote.fim.minute.toString().padLeft(2, '0')}'),
        const SizedBox(height: 12),
        const Text('Para ofertar lances reais, será necessário cadastro e habilitação pelo leiloeiro.', style: TextStyle(fontWeight: FontWeight.w600)),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fechar'))],
    ));
  }

  Future<void> criarLote() async {
    final titulo = TextEditingController();
    final descricao = TextEditingController();
    final inicial = TextEditingController();
    final incremento = TextEditingController();
    final retirada = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final criado = await showDialog<Lote>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Cadastrar lote (demonstração)'),
      content: SizedBox(width: 450, child: Form(key: formKey, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        campo(titulo, 'Título do lote'), campo(descricao, 'Descrição dos itens', linhas: 3),
        campo(inicial, 'Lance inicial (ex.: 500)'), campo(incremento, 'Incremento mínimo (ex.: 50)'), campo(retirada, 'Local de retirada'),
      ])))),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        FilledButton(onPressed: () {
          if (!formKey.currentState!.validate()) return;
          final valor = double.tryParse(inicial.text.replaceAll(',', '.'));
          final passo = double.tryParse(incremento.text.replaceAll(',', '.'));
          if (valor == null || passo == null || valor <= 0 || passo <= 0) {
            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Informe valores positivos válidos.')));
            return;
          }
          Navigator.pop(ctx, Lote(titulo: titulo.text.trim(), descricao: descricao.text.trim(), inicial: valor, incremento: passo, retirada: retirada.text.trim(), fim: DateTime.now().add(const Duration(days: 7)), situacao: Situacao.aberto));
        }, child: const Text('Salvar'))],
    ));
    titulo.dispose(); descricao.dispose(); inicial.dispose(); incremento.dispose(); retirada.dispose();
    if (criado != null && mounted) setState(() { lotes.add(criado); aba = 0; filtro = null; });
  }

  Widget campo(TextEditingController c, String rotulo, {int linhas = 1}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(controller: c, maxLines: linhas, decoration: InputDecoration(labelText: rotulo, border: const OutlineInputBorder()), validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null),
  );

  @override
  Widget build(BuildContext context) {
    final visiveis = lotes.where((l) => filtro == null || l.situacao == filtro).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Portal de Leilões'), backgroundColor: Theme.of(context).colorScheme.primaryContainer),
      body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1100), child: Padding(
        padding: const EdgeInsets.all(20), child: aba == 0 ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Explore os leilões', style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6), const Text('Protótipo demonstrativo: não recebe lances reais.'),
          const SizedBox(height: 16), Wrap(spacing: 8, runSpacing: 8, children: [
            ChoiceChip(label: const Text('Todos'), selected: filtro == null, onSelected: (_) => setState(() => filtro = null)),
            for (final s in Situacao.values) ChoiceChip(label: Text(nomeSituacao(s)), selected: filtro == s, onSelected: (_) => setState(() => filtro = s)),
          ]), const SizedBox(height: 14),
          Expanded(child: visiveis.isEmpty ? const Center(child: Text('Nenhum lote encontrado.')) : ListView.builder(itemCount: visiveis.length, itemBuilder: (context, i) {
            final l = visiveis[i];
            return Card(child: ListTile(contentPadding: const EdgeInsets.all(14), leading: const CircleAvatar(child: Icon(Icons.gavel)),
              title: Text(l.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${nomeSituacao(l.situacao)} • ${l.retirada}\nLance inicial: ${dinheiro(l.inicial)} • Incremento: ${dinheiro(l.incremento)}'),
              isThreeLine: true, trailing: const Icon(Icons.chevron_right), onTap: () => mostrarLote(l)));
          })),
        ]) : SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Painel do leiloeiro', style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10), const Text('Modo de demonstração. Na versão real, somente leiloeiros verificados terão acesso.'),
          const SizedBox(height: 20), Text('Lotes cadastrados: ${lotes.length}', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 18), FilledButton.icon(onPressed: criarLote, icon: const Icon(Icons.add), label: const Text('Cadastrar novo lote')),
          const SizedBox(height: 18), const Text('Próximas funcionalidades: verificação de leiloeiros, aprovação de arrematantes, lances em tempo real e pagamentos.'),
        ])),
      ))),
      bottomNavigationBar: NavigationBar(selectedIndex: aba, onDestinationSelected: (i) => setState(() => aba = i), destinations: const [
        NavigationDestination(icon: Icon(Icons.search), label: 'Leilões'),
        NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Painel do leiloeiro'),
      ]),
    );
  }
}
