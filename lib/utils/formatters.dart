import 'package:intl/intl.dart';

class Formatters {
  const Formatters._();

  static final DateFormat _dataHora = DateFormat('dd/MM/yyyy HH:mm');

  static String dataHora(DateTime d) => _dataHora.format(d);

  static String percentual(double valor) =>
      '${(valor * 100).toStringAsFixed(0)}%';
}
