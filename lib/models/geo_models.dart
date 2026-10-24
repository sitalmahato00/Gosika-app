class Province {
  final int id;
  final String name;

  Province({required this.id, required this.name});

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      id: json['id'],
      name: json['name'],
    );
  }
}

class District {
  final int id;
  final int provinceId;
  final String name;

  District({required this.id, required this.provinceId, required this.name});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'],
      provinceId: json['province_id'],
      name: json['name'],
    );
  }
}

class Municipality {
  final int id;
  final int districtId;
  final String name;

  Municipality({required this.id, required this.districtId, required this.name});

  factory Municipality.fromJson(Map<String, dynamic> json) {
    return Municipality(
      id: json['id'],
      districtId: json['district_id'],
      name: json['name'],
    );
  }
}
