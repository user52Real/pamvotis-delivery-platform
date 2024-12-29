import '../core/result.dart';

abstract class BaseRepository<T> {
  Future<Result<T>> get(String id);
  Future<Result<List<T>>> getAll();
  Future<Result<void>> create(T item);
  Future<Result<void>> update(T item);
  Future<Result<void>> delete(String id);
}