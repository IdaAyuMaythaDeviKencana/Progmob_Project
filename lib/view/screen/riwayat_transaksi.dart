import 'package:flutter/material.dart';
import 'package:demo_savitrishop/utils/api_service.dart';
import 'package:demo_savitrishop/models/jenis_transaksi.dart';

class RiwayatTransaksiPage extends StatefulWidget {
  final int anggotaId;

  const RiwayatTransaksiPage({super.key, required this.anggotaId});

  @override
  State<RiwayatTransaksiPage> createState() => _RiwayatTransaksiPageState();
}

class _RiwayatTransaksiPageState extends State<RiwayatTransaksiPage> {
  int? saldo;
  bool isLoadingSaldo = true;
  bool isLoadingTransaksi = true;
  bool isLoadingJenisTransaksi = true;

  List<Map<String, dynamic>> transaksiList = [];
  List<JenisTransaksi> jenisTransaksiList = [];

  @override
  void initState() {
    super.initState();
    loadAllData();
  }

  Future<void> loadAllData() async {
    await Future.wait([
      loadSaldo(),
      loadJenisTransaksi(),
      loadTransaksi(),
    ]);
  }

  Future<void> loadSaldo() async {
    try {
      final fetchedSaldo = await ApiService().getSaldoByAnggotaId(widget.anggotaId);
      setState(() {
        saldo = fetchedSaldo;
        isLoadingSaldo = false;
      });
    } catch (e) {
      print('Gagal ambil saldo: $e');
      setState(() => isLoadingSaldo = false);
    }
  }

  Future<void> loadJenisTransaksi() async {
    try {
      final fetchedJenis = await ApiService().getJenisTransaksi();
      setState(() {
        jenisTransaksiList = fetchedJenis;
        isLoadingJenisTransaksi = false;
      });
    } catch (e) {
      print('Gagal ambil jenis transaksi: $e');
      setState(() => isLoadingJenisTransaksi = false);
    }
  }

  Future<void> loadTransaksi() async {
    try {
      final fetchedTransaksi = await ApiService().getTransaksiByAnggotaId(widget.anggotaId);
      setState(() {
        transaksiList = fetchedTransaksi;
        isLoadingTransaksi = false;
      });
    } catch (e) {
      print('Gagal ambil transaksi: $e');
      setState(() => isLoadingTransaksi = false);
    }
  }



  // Ambil nama jenis transaksi dari trxId
  String getNamaJenisByTrxId(int trxId) {
    final jenis = jenisTransaksiList.firstWhere(
      (j) => j.id == trxId,
      orElse: () => JenisTransaksi(id: 0, trxName: 'Tidak diketahui', trxMultiply: 0),
    );
    return jenis.trxName;
  }

  // Ambil warna berdasarkan trxMultiply dari jenis transaksi
  Color getColorByTrxId(int trxId) {
    final jenis = jenisTransaksiList.firstWhere(
      (j) => j.id == trxId,
      orElse: () => JenisTransaksi(id: 0, trxName: 'Tidak diketahui', trxMultiply: 0),
    );

    if (jenis.trxMultiply == 1) return Colors.green;
    if (jenis.trxMultiply == -1) return Colors.red;
    return Colors.grey;
  }

  IconData getIconByTrxId(int trxId) {
    final jenis = jenisTransaksiList.firstWhere(
      (j) => j.id == trxId,
      orElse: () => JenisTransaksi(id: 0, trxName: 'Tidak diketahui', trxMultiply: 0),
    );

    if (jenis.trxMultiply == 1) return Icons.call_received;
    if (jenis.trxMultiply == -1) return Icons.call_made;
    return Icons.help_outline;
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = isLoadingSaldo || isLoadingTransaksi || isLoadingJenisTransaksi;

    return Scaffold(
      appBar: AppBar(title: Text('Riwayat Transaksi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Card(
                    child: ListTile(
                      title: Text("Saldo Saat Ini"),
                      subtitle: Text("Rp ${saldo ?? 0}"),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Riwayat Transaksi",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: transaksiList.isEmpty
                        ? Center(child: Text("Belum ada transaksi."))
                        : ListView.builder(
                            itemCount: transaksiList.length,
                            itemBuilder: (context, index) {
                              final trx = transaksiList[index];
                              final trxId = trx['trx_id'] ?? 0;
                              final nominal = trx['trx_nominal'] ?? 0;
                              final tanggal = trx['trx_tanggal'] ?? '';


                              final color = getColorByTrxId(trxId);
                              final icon = getIconByTrxId(trxId);
                              final namaJenis = getNamaJenisByTrxId(trxId);

                              return ListTile(
                                leading: Icon(icon, color: color),
                                title: Text(
                                  namaJenis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                                  subtitle: Text("Rp $nominal"),
                                  trailing: Text(tanggal),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
