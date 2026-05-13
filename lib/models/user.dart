class UserModel {
  final int id;
  final String phone;
  final String? email;
  final String? nickname;
  final String? avatarUrl;
  final bool isVip;
  final DateTime? vipExpireAt;

  UserModel({
    required this.id,
    required this.phone,
    this.email,
    this.nickname,
    this.avatarUrl,
    this.isVip = false,
    this.vipExpireAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      nickname: json['nickname'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isVip: json['is_vip'] == 1 || json['is_vip'] == true,
      vipExpireAt: json['vip_expire_at'] != null
          ? DateTime.parse(json['vip_expire_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'phone': phone,
    'email': email,
    'nickname': nickname,
    'avatar_url': avatarUrl,
    'is_vip': isVip,
    'vip_expire_at': vipExpireAt?.toIso8601String(),
  };
}
