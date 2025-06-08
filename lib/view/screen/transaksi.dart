import 'package:flutter/material.dart';
import 'package:demo_savitrishop/utils/api_service.dart';
import 'package:demo_savitrishop/models/jenis_transaksi.dart';
import 'package:demo_savitrishop/view/screen/riwayat_transaksi.dart';

class TambahTransaksiPage extends StatefulWidget {
  final int anggotaId;

  const TambahTransaksiPage({
    Key? key,
    required this.anggotaId,
  }) : super(key: key);

  @override
  State<TambahTransaksiPage> createState() => _TambahTransaksiPageState();
}

class _TambahTransaksiPageState extends State<TambahTransaksiPage> {
  final TextEditingController nominalController = TextEditingController();

  List<JenisTransaksi> jenisTransaksiList = [];
  JenisTransaksi? selectedJenis;
  JenisTransaksi? saldoAwal;
  DateTime selectedDate = DateTime.now();
  late final int anggotaId;
  String? namaAnggota;

  @override
  void initState() {
    super.initState();
    anggotaId = widget.anggotaId;
    fetchJenisTransaksi();
    fetchNamaAnggota();
  }

  // untuk mendapatkan jenis transaksi
  Future<void> fetchJenisTransaksi() async {
    try {
      final result = await ApiService().getJenisTransaksi();

      // Cari saldo awal di data
      final _saldoAwal = result.firstWhere(
        (item) => item.trxName.toLowerCase().contains('saldo awal'),
        orElse: () => JenisTransaksi(id: 0, trxName: '', trxMultiply: 1),
      );

      setState(() {
        saldoAwal = _saldoAwal.id != 0 ? _saldoAwal : null;

        // Tampilkan SEMUA jenis transaksi, termasuk saldo awal
        jenisTransaksiList = result;

        // Set default selectedJenis
        if (saldoAwal != null) {
          selectedJenis = saldoAwal;
        } else if (jenisTransaksiList.isNotEmpty) {
          selectedJenis = jenisTransaksiList.first;
        }
      });
    } catch (e) {
      print("Gagal mengambil jenis transaksi: $e");
    }
  }

  // untuk menambahkan transaksi 
  Future<void> addTransaksiTabungan() async {
    if (selectedJenis == null || nominalController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Silakan lengkapi semua data")),
      );
      return;
    }

    final sukses = await ApiService().addTransaksiTabungan(
      anggotaId: anggotaId,
      tanggal: selectedDate.toIso8601String().split('T')[0],
      trxId: selectedJenis!.id,
      nominal: nominalController.text,
    );

    if (sukses) {
      nominalController.clear();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Sukses"),
          content: Text("Transaksi berhasil disimpan."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // tutup dialog
              },
              child: Text("Tutup"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // tutup dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RiwayatTransaksiPage(anggotaId: anggotaId)),
                );
              },
              child: Text("Lihat Riwayat"),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan transaksi")),
      );
    }
  }

  // untuk melihat detail anggota dan menampilkan nama anggota
  Future<void> fetchNamaAnggota() async {
    final nama = await ApiService().getNamaAnggotaById(anggotaId);
    setState(() {
      namaAnggota = nama;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Transaksi")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: jenisTransaksiList.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Nama Anggota", style: TextStyle(fontSize: 16)),
                  SizedBox(height: 4),
                  Text(
                    namaAnggota ?? "Memuat...",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text("Jenis Transaksi", style: TextStyle(fontSize: 16)),
                  DropdownButton<JenisTransaksi>(
                    isExpanded: true,
                    value: selectedJenis,
                    items: jenisTransaksiList.map((jenis) {
                      return DropdownMenuItem(
                        value: jenis,
                        child: Text(jenis.trxName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedJenis = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  Text("Tanggal Transaksi", style: TextStyle(fontSize: 16)),
                  SizedBox(height: 4),
                  Text(
                    selectedDate.toLocal().toString().split(' ')[0],
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: nominalController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Nominal",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: addTransaksiTabungan,
                    child: Text("Simpan Transaksi"),
                  ),
                ],
              ),
      ),
    );
  }
}
