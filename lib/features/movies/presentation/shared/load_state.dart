import 'package:equatable/equatable.dart';

sealed class LoadState<T> extends Equatable {
  const LoadState();

  @override
  List<Object?> get props => [];
}

final class LoadInitial<T> extends LoadState<T> {
  const LoadInitial();
}

final class LoadInProgress<T> extends LoadState<T> {
  const LoadInProgress();
}

final class LoadSuccess<T> extends LoadState<T> {
  const LoadSuccess(this.data);

  final T data;

  @override
  List<Object?> get props => [data];
}

final class LoadFailure<T> extends LoadState<T> {
  const LoadFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
