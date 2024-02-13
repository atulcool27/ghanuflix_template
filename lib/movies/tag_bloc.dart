

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghanuflix/movies/ui_entity.dart';

abstract class TagSelectionEvent extends Equatable {
  const TagSelectionEvent();

  @override
  List<Object> get props => [];
}

class UpdateTagSelectionEvent extends TagSelectionEvent{
  final List<String> availableTags;
  final List<String> selectedTags;
  final Map<String, Set<VideoItem>> myMap;
  final String tag;
  final bool isSelected;
  UpdateTagSelectionEvent(this.availableTags,this.selectedTags,this.myMap,this.tag, this.isSelected);

  @override
  List<Object> get props => [availableTags,selectedTags,myMap, tag,isSelected];
}

class ReverseTagSelectionEvent extends TagSelectionEvent{
  final List<String> availableTags;
  final List<String> selectedTags;
  final List<VideoItem> vlist;
  final bool ascending;
  ReverseTagSelectionEvent(this.availableTags,this.selectedTags,this.vlist, this.ascending);

  @override
  List<Object> get props => [availableTags,selectedTags,vlist, ascending];
}

class SearchTagSelectionEvent extends TagSelectionEvent{
  final List<String> availableTags;
  final List<String> selectedTags;
  final Map<String, Set<VideoItem>> myMap;
  final String searchText;
  SearchTagSelectionEvent(this.availableTags,this.selectedTags,this.myMap, this.searchText);

  @override
  List<Object> get props => [availableTags,selectedTags,myMap, searchText];
}


abstract class TagSelectionState extends Equatable {
  TagSelectionState();

  @override
  List<Object> get props => [];
}

class UpdateTagSelectionState extends TagSelectionState{
  final List<String> availableTags;
  final List<String> selectedTags;
  final List<VideoItem> vlist;
  UpdateTagSelectionState(this.availableTags, this.selectedTags, this.vlist);

  @override
  List<Object> get props => [availableTags, selectedTags, vlist, DateTime.now().millisecondsSinceEpoch];
}

class DefaultSelectionState extends TagSelectionState{}


class TagSelectionBloc extends Bloc<TagSelectionEvent, TagSelectionState> {
  TagSelectionBloc() : super(DefaultSelectionState()){

    on<SearchTagSelectionEvent>((event, emit) {
      try{
        List<String> availableTags = <String>[];
        availableTags.addAll(event.availableTags);
        List<String> selectedTags = <String>[];
        selectedTags.addAll(event.selectedTags);

        availableTags = availableTags.where((element) => element.contains(event.searchText)).toList();

        Set<VideoItem> mySet = Set<VideoItem>();
        for(String tag in selectedTags){
          mySet.addAll(event.myMap[tag]!);
        }

        List<VideoItem> vlist = mySet.toList();

        emit(UpdateTagSelectionState(availableTags, selectedTags, vlist));
      }on Exception catch(e){
        emit(UpdateTagSelectionState(event.availableTags, event.selectedTags, <VideoItem>[]));
      }
    });

    on<UpdateTagSelectionEvent>((event, emit) {
      try{
        List<String> availableTags = <String>[];
        availableTags.addAll(event.availableTags);
        List<String> selectedTags = <String>[];
        selectedTags.addAll(event.selectedTags);

        if(event.tag.isNotEmpty){
          if(selectedTags.contains(event.tag)){
            selectedTags.remove(event.tag);
          }else{
            selectedTags.add(event.tag);
          }

        }

        Set<VideoItem> mySet = Set<VideoItem>();
        for(String tag in selectedTags){
          mySet.addAll(Set.from(event.myMap[tag]!));
        }
        List<VideoItem> vlist = mySet.toList()
          ..sort((a, b) => compareByDateTag(a.tags, b.tags,false));
        emit(UpdateTagSelectionState(availableTags, selectedTags, vlist));
      }on Exception catch(e){
        emit(UpdateTagSelectionState(event.availableTags, event.selectedTags, <VideoItem>[]));
      }

    });

    on<ReverseTagSelectionEvent>((event, emit) {
      try{
        List<VideoItem> newList = event.vlist
          ..sort((a, b) => compareByDateTag(a.tags, b.tags, event.ascending));
        emit(UpdateTagSelectionState(event.availableTags, event.selectedTags, newList));
      }on Exception catch(e){
        emit(UpdateTagSelectionState(event.availableTags, event.selectedTags, <VideoItem>[]));
      }
    },);
  }


  int compareByDateTag(List<String>? tagsA, List<String>? tagsB, bool ascendingOrder) {
    String? dateTagA = tagsA?.firstWhere(
          (tag) => RegExp(r'^\d{4}-\d{2}$').hasMatch(tag),
      orElse: () => '',
    );

    String? dateTagB = tagsB?.firstWhere(
          (tag) => RegExp(r'^\d{4}-\d{2}$').hasMatch(tag),
      orElse: () => '',
    );

    if (dateTagA != null && dateTagB != null) {
      if(ascendingOrder)
        return dateTagA.compareTo(dateTagB);
      return dateTagB.compareTo(dateTagA);
    } else if (dateTagA != '') {
      return -1;
    } else if (dateTagB != '') {
      return 1;
    } else {
      return 0; // No date tags in either set
    }
  }


}

