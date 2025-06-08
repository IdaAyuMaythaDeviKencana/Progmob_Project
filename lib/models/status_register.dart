class StatusRegister {
  final bool status;
  final String message;

  StatusRegister({required this.status, required this.message});

  factory StatusRegister.fromJson(Map<String, dynamic> json) {
    return StatusRegister(
      status: json['success'].toString() == 'true',
      message: json['message'] ?? 'Terjadi kesalahan',
    );
  }
}
