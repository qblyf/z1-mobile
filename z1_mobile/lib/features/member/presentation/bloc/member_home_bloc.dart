import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/datasources/member_remote_datasource.dart';
import '../../data/models/member_model.dart';

abstract class MemberHomeEvent extends Equatable {
  const MemberHomeEvent();
  @override
  List<Object?> get props => [];
}

class MemberHomeLoadRequested extends MemberHomeEvent {
  const MemberHomeLoadRequested();
}

class MemberHomeSearchRequested extends MemberHomeEvent {
  final String keyword;
  const MemberHomeSearchRequested(this.keyword);
  @override
  List<Object?> get props => [keyword];
}

class MemberHomeClearSearch extends MemberHomeEvent {
  const MemberHomeClearSearch();
}

abstract class MemberHomeState extends Equatable {
  const MemberHomeState();
  @override
  List<Object?> get props => [];
}

class MemberHomeInitial extends MemberHomeState {
  const MemberHomeInitial();
}

class MemberHomeLoading extends MemberHomeState {
  const MemberHomeLoading();
}

class MemberHomeLoaded extends MemberHomeState {
  final List<MemberModel> members;
  final List<MemberModel> recentMembers;
  final bool isSearchResult;
  final String searchKeyword;

  const MemberHomeLoaded({
    required this.members,
    this.recentMembers = const [],
    this.isSearchResult = false,
    this.searchKeyword = '',
  });

  MemberHomeLoaded copyWith({
    List<MemberModel>? members,
    List<MemberModel>? recentMembers,
    bool? isSearchResult,
    String? searchKeyword,
  }) {
    return MemberHomeLoaded(
      members: members ?? this.members,
      recentMembers: recentMembers ?? this.recentMembers,
      isSearchResult: isSearchResult ?? this.isSearchResult,
      searchKeyword: searchKeyword ?? this.searchKeyword,
    );
  }

  @override
  List<Object?> get props => [members, recentMembers, isSearchResult, searchKeyword];
}

class MemberHomeEmpty extends MemberHomeState {
  final String? searchKeyword;
  const MemberHomeEmpty({this.searchKeyword});
  @override
  List<Object?> get props => [searchKeyword];
}

class MemberHomeError extends MemberHomeState {
  final String message;
  const MemberHomeError(this.message);
  @override
  List<Object?> get props => [message];
}

class MemberHomeBloc extends Bloc<MemberHomeEvent, MemberHomeState> {
  final MemberRemoteDataSource _dataSource;
  Timer? _debounce;

  MemberHomeBloc({required MemberRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const MemberHomeInitial()) {
    on<MemberHomeLoadRequested>(_onLoadRequested);
    on<MemberHomeSearchRequested>(_onSearchRequested);
    on<MemberHomeClearSearch>(_onClearSearch);
  }

  Future<void> _onLoadRequested(
    MemberHomeLoadRequested event,
    Emitter<MemberHomeState> emit,
  ) async {
    emit(const MemberHomeLoading());

    final result = await _dataSource.searchByPhone('');

    if (result.isFailure) {
      emit(MemberHomeError(result.failure!.message));
      return;
    }

    final members = result.value!;
    if (members.isEmpty) {
      emit(const MemberHomeEmpty());
    } else {
      emit(MemberHomeLoaded(members: members));
    }
  }

  Future<void> _onSearchRequested(
    MemberHomeSearchRequested event,
    Emitter<MemberHomeState> emit,
  ) async {
    _debounce?.cancel();

    if (event.keyword.isEmpty) {
      add(const MemberHomeLoadRequested());
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final result = await _dataSource.searchByPhone(event.keyword);

      if (result.isFailure) {
        emit(MemberHomeError(result.failure!.message));
        return;
      }

      final members = result.value!;
      if (members.isEmpty) {
        emit(MemberHomeEmpty(searchKeyword: event.keyword));
      } else {
        emit(MemberHomeLoaded(
          members: members,
          isSearchResult: true,
          searchKeyword: event.keyword,
        ));
      }
    });
  }

  Future<void> _onClearSearch(
    MemberHomeClearSearch event,
    Emitter<MemberHomeState> emit,
  ) async {
    add(const MemberHomeLoadRequested());
  }
}