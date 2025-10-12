import 'dart:async' show Timer;

import 'package:eeg/app.dart';
import 'package:eeg/business/assess/mode/assess_data.dart';
import 'package:eeg/business/assess/mode/assess_record.dart';
import 'package:eeg/business/assess/page/assess_upload_page.dart';
import 'package:eeg/business/patient/mode/patient_info_mode.dart';
import 'package:eeg/business/patient/viewmodel/patient_detail_view_model.dart';
import 'package:eeg/common/widget/left_menu_page.dart';
import 'package:eeg/common/widget/loading_status_page.dart';
import 'package:eeg/core/network/http_service.dart';
import 'package:eeg/core/utils/router_utils.dart';
import 'package:eeg/core/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AssessViewModel extends LoadingPageStatusViewModel {
  final PanePageController controller = PanePageController();
  final Patient patient;
  final AssessCategory _selectedCategory;
  final AssessSubCategory _selectedSubCategory;
  final AssessInspectionPoint _assessInspectionPoint;
  late final AssessData data;
  Timer? timer;
  int patientEvaluationId = 0;

  bool enableUploadData = false;

  AssessViewModel(this.patient, this._selectedCategory,
      this._selectedSubCategory, this._assessInspectionPoint) {
    data = _assessInspectionPoint.data[0];
  }

  Player? _player;

  Player get player => _player ??= Player();

  @override
  void init() async {
    super.init();
    if (data.isVideo) {
      MediaKit.ensureInitialized();
      await player.setPlaylistMode(PlaylistMode.none);
      var firstOrNull = data.dataList.firstOrNull;
      if (firstOrNull != null) {
        await player.open(Media('${data.dataPath}/${firstOrNull}'));
        addSubscription(player.stream.completed.listen((event) {
          if (event) {
            _nextVideo();
          }
        }));
      }
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => startImageAssess());
    }
    controller.onClickItem = _onClickItem;
  }

  void startImageAssess() {
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 2), _next);
  }

  bool _onClickItem(item, index) {
    if (timer?.isActive == true) {
      controller.setSelectedIndex(index);
      startImageAssess();
      return true;
    } else if (_player != null && player.stream.playing.last == true) {
      player.stop();
      player.open(Media('${data.dataPath}/${data.dataList[index]}'));
      player.play();
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    timer?.cancel();
    _player?.stop();
    _player?.dispose();
    super.dispose();
  }

  void _nextVideo() {
    int nextIndex = controller.selectedIndex + 1;
    if (nextIndex < _assessInspectionPoint.data[0].dataList.length) {
      controller.setSelectedIndex(nextIndex);
    } else {
      _finishAssess();
    }
  }

  void _next(Timer timer) {
    int nextIndex = controller.selectedIndex + 1;
    if (nextIndex < _assessInspectionPoint.data[0].dataList.length) {
      controller.setSelectedIndex(nextIndex);
    } else {
      timer.cancel();
      _finishAssess();
    }
  }

  void _finishAssess() {
    enableUploadData = true;
    notifyListeners();
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: Text('${patient.name}的本次评估已完成'),
        description: Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            '评估内容:[${_selectedCategory.name}]-[${_selectedSubCategory.name}]-[${_assessInspectionPoint.name}]',
          ),
        ),
        actions: [
          ShadButton.destructive(
            child: const Text('关闭弹窗'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ShadButton(
            child: const Text('再次评估'),
            onPressed: () {
              context.popPage();
              onClickRetryAssess();
            },
          ),
          ShadButton(
            onPressed: () async {
              if (await onClickUploadData()) {
                context.popPage();
              }
            },
            gradient: LinearGradient(colors: [
              Colors.cyan,
              Colors.indigo,
            ]),
            shadows: [
              BoxShadow(
                color: Colors.blue.withOpacity(.4),
                spreadRadius: 4,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
            child: const Text('上传评估数据'),
          )
        ],
      ),
    );
  }

  void onClickRetryAssess() {
    controller.setSelectedIndex(0);
    if (data.isImage) {
      startImageAssess();
    } else if (data.isVideo) {
      player.stop();
      player.open(Media('${data.dataPath}/${data.dataList[0]}'));
      player.play();
    }
  }

  Future<bool> onClickUploadData() async {
    if (patientEvaluationId <= 0) {
      showLoading();
      ResponseData post =
          await HttpService.post('/api/v2/evaluation/add', data: {
        "patient_id": patient.patientId,
        'patient_evaluation': {
          'evaluate_info': {
            "evaluate_level": _selectedCategory.name,
            "evaluate_type": _selectedSubCategory.name,
            "evaluate_classification": _assessInspectionPoint.name,
            "evaluate_date": DateTime.timestamp().toIso8601String(),
          },
        }
      });
      hideLoading();
      if (post.status == 0 &&
          post.data['evaluate_list'] != null &&
          post.data['evaluate_list'].isNotEmpty &&
          post.data['evaluate_list'][0]['evaluate_info'] != null) {
        var assessRecord = AssessRecord.fromJson(
            post.data['evaluate_list'][0]['evaluate_info']);
        patientEvaluationId = assessRecord.evaluationId;
      }
      if (patientEvaluationId > 0) {
        eventBus.fire(UpdateOrInsertPatientEvaluateEvent(
            patientEvaluationId: patientEvaluationId,
            patientId: patient.patientId));
        Future.microtask(_onNextUploadData);
        return true;
      } else {
        '生成评估记录失败,请稍后重试'.showToast();
        return false;
      }
    } else {
      Future.microtask(_onNextUploadData);
      return true;
    }
  }

  void _onNextUploadData() async {
    await showShadDialog(
      context: context,
      builder: (context) => AssessUploadPage(
        patientId: patient.patientId,
        patientEvaluationId: patientEvaluationId,
      ),
    );
    context.popPage();
  }

  @override
  void onClickRetryLoadingData() {}
}
