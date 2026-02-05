class Player {
  final String id;
  final String name;
  final String team;
  final int number;
  final String position;
  final String nationality;
  final String? imageUrl;
  final int goals;
  final int assists;
  final double rating;

  Player({
    required this.id,
    required this.name,
    required this.team,
    required this.number,
    required this.position,
    required this.nationality,
    this.imageUrl,
    this.goals = 0,
    this.assists = 0,
    this.rating = 0.0,
  });
}
