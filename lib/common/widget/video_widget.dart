import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoWidget extends StatelessWidget {
  final Player player;
  late final controller = VideoController(player);

  VideoWidget({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Center(child: Video(controller: controller));
  }
}
