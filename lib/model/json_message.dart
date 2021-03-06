import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
part 'json_message.g.dart';

abstract class JsonMessage {
  Map<String, dynamic> toJson();
  String toJsonString() {
    return jsonEncode(toJson());
  }
}

@JsonSerializable()
class SetPicture extends JsonMessage {
  final String filepath;

  SetPicture({this.filepath});

  factory SetPicture.fromJson(Map<String, dynamic> json) =>
      _$SetPictureFromJson(json);

  Map<String, dynamic> toJson() => _$SetPictureToJson(this);
}

@JsonSerializable()
class ShowPoint extends JsonMessage {
  final bool showPoint;

  ShowPoint(this.showPoint);

  factory ShowPoint.fromJson(Map<String, dynamic> json) =>
      _$ShowPointFromJson(json);

  Map<String, dynamic> toJson() => _$ShowPointToJson(this);
}

@JsonSerializable()
class GenerateHeatMap extends JsonMessage {
  GenerateHeatMap();

  factory GenerateHeatMap.fromJson(Map<String, dynamic> json) =>
      _$GenerateHeatMapFromJson(json);

  Map<String, dynamic> toJson() => _$GenerateHeatMapToJson(this);
}

@JsonSerializable()
class SkyBoxUpdate extends JsonMessage {
  final String filepath;

  SkyBoxUpdate({this.filepath});

  factory SkyBoxUpdate.fromJson(Map<String, dynamic> json) =>
      _$SkyBoxUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$SkyBoxUpdateToJson(this);
}

@JsonSerializable()
class GazeData extends JsonMessage {
  final double x;
  final double y;
  final int timestamp;

  GazeData({this.x, this.y, this.timestamp});

  factory GazeData.fromJson(Map<String, dynamic> json) =>
      _$GazeDataFromJson(json);

  Map<String, dynamic> toJson() => _$GazeDataToJson(this);
}

@JsonSerializable()
class ClientConnected extends JsonMessage {
  final String name;

  ClientConnected({this.name});

  factory ClientConnected.fromJson(Map<String, dynamic> json) =>
      _$ClientConnectedFromJson(json);

  Map<String, dynamic> toJson() => _$ClientConnectedToJson(this);
}

@JsonSerializable()
class ScreenUpdate extends JsonMessage {
  final bool fulscreen;

  ScreenUpdate({this.fulscreen});

  factory ScreenUpdate.fromJson(Map<String, dynamic> json) =>
      _$ScreenUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$ScreenUpdateToJson(this);
}

@JsonSerializable()
class PictureOffset extends JsonMessage {
  final double x;
  final double y;
  final double z;

  PictureOffset(this.x, this.y, this.z);

  factory PictureOffset.fromJson(Map<String, dynamic> json) =>
      _$PictureOffsetFromJson(json);

  Map<String, dynamic> toJson() => _$PictureOffsetToJson(this);
}
