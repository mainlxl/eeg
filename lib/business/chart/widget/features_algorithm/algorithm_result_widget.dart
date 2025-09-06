import 'dart:convert';
import 'dart:typed_data';

import 'package:eeg/business/chart/dialog/features_algorithm_dialog.dart';
import 'package:eeg/business/chart/mode/channel_alagorithm.dart';
import 'package:eeg/business/chart/viewmodel/chart_line_view_model.dart';
import 'package:eeg/common/widget/loading_status_page.dart';
import 'package:eeg/core/network/http_service.dart';
import 'package:fluent_ui/fluent_ui.dart';
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
          algorithmDatum, algorithmFeature, parentViewModel, rootViewModel),
      buildPageContent: (BuildContext context, AlgorithmResultViewModel vm) {
        return vm.resultImageSvg != null
            ? SvgMemoryZoomable(svgData: vm.resultImageSvg!)
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

  AlgorithmResultViewModel(this.algorithmDatum, this.algorithmFeature,
      this.parentViewModel, this.rootViewModel);

  @override
  void onClickRetryLoadingData() => _rawLoadData();
  Uint8List? resultImageSvg;

  @override
  void init() async {
    setPageStatus(PageStatus.loading);
    var rawLoadData = await _rawLoadData();
    final resultImageBase64 =
        rawLoadData.data['patient_evaluate_feature_option']['feature_items'][0]
            ['feature_data']['result_svg'][0];
    resultImageSvg =
        resultImageBase64 != null ? base64Decode(resultImageBase64) : null;
    if (resultImageSvg != null) {
      setPageStatus(PageStatus.loadingSuccess);
    } else {
      setPageStatus(PageStatus.empty);
    }
  }

  Future<ResponseData> _rawLoadData() async {
    var channelMeta = rootViewModel.channelMeta;
    var data = {
      'data_filter_info_data': {
        "data_id": channelMeta.dataId,
        'channels': channelMeta.channels?.join(','),
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

class SvgMemoryZoomable extends StatefulWidget {
  final Uint8List svgData; // 假设这是 SVG 字符串数据
  const SvgMemoryZoomable({super.key, required this.svgData});

  @override
  _SvgMemoryZoomableState createState() => _SvgMemoryZoomableState();
}

class _SvgMemoryZoomableState extends State<SvgMemoryZoomable> {
  // 可以根据需要调整 InteractiveViewer 的初始值
  final TransformationController _transformationController =
      TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 0.1,
        maxScale: 20.0,
        scaleEnabled: true,
        panEnabled: true,
        boundaryMargin: const EdgeInsets.all(80.0),
        clipBehavior: Clip.hardEdge,
        onInteractionEnd: (details) {},
        onInteractionStart: (details) {},
        onInteractionUpdate: (details) {},
        child: SvgPicture.memory(
          widget.svgData,
          fit: BoxFit.contain,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 重置缩放和平移到初始状态
          _transformationController.value = Matrix4.identity();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
