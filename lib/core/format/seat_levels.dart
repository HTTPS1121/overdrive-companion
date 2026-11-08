const seatLevelLabelsHe = ['כבוי', 'נמוך', 'גבוה'];

String seatLevelLabelHe(int level) {
  final i = level.clamp(0, seatLevelLabelsHe.length - 1);
  return seatLevelLabelsHe[i];
}

String celsiusLabelHe(num temp) => '${temp.round()} מעלות צלזיוס';
