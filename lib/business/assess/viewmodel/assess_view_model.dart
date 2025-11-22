import 'dart:async' show Timer;

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
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:media_kit/media_kit.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AssessViewModel extends LoadingPageStatusViewModel {
  final PanePageController controller = PanePageController();
  final Patient patient;
  final AssessCategory _selectedCategory;
  final AssessSubCategory _selectedSubCategory;
  final AssessInspectionPoint _assessInspectionPoint;
  late final AssessData data;
  Timer? timerSingleRun;
  Timer? timerIntermittent;
  int patientEvaluationId = 0;
  bool enableUploadData = false;

  var timeSingleRun = Duration(seconds: 10);
  var timeIntermittent = Duration(seconds: 5);
  var imageCount = 8;
  var currentImageCount = 0;
  bool _isImageTimerIntermittent = false;

  bool get isImageTimerIntermittent => _isImageTimerIntermittent;

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
      final firstOrNull = data.dataList.firstOrNull;
      if (firstOrNull != null) {
        await player.open(Media('${data.dataPath}/$firstOrNull'));
        addSubscription(player.stream.completed.listen((event) {
          if (event) {
            _nextVideo();
          }
        }));
      }
    } else if (data.isGame) {
      //ignore
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => startImageAssess());
    }
    controller.onClickItem = _onClickItem;
  }

  void onGameFinish(int correctCount, int count) {
    _finishAssess();
  }

  void startImageAssess() {
    timerSingleRun?.cancel();
    timerSingleRun = Timer(timeSingleRun, _next);
    notifyListeners();
  }

  bool _onClickItem(PanePageItem item, int index) {
    if (timerSingleRun?.isActive == true) {
      controller.setSelectedIndex(index);
      startImageAssess();
      return true;
    } else if (_player != null && player.state.playing) {
      player.stop();
      player.open(Media('${data.dataPath}/${data.dataList[index]}'));
      player.play();
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    timerSingleRun?.cancel();
    timerIntermittent?.cancel();
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

  void _next() {
    void fireNext(int nextIndex) {
      timerIntermittent?.cancel();
      controller.setSelectedIndex(nextIndex);
      _isImageTimerIntermittent = true;
      timerIntermittent = Timer(timeIntermittent, () {
        _isImageTimerIntermittent = false;
        timerSingleRun = Timer(timeSingleRun, _next);
        notifyListeners();
      });
      notifyListeners();
    }

    void fireFinish() {
      _finishAssess();
    }

    int nextIndex = controller.selectedIndex + 1;
    //是否单词完成
    final isSingleFinish =
        nextIndex >= _assessInspectionPoint.data[0].dataList.length;
    if (isSingleFinish) {
      if (++currentImageCount >= imageCount) {
        fireFinish();
      } else {
        fireNext(0);
      }
    } else {
      fireNext(nextIndex);
    }
  }

  void _finishAssess({String? gameResult}) {
    enableUploadData = true;
    notifyListeners();
    showShadDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => ShadDialog.alert(
        title: Text('${patient.name}的本次评估已完成'),
        description: Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            '评估内容:[${_selectedCategory.name}]-[${_selectedSubCategory.name}]-[${gameResult ?? _assessInspectionPoint.name}]',
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
                color: Colors.blue.withValues(alpha: .4),
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

  void onClickRetryAssess() => _resetAssess();

  void _resetAssess() {
    currentImageCount = 0;
    controller.setSelectedIndex(0);
    if (data.isGame) {
      gameReset?.call();
    } else if (data.isImage) {
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
        fireEvent(UpdateOrInsertPatientEvaluateEvent(
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
  VoidCallback? gameReset;

  void onResetControlChange(VoidCallback reset) {
    gameReset = reset;
  }

  void onClickChangeFrequency(AssessData data) {
    final TextEditingController intermittentController =
        TextEditingController();
    final TextEditingController singleRunController = TextEditingController();
    final TextEditingController imageCountController = TextEditingController();
    intermittentController.text = timeIntermittent.inSeconds.toString();
    singleRunController.text = timeSingleRun.inSeconds.toString();
    imageCountController.text = imageCount.toString();
    final dialogTag = 'change_frequency_dialog';
    var isReset = true;
    SmartDialog.show(
      tag: dialogTag,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('修改参数'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: intermittentController,
                decoration: InputDecoration(labelText: '间歇时间（秒）'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: singleRunController,
                decoration: InputDecoration(labelText: '单次运行时间（秒）'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: imageCountController,
                decoration: InputDecoration(labelText: '循环次数'),
                keyboardType: TextInputType.number,
              ),
              Row(
                children: [
                  Checkbox(
                    value: isReset,
                    onChanged: (bool? value) {
                      isReset = value ?? true;
                    },
                  ),
                  Text('是否重新开始'),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('确定'),
              onPressed: () {
                timeIntermittent =
                    Duration(seconds: int.parse(intermittentController.text));
                timeSingleRun =
                    Duration(seconds: int.parse(singleRunController.text));
                imageCount = int.parse(imageCountController.text);
                if (currentImageCount > imageCount) {
                  currentImageCount = imageCount;
                }
                if (isReset) {
                  _resetAssess();
                }
                notifyListeners();
                SmartDialog.dismiss(tag: dialogTag);
              },
            ),
            TextButton(
              child: Text('取消'),
              onPressed: () {
                SmartDialog.dismiss(tag: dialogTag);
              },
            ),
          ],
        );
      },
    );
  }
}
