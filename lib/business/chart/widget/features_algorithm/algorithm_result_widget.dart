import 'dart:convert';
import 'dart:io';
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
import 'package:fluent_ui/fluent_ui.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
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

    final filterData = rawLoadData.data['data_filter_info_data'];
    resultInfo =
        '${filterData['data_type']}-通道(${filterData['channels']})-类别(${algorithmDatum.category})-算法(${algorithmFeature.name})-参数(${algorithmFeature.parameters.join(',')})';
    final resultImageBase64 =
        rawLoadData.data['patient_evaluate_feature_option']['feature_items'][0]
            ['feature_data']['result_svg'][0];
    resultImageSvg =
        resultImageBase64 != null ? base64Decode(resultImageBase64) : null;
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
    var channelMeta = rootViewModel.channelMeta;
    var data = {
      'data_filter_info_data': {
        "data_id": channelMeta.dataId,
        'channels': rootViewModel.channels.map((e) => e.channelName).join(','),
        "patient_evaluation_id": channelMeta.patientEvaluationId,
        "drop_rate": 1,
        "page": rootViewModel.lastPage,
        "page_size": rootViewModel.lastPageSize,
        "data_type": channelMeta.dataType,
        'data_adapters': rootViewModel.getPreporcessingParam(),
      },
      'patient_evaluate_feature_option': {
        'data_type': channelMeta.dataType,
        'feature_items': [
          {
            'feature_name': algorithmFeature.name,
            'feature_category': algorithmDatum.category,
            'feature_para': algorithmFeature.parameters,
          }
        ]
      }
    };

    return HttpService.post('/api/v1/patients/evaluate/EvaluateFeatureComputer',
        data: data);
  }
}
