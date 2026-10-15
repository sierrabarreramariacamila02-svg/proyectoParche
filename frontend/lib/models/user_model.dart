class UserModel {
  final String? id;
  final String nombre;
  final String email;
  final String password;
  final String telefono;
  final String direccion;
  final String rol;

  UserModel({
    this.id,
    required this.nombre,
    required this.email,
    required this.password,
    required this.telefono,
    required this.direccion,
    this.rol = 'usuario', //usuario por 
  });

  //getter util para verificar si el usuario es admin
  bool get esAdmin => rol.toLowerCase() == 'admin';

//mapea la respuestade la base de datos
    factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
    id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
    nombre: json['nombre']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    password: json['password']?.toString() ?? '', // Maneja el null cuando el backend borra el password
    telefono: json['telefono']?.toString() ?? '',
    direccion: json['direccion']?.toString() ?? '',
    rol: json['rol']?.toString() ?? 'usuario',
  );
}

//enviar al post
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'email': email,
      'password': password,
      'telefono': telefono,
      'direccion': direccion,
      'rol': rol,
    };
  }
}


