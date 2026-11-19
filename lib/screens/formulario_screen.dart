import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../models/ocorrencia.dart';
import '../providers/ocorrencia_provider.dart';
import '../utils/validators.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/section_title.dart';

/// Tela 3: formulário de cadastro e edição com validação.
/// Recebe uma [Ocorrencia] opcional: se vier preenchida, entra em modo edição.
class FormularioScreen extends StatefulWidget {
  const FormularioScreen({super.key, this.ocorrencia});

  final Ocorrencia? ocorrencia;

  @override
  State<FormularioScreen> createState() => _FormularioScreenState();
}

class _FormularioScreenState extends State<FormularioScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _tituloCtrl;
  late final TextEditingController _descricaoCtrl;
  late final TextEditingController _enderecoCtrl;
  late final TextEditingController _bairroCtrl;

  Categoria? _categoria;
  late Prioridade _prioridade;
  late StatusOcorrencia _status;
  late bool _riscoSeguranca;
  bool _confirmado = false;
  bool _salvando = false;

  /// Após a 1ª tentativa de envio, revalida enquanto o usuário digita.
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  bool get _editando => widget.ocorrencia != null;

  @override
  void initState() {
    super.initState();
    final o = widget.ocorrencia;
    _tituloCtrl = TextEditingController(text: o?.titulo ?? '');
    _descricaoCtrl = TextEditingController(text: o?.descricao ?? '');
    _enderecoCtrl = TextEditingController(text: o?.endereco ?? '');
    _bairroCtrl = TextEditingController(text: o?.bairro ?? '');
    _categoria = o?.categoria;
    _prioridade = o?.prioridade ?? Prioridade.media;
    _status = o?.status ?? StatusOcorrencia.aberta;
    _riscoSeguranca = o?.riscoSeguranca ?? false;
    _confirmado = _editando;
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descricaoCtrl.dispose();
    _enderecoCtrl.dispose();
    _bairroCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      mostrarSnack(context, 'Corrija os campos destacados', erro: true);
      return;
    }

    setState(() => _salvando = true);

    final dados = Ocorrencia(
      id: widget.ocorrencia?.id,
      titulo: _tituloCtrl.text.trim(),
      descricao: _descricaoCtrl.text.trim(),
      categoria: _categoria!,
      endereco: _enderecoCtrl.text.trim(),
      bairro: _bairroCtrl.text.trim(),
      prioridade: _prioridade,
      status: _status,
      riscoSeguranca: _riscoSeguranca,
      criadoEm: widget.ocorrencia?.criadoEm ?? DateTime.now(),
    );

    final provider = context.read<OcorrenciaProvider>();
    final sucesso = _editando
        ? await provider.atualizar(dados)
        : await provider.adicionar(dados);

    if (!mounted) return;
    setState(() => _salvando = false);

    if (sucesso) {
      mostrarSnack(
        context,
        _editando ? 'Ocorrência atualizada' : 'Ocorrência registrada',
      );
      Navigator.pop(context, true);
    } else {
      mostrarSnack(context, provider.erro ?? 'Erro ao salvar', erro: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar ocorrência' : 'Nova ocorrência'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: _autovalidate,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              const SectionTitle('Problema'),
              TextFormField(
                key: const Key('campo_titulo'),
                controller: _tituloCtrl,
                textInputAction: TextInputAction.next,
                maxLength: 60,
                decoration: const InputDecoration(
                  labelText: 'Título *',
                  hintText: 'Ex.: Buraco grande na esquina',
                ),
                validator: Validators.titulo,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Categoria>(
                key: const Key('campo_categoria'),
                initialValue: _categoria,
                decoration: const InputDecoration(labelText: 'Categoria *'),
                items: [
                  for (final c in Categoria.values)
                    DropdownMenuItem(value: c, child: Text(c.label)),
                ],
                onChanged: (v) => setState(() => _categoria = v),
                validator: (v) => v == null ? 'Selecione uma categoria' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('campo_descricao'),
                controller: _descricaoCtrl,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Descrição *',
                  alignLabelWithHint: true,
                ),
                validator: Validators.descricao,
              ),
              const SizedBox(height: 24),
              const SectionTitle('Local'),
              TextFormField(
                key: const Key('campo_endereco'),
                controller: _enderecoCtrl,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Endereço *',
                  hintText: 'Rua, número ou ponto de referência',
                ),
                validator: Validators.endereco,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('campo_bairro'),
                controller: _bairroCtrl,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(labelText: 'Bairro *'),
                validator: Validators.bairro,
              ),
              const SizedBox(height: 24),
              const SectionTitle('Gravidade'),
              SegmentedButton<Prioridade>(
                segments: [
                  for (final p in Prioridade.values)
                    ButtonSegment(value: p, label: Text(p.label)),
                ],
                selected: {_prioridade},
                onSelectionChanged: (s) =>
                    setState(() => _prioridade = s.first),
              ),
              const SizedBox(height: 12),
              Card(
                child: SwitchListTile(
                  value: _riscoSeguranca,
                  onChanged: (v) => setState(() => _riscoSeguranca = v),
                  title: const Text('Oferece risco à segurança'),
                  subtitle: const Text('Risco de acidentes, quedas ou doenças'),
                ),
              ),
              if (_editando) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<StatusOcorrencia>(
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: [
                    for (final s in StatusOcorrencia.values)
                      DropdownMenuItem(value: s, child: Text(s.label)),
                  ],
                  onChanged: (v) => setState(() => _status = v ?? _status),
                ),
              ],
              const SizedBox(height: 16),
              FormField<bool>(
                initialValue: _confirmado,
                validator: (_) => Validators.confirmacao(_confirmado),
                builder: (field) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CheckboxListTile(
                      key: const Key('campo_confirmacao'),
                      value: _confirmado,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text(
                        'Confirmo que as informações são verdadeiras',
                      ),
                      onChanged: (v) {
                        setState(() => _confirmado = v ?? false);
                        field.didChange(v);
                      },
                    ),
                    if (field.hasError)
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                          field.errorText!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: FilledButton(
              key: const Key('botao_salvar'),
              onPressed: _salvando ? null : _salvar,
              child: _salvando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _editando ? 'Salvar alterações' : 'Registrar ocorrência',
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
