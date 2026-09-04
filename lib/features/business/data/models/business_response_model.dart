class BusinessResponseModel {
  final String result;
  final int code;
  final int count;
  final List<dynamic> data;

  BusinessResponseModel({
    required this.result,
    required this.code,
    required this.count,
    required this.data,
  });

  factory BusinessResponseModel.fromJson(Map<String, dynamic> json) {
    var rawData = json['data'];
    List<dynamic> parsedData = [];
    
    if (rawData != null) {
      if (rawData is List) {
        parsedData = rawData;
      } else if (rawData is Map) {
        parsedData = [rawData];
      }
    }
    
    return BusinessResponseModel(
      result: json['result'] ?? '',
      code: json['code'] ?? 0,
      count: json['count'] ?? 0,
      data: parsedData,
    );
  }
}
