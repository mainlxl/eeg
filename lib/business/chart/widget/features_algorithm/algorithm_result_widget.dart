import 'dart:convert';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:eeg/business/chart/dialog/base_close_dialog.dart';
import 'package:eeg/business/chart/dialog/features_algorithm_dialog.dart';
import 'package:eeg/business/chart/mode/channel_alagorithm.dart';
import 'package:eeg/business/chart/viewmodel/chart_line_view_model.dart';
import 'package:eeg/common/widget/loading_status_page.dart';
import 'package:eeg/core/network/http_service.dart';
import 'package:eeg/core/utils/toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AlgorithmResultWidget extends ItemContainerWidget {
  final AlgorithmFeature algorithmFeature;
  final AlgorithmDatum algorithmDatum;
  final AlgorithmViewModel parentViewModel;
  final ChartLineViewModel rootViewModel;

  AlgorithmResultWidget({
    required this.algorithmDatum,
    required this.algorithmFeature,
    required this.parentViewModel,
    required this.rootViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingPageStatusWidget(
      createOrGetViewMode: () => AlgorithmResultViewModel(
          algorithmDatum,
          algorithmFeature,
          parentViewModel,
          rootViewModel,
          actionButtonsController),
      buildPageContent: (BuildContext context, AlgorithmResultViewModel vm) {
        return vm.resultImageSvg != null
            ? InteractiveViewer(
                transformationController: vm.imageTransformationController,
                minScale: 0.1,
                maxScale: 20.0,
                scaleEnabled: true,
                panEnabled: true,
                clipBehavior: Clip.hardEdge,
                onInteractionEnd: (details) {},
                onInteractionStart: (details) {},
                onInteractionUpdate: (details) {},
                child:
                    SvgPicture.memory(vm.resultImageSvg!, fit: BoxFit.contain),
              )
            : Container();
      },
    );
  }
}

class AlgorithmResultViewModel extends LoadingPageStatusViewModel {
  final AlgorithmDatum algorithmDatum;
  final AlgorithmFeature algorithmFeature;
  final AlgorithmViewModel parentViewModel;
  final ChartLineViewModel rootViewModel;
  final DialogActionsController? actionButtonsController;
  Uint8List? resultImageSvg;
  String? resultInfo;
  final TransformationController imageTransformationController =
      TransformationController();

  AlgorithmResultViewModel(this.algorithmDatum, this.algorithmFeature,
      this.parentViewModel, this.rootViewModel, this.actionButtonsController);

  @override
  void onClickRetryLoadingData() => _rawLoadData();

  @override
  void init() async {
    setPageStatus(PageStatus.loading);
    var rawLoadData = await _rawLoadData();

    final result = rawLoadData.data['patient_evaluation_feature']?[0];
    resultInfo =
        '${result['data_type']}-类别(${algorithmDatum.category})-算法(${algorithmFeature.name})-参数(${algorithmFeature.parameters.join(',')})';
    var resultImageBase64 = (result['feature_items']?[0]?['feature_data']?[0]
            ?['result_svg']?[0]) as String? ??
        '';
    if (resultImageBase64.startsWith('data:image/svg+xml;base64,')) {
      final split = resultImageBase64.split(',');
      resultImageBase64 = split.length > 1 ? split[1] : '';
    }
    resultImageSvg =
        resultImageBase64.isNotEmpty ? base64Decode(resultImageBase64) : null;
    if (resultImageSvg != null) {
      setPageStatus(PageStatus.loadingSuccess);
      actionButtonsController?.notifyActionWidgets([
        fluent.Button(
          onPressed: onClickSaveResult,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: const Text('下载结果'),
          ),
        ),
        const SizedBox(width: 8),
        fluent.Button(
            onPressed: onClickResetImage,
            child: const Padding(
              padding: const EdgeInsets.all(2),
              child: const Text('恢复默认大小'),
            )),
      ]);
    } else {
      setPageStatus(PageStatus.empty);
    }
  }

  void onClickSaveResult() async {
    var filename =
        '${DateFormat('yyyyMMdd-HH_mm_ss').format(DateTime.now())}-${resultInfo}';
    if (filename.length > 240) {
      filename = '${filename.substring(0, 240)}……';
    }
    try {
      final saveFile = await FilePicker.platform.saveFile(
          dialogTitle: '保存结果SVG文件',
          fileName: '$filename.svg',
          bytes: resultImageSvg);
      if (saveFile != null) {
        '文件下载成功: $saveFile'.toast;
      }
    } catch (e) {
      '文件下载失败: $e'.toast;
    }
  }

  void onClickResetImage() {
    imageTransformationController.value = Matrix4.identity();
  }

  Future<ResponseData> _rawLoadData() async {
    final channelMeta = rootViewModel.channelMeta;
    final data = {
      'patient_evalution_data': {
        "data_type": channelMeta.dataType,
        "data_id": channelMeta.dataId,
        "patient_evaluation_id": channelMeta.patientEvaluationId,
        'feature_algorithm': {
          'data_type': channelMeta.dataType,
          'feature_items': [
            {
              'feature_name': algorithmFeature.name,
              'feature_category': algorithmDatum.category,
              'feature_para': algorithmFeature.parameters,
            }
          ]
        }
      }
    };
    // 如果有预处理算法 则捎带上
    final list = rootViewModel.getPreporcessingParam();
    if (list.isNotEmpty) {
      data['patient_evalution_data']?['preprocess_algorithm'] = list.isNotEmpty
          ? List<dynamic>.from(list.map((x) => x.toJson()))
          : [];
    }
    return HttpService.post('/api/v2/feature/evaluate', data: data);
  }
}
