class AppUser {
  const AppUser({
    required this.id,
    required this.login,
    required this.password,
    this.birthday,
    this.address = '',
    this.postalCode = '',
    this.city = '',
  });

  final String id;
  final String login;
  final String password;
  final DateTime? birthday;
  final String address;
  final String postalCode;
  final String city;

  AppUser copyWith({
    String? password,
    DateTime? birthday,
    String? address,
    String? postalCode,
    String? city,
  }) {
    return AppUser(
      id: id,
      login: login,
      password: password ?? this.password,
      birthday: birthday ?? this.birthday,
      address: address ?? this.address,
      postalCode: postalCode ?? this.postalCode,
      city: city ?? this.city,
    );
  }
}
