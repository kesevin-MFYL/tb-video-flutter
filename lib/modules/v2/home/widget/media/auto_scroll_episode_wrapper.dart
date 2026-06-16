import 'package:editvideo/models/episode_entity.dart';
import 'package:editvideo/modules/v2/home/controllers/media_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AutoScrollEpisodeWrapper extends StatefulWidget {
  final MediaDetailController controller;
  final List<dynamic> episodeList;
  final Widget Function(BuildContext context, ScrollController scrollController) builder;
  final double Function(int index, double viewportDimension) calculateOffset;

  const AutoScrollEpisodeWrapper({
    super.key,
    required this.controller,
    required this.episodeList,
    required this.builder,
    required this.calculateOffset,
  });

  @override
  State<AutoScrollEpisodeWrapper> createState() => _AutoScrollEpisodeWrapperState();
}

class _AutoScrollEpisodeWrapperState extends State<AutoScrollEpisodeWrapper> {
  late ScrollController _scrollController;
  Worker? _worker;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Listen to selectEpisode changes
    _worker = ever(widget.controller.selectEpisode, (EpisodeEntity? episode) {
      if (episode != null) {
        _scrollToEpisode(episode);
      }
    });

    // Initial scroll after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.controller.selectEpisode.value != null) {
        _scrollToEpisode(widget.controller.selectEpisode.value!);
      }
    });
  }

  void _scrollToEpisode(EpisodeEntity episode) {
    if (!_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController.hasClients) {
          _performScroll(episode);
        }
      });
      return;
    }
    _performScroll(episode);
  }

  void _performScroll(EpisodeEntity episode) {
    final index = widget.episodeList.indexOf(episode);
    if (index != -1) {
      final viewportDimension = _scrollController.position.viewportDimension;
      double offset = widget.calculateOffset(index, viewportDimension);
      offset = offset.clamp(0.0, _scrollController.position.maxScrollExtent);

      _scrollController.animateTo(offset, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  void didUpdateWidget(AutoScrollEpisodeWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.episodeList != widget.episodeList) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.controller.selectEpisode.value != null) {
          _scrollToEpisode(widget.controller.selectEpisode.value!);
        }
      });
    }
  }

  @override
  void dispose() {
    _worker?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _scrollController);
  }
}
