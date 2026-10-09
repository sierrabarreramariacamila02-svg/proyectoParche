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
      nombre: json['nombre'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      telefono: json['telefono'] as String,
      direccion: json['direccion'] as String,
      rol: json['rol'] as String? ?? 'usuario',
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


