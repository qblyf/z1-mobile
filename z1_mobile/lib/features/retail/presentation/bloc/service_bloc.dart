import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/datasources/service_remote_datasource.dart';
import '../../data/models/service_model.dart';

abstract class ServiceEvent extends Equatable {
  const ServiceEvent();
  @override
  List<Object?> get props => [];
}

class ServiceLoadRequested extends ServiceEvent {
  const ServiceLoadRequested();
}

class ServiceCategoryChanged extends ServiceEvent {
  final String? category;
  const ServiceCategoryChanged(this.category);
  @override
  List<Object?> get props => [category];
}

class ServiceSearchCleared extends ServiceEvent {
  const ServiceSearchCleared();
}

abstract class ServiceState extends Equatable {
  const ServiceState();
  @override
  List<Object?> get props => [];
}

class ServiceInitial extends ServiceState {
  const ServiceInitial();
}

class ServiceLoading extends ServiceState {
  const ServiceLoading();
}

class ServiceLoaded extends ServiceState {
  final List<ServiceModel> services;
  final List<ServiceModel> filteredServices;
  final List<ServiceCategoryModel> categories;
  final String? currentCategory;

  const ServiceLoaded({
    required this.services,
    required this.filteredServices,
    this.categories = const [],
    this.currentCategory,
  });

  ServiceLoaded copyWith({
    List<ServiceModel>? services,
    List<ServiceModel>? filteredServices,
    List<ServiceCategoryModel>? categories,
    String? currentCategory,
  }) {
    return ServiceLoaded(
      services: services ?? this.services,
      filteredServices: filteredServices ?? this.filteredServices,
      categories: categories ?? this.categories,
      currentCategory: currentCategory ?? this.currentCategory,
    );
  }

  @override
  List<Object?> get props => [services, filteredServices, categories, currentCategory];
}

class ServiceError extends ServiceState {
  final String message;
  const ServiceError(this.message);
  @override
  List<Object?> get props => [message];
}

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final ServiceRemoteDataSource _dataSource;

  ServiceBloc({required ServiceRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const ServiceInitial()) {
    on<ServiceLoadRequested>(_onLoadRequested);
    on<ServiceCategoryChanged>(_onCategoryChanged);
  }

  Future<void> _onLoadRequested(
    ServiceLoadRequested event,
    Emitter<ServiceState> emit,
  ) async {
    emit(const ServiceLoading());

    final result = await _dataSource.getServiceSelectBase();

    if (result.isFailure) {
      emit(ServiceError(result.failure!.message));
      return;
    }

    final data = result.value!;
    emit(ServiceLoaded(
      services: data.services,
      filteredServices: data.services,
      categories: data.categories,
    ));
  }

  void _onCategoryChanged(
    ServiceCategoryChanged event,
    Emitter<ServiceState> emit,
  ) {
    final currentState = state;
    if (currentState is ServiceLoaded) {
      final filtered = _filterServices(
        currentState.services,
        event.category,
      );
      emit(currentState.copyWith(
        filteredServices: filtered,
        currentCategory: event.category,
      ));
    }
  }

  List<ServiceModel> _filterServices(
    List<ServiceModel> services,
    String? category,
  ) {
    return services.where((s) {
      final matchCategory = category == null || category == '全部' || s.categoryName == category;
      return matchCategory;
    }).toList();
  }
}