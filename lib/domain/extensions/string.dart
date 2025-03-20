extension StringExtensions on String {
  String capitalizeFirst() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }

  String lowerCaseFirst() {
    if (isEmpty) return this;
    return this[1].toLowerCase() + substring(1);
  }
}
