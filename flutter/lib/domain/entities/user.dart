class User {
  String id;
  String name;

  User(
      this.id,
      this.name,
  );

  @override
  String toString() {
    return 'id: ${this.id}, name: ${this.name}';
  }
}