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

    try {
      final result = await _dataSource.searchByPhone('');

      if (result.isFailure) {
        emit(const MemberHomeEmpty());
        return;
      }

      final members = result.value!;
      if (members.isEmpty) {
        emit(const MemberHomeEmpty());
      } else {
        emit(MemberHomeLoaded(members: members));
      }
    } catch (e) {
      emit(MemberHomeError(e.toString()));
    }
  }

  Future<void> _onSearchRequested(
    MemberHomeSearchRequested event,
    Emitter<MemberHomeState> emit,
  ) async {
    if (event.keyword.isEmpty) {
      add(const MemberHomeLoadRequested());
      return;
    }

    emit(MemberHomeLoaded(
      members: const [],
      isSearchResult: true,
      searchKeyword: event.keyword,
    ));

    try {
      final result = await _dataSource.searchByPhone(event.keyword);

      if (result.isFailure) {
        emit(MemberHomeEmpty(searchKeyword: event.keyword));
        return;
      }

      final members = result.value!;
      emit(MemberHomeLoaded(
        members: members,
        isSearchResult: true,
        searchKeyword: event.keyword,
      ));
    } catch (e) {
      emit(MemberHomeError(e.toString()));
    }
  }

  Future<void> _onClearSearch(
    MemberHomeClearSearch event,
    Emitter<MemberHomeState> emit,
  ) async {
    add(const MemberHomeLoadRequested());
  }
}