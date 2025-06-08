class JenisTransaksi {
  final int id;
  final String trxName;
  final int trxMultiply;

  JenisTransaksi({
    required this.id,
    required this.trxName,
    required this.trxMultiply,
  });

  factory JenisTransaksi.fromJson(Map<String, dynamic> json) {
    return JenisTransaksi(
      id: json['id'],
      trxName: json['trx_name'],
      trxMultiply: json['trx_multiply'],
    );
  }
}