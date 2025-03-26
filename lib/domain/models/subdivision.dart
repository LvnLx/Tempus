class Subdivision {
  int option;
  double volume;

  Subdivision({required this.option, required this.volume});

  Map<String, dynamic> toJson() => {"option": option, "volume": volume};

  static Subdivision fromJson(Map<String, dynamic> json) =>
      Subdivision(option: json["option"], volume: json["volume"]);
}
