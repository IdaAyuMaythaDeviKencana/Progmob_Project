class Member {
  final int id;
  final String nomorInduk; // field nomor induk
  final String nama;
  final String telepon;
  final String alamat;
  final String tglLahir;

  Member({
    required this.id,
    required this.nomorInduk,
    required this.nama,
    required this.telepon,
    required this.alamat,
    required this.tglLahir,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      nomorInduk: json['nomor_induk'].toString(),  // pastikan ini ada di JSON API
      nama: json['nama'],
      telepon: json['telepon'],
      alamat: json['alamat'],
      tglLahir: json['tgl_lahir'],
    );
  }
}
