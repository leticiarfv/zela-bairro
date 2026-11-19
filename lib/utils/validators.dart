/// Validações reutilizáveis dos campos do formulário.
/// Retornam `null` quando o valor é válido ou a mensagem de erro.
class Validators {
  const Validators._();

  static String? obrigatorio(
    String? valor, {
    String campo = 'Campo',
    bool feminino = false,
  }) {
    if (valor == null || valor.trim().isEmpty) {
      return '$campo é ${feminino ? 'obrigatória' : 'obrigatório'}';
    }
    return null;
  }

  static String? titulo(String? valor) {
    final erro = obrigatorio(valor, campo: 'Título');
    if (erro != null) return erro;
    final tamanho = valor!.trim().length;
    if (tamanho < 5) return 'Título deve ter pelo menos 5 caracteres';
    if (tamanho > 60) return 'Título deve ter no máximo 60 caracteres';
    return null;
  }

  static String? descricao(String? valor) {
    final erro = obrigatorio(valor, campo: 'Descrição', feminino: true);
    if (erro != null) return erro;
    if (valor!.trim().length < 15) {
      return 'Descreva melhor o problema (mínimo 15 caracteres)';
    }
    return null;
  }

  static String? endereco(String? valor) {
    final erro = obrigatorio(valor, campo: 'Endereço');
    if (erro != null) return erro;
    if (!RegExp(r'[A-Za-zÀ-ú]').hasMatch(valor!)) {
      return 'Informe um endereço válido (rua, número)';
    }
    return null;
  }

  static String? bairro(String? valor) {
    final erro = obrigatorio(valor, campo: 'Bairro');
    if (erro != null) return erro;
    if (valor!.trim().length < 3) return 'Bairro inválido';
    return null;
  }

  static String? confirmacao(bool? marcado) {
    if (marcado != true) {
      return 'Confirme que as informações são verdadeiras';
    }
    return null;
  }
}
