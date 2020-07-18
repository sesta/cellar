class Status {
  List<int> drinkTypeUploadCounts;

  Status(
    this.drinkTypeUploadCounts,
  );

  int get uploadCount {
    return drinkTypeUploadCounts.reduce((sum, count) => sum + count);
  }

  @override
  String toString() {
    return 'uploadCounts: $drinkTypeUploadCounts';
  }
}
