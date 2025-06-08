import 'package:flutter/material.dart';
import 'package:demo_savitrishop/models/member.dart';
import 'package:demo_savitrishop/utils/api_service.dart';
import 'package:demo_savitrishop/utils/token_helper.dart';
import 'package:demo_savitrishop/view/screen/riwayat_transaksi.dart';
import 'package:demo_savitrishop/view/screen/transaksi.dart';

class TabunganMember extends StatefulWidget {
  const TabunganMember({Key? key}) : super(key: key);

  @override
  State<TabunganMember> createState() => _TabunganMemberState();
}

class _TabunganMemberState extends State<TabunganMember> {
  final ApiService apiService = ApiService();

  Future<List<Member>> fetchMembers() async {
    final token = await TokenHelper.getToken();

    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }

    final response = await apiService.getMembers();

    if (response == null || response.statusCode != 200) {
      throw Exception('Gagal memuat data anggota.');
    }

    final List<dynamic> membersJson = response.data['data']['anggotas'];
    return membersJson.map((json) => Member.fromJson(json)).toList();
  }

  Future<int> fetchSaldo(int anggotaId) async {
    try {
      return await apiService.getSaldoByAnggotaId(anggotaId);
    } catch (e) {
      print('Gagal ambil saldo: $e');
      return 0;
    }
  }


  void _refreshMembers() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, //untuk tidak balik ke halaman sebelumnya
        title: Text('Detail Tabungan Member'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshMembers,
          ),
        ],
      ),
      body: FutureBuilder<List<Member>>(
        future: fetchMembers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Belum ada member.'));
          }

          final memberList = snapshot.data!;

          return ListView.builder(
            itemCount: memberList.length,
            itemBuilder: (context, index) {
              final member = memberList[index];

              return FutureBuilder<int>(
                future: fetchSaldo(member.id),
                builder: (context, saldoSnapshot) {
                  final saldo = saldoSnapshot.data?.toStringAsFixed(2) ?? '...';

                  return ListTile(
                    title: Text(member.nama),
                    subtitle: Text('Saldo: Rp $saldo'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.history, color: Colors.deepOrange),
                          tooltip: 'Riwayat Transaksi',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RiwayatTransaksiPage(
                                  anggotaId: member.id,
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.attach_money, color: Colors.green),
                          tooltip: 'Tambah Transaksi',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TambahTransaksiPage(
                                  anggotaId: member.id,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
