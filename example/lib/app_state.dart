import 'package:equatable/equatable.dart';

abstract class ApiState extends Equatable {
  const ApiState();

  @override
  List<Object?> get props => [];
}
class ApiInitial extends ApiState{
  const ApiInitial();
}
class ApiLoading extends ApiState {
  const ApiLoading();
}

class ApiSuccess extends ApiState {
  final List<String> data;
  const ApiSuccess(this.data);

  @override
  List<Object?> get props => [data];
}

class ApiError extends ApiState {
  final String message;
  const ApiError(this.message);

  @override
  List<Object?> get props => [message];
}
