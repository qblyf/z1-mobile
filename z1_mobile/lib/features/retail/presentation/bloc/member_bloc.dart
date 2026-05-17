import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/datasources/member_remote_datasource.dart';
import '../../data/models/member_model.dart';

abstract class MemberEvent extends Equatable {
  const MemberEvent();
  @override
  List<Object?> get props => [];
}

class MemberLoadRecentRequested extends MemberEvent {
  const MemberLoadRecentRequested();
}

class MemberSearchByPhoneRequested extends MemberEvent {
  final String phone;
  const MemberSearchByPhoneRequested(this.phone);
  @override
  List<Object?> get props => [phone];
}

class MemberSearchCleared extends MemberEvent {
  const MemberSearchCleared();
}

abstract class MemberState extends Equatable {
  const MemberState();
  @override
  List<Object?> get props => [];
}

class MemberInitial extends MemberState {
  const MemberInitial();
}

class MemberLoading extends MemberState {
  const MemberLoading();
}

class MemberLoaded extends MemberState {
  final List<MemberModel> recentMembers;
  final List<MemberModel> searchResults;
  final String? searchPhone;

  const MemberLoaded({
    this.recentMembers = const [],
    this.searchResults = const [],
    this.searchPhone,
  });

  MemberLoaded copyWith({
    List<MemberModel>? recentMembers,
    List<MemberModel>? searchResults,
    String? searchPhone,
  }) {
    return MemberLoaded(
      recentMembers: recentMembers ?? this.recentMembers,
      searchResults: searchResults ?? this.searchResults,
      searchPhone: searchPhone ?? this.searchPhone,
    );
  }

  @override
  List<Object?> get props => [recentMembers, searchResults, searchPhone];
}

class MemberError extends MemberState {
  final String message;
  const MemberError(this.message);
  @override
  List<Object?> get props => [message];
}

class MemberBloc extends Bloc<MemberEvent, MemberState> {
  final RetailMemberRemoteDataSource _dataSource;

  MemberBloc({required RetailMemberRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const MemberInitial()) {
    on<MemberLoadRecentRequested>(_onLoadRecentRequested);
    on<MemberSearchByPhoneRequested>(_onSearchByPhoneRequested);
    on<MemberSearchCleared>(_onSearchCleared);
  }

  Future<void> _onLoadRecentRequested(
    MemberLoadRecentRequested event,
    Emitter<MemberState> emit,
  ) async {
    emit(const MemberLoading());

    final result = await _dataSource.getRecentMembers();

    if (result.isFailure) {
      emit(MemberError(result.failure!.message));
      return;
    }

    emit(MemberLoaded(recentMembers: result.value!));
  }

  Future<void> _onSearchByPhoneRequested(
    MemberSearchByPhoneRequested event,
    Emitter<MemberState> emit,
  ) async {
    final currentState = state;
    List<MemberModel> recentMembers = [];

    if (currentState is MemberLoaded) {
      recentMembers = currentState.recentMembers;
    }

    if (event.phone.isEmpty) {
      emit(MemberLoaded(recentMembers: recentMembers));
      return;
    }

    final result = await _dataSource.searchMembersByPhone(event.phone);

    if (result.isFailure) {
      emit(MemberLoaded(recentMembers: recentMembers));
      return;
    }

    emit(MemberLoaded(
      recentMembers: recentMembers,
      searchResults: result.value!,
      searchPhone: event.phone,
    ));
  }

  void _onSearchCleared(
    MemberSearchCleared event,
    Emitter<MemberState> emit,
  ) {
    final currentState = state;
    if (currentState is MemberLoaded) {
      emit(currentState.copyWith(
        searchResults: [],
        searchPhone: null,
      ));
    }
  }
}