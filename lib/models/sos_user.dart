class SOSUser {
  final String id;
  final String name;
  final double lat;
  final double long;
  final String cpf;
  final String cep;
  final String uf;
  final String city;
  final String phone;
  final String email;
  final String imageURL;

  const SOSUser({
    required this.id,
    required this.name,
    required this.lat,
    required this.long,
    required this.cpf,
    required this.cep,
    required this.uf,
    required this.city,
    required this.phone,
    required this.email,
    required this.imageURL,
  });
}
