import 'package:fwidget/widgets.dart';

import 'json.dart';

class FTableRowWorkedModel extends FTableRow<WorkedModel> {
  FTableRowWorkedModel({required WorkedModel value}) : super(value: value);

  static List<String> headers() {
    return [
      '',
      'Datum',
      'Geleistete Arbeitszeit',
      '',
    ];
  }

  @override
  List<Widget> build(BuildContext context) {
    return [
      const Text("",
          textAlign: TextAlign.left,
          style: TextStyle(fontWeight: FontWeight.bold)),
      Text("${value.datum.day}.${value.datum.month}.${value.datum.year}",
          textAlign: TextAlign.left,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      Text(value.hasworked,
          textAlign: TextAlign.left,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      const Text("",
          textAlign: TextAlign.left,
          style: TextStyle(fontWeight: FontWeight.bold)),
    ];
  }

  @override
  void updateValue(WorkedModel newValue) {
    value = newValue;
  }

  @override
  bool hasSameValue(FTableRow<WorkedModel> other) {
    return value == other.value;
  }

  @override
  FTableRow<WorkedModel> clone() {
    return FTableRowWorkedModel(
      value: value.clone(),
    );
  }

  //@override
  //int compareCell(int i, FTableRow<ConvCustomConverterModel> other) {
  //  switch (i) {
  //    case 0:
  //      return Comparable.compare(value.from?.value ?? '',
  //          (other as FTableRowModel).value.from?.value ?? '');
  //    case 1:
  //      return Comparable.compare(value.to?.value ?? '',
  //          (other as FTableRowModel).value.to?.value ?? '');
  //    case 2:
  //      return Comparable.compare(
  //          value.code.value, (other as FTableRowModel).value.code.value);
  //  }
  //  return 0;
  //}
}

class WorkedModel implements FCloneable<WorkedModel> {
  WorkingDate datum;
  String hasworked;
  WorkedModel({
    required this.datum,
    required this.hasworked,
  });

  @override
  WorkedModel clone() {
    return WorkedModel(
      datum: WorkingDate(
        day: datum.day,
        month: datum.month,
        year: datum.year,
      ),
      hasworked: hasworked,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is WorkedModel) {
      return datum.day == other.datum.day &&
          datum.month == other.datum.month &&
          datum.year == other.datum.year &&
          hasworked == other.hasworked;
    }
    return false;
  }

  @override
  int get hashCode {
    return Object.hash(
      datum.day,
      datum.month,
      datum.year,
      hasworked,
    );
  }
}

String addLeadingZero(int value) {
  if (value < 10) {
    return "0$value";
  } else {
    return "$value";
  }
}
