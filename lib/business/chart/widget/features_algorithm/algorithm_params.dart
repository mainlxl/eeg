// import 'package:eeg/business/chart/mode/channel_alagorithm.dart';
// import 'package:eeg/business/chart/mode/params.dart';
// import 'package:eeg/common/app_colors.dart';
// import 'package:flutter/material.dart';
//
// class AlgorithmParametersWidget extends StatelessWidget {
//   final PreporcessingAlgorithm data;
//   final int index;
//   final Function(int, PreporcessingAlgorithm) onClick;
//
//   AlgorithmParametersWidget(
//       {required this.index, required this.data, required this.onClick})
//       : super(key: Key('$index'));
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           TextButton(
//             onPressed: () => onClick(index, data),
//             child: Row(
//               children: [
//                 ReorderableDragStartListener(
//                     index: index,
//                     child: Icon(Icons.featured_play_list,
//                         color: data.checked ? iconColor : subtitleColor)),
//                 SizedBox(width: 10),
//                 Text(data.des,
//                     style: TextStyle(
//                         color: data.checked ? textColor : subtitleColor,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold)),
//               ],
//             ),
//           ),
//           if (data.checked) SizedBox(height: 10),
//           if (data.checked)
//             ...List.generate(data.params.length,
//                 (index) => _buildFeaturesParametersItem(data.params[index])),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFeaturesParametersItem(AlgorithmParam param) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 15),
//       child: TextField(
//         style: TextStyle(fontSize: 16, height: 1.0),
//         inputFormatters: param.getInputFormatters(),
//         controller: param.controller,
//         decoration: InputDecoration(
//           border: InputBorder.none,
//           prefixIcon: _renderPrefix(param),
//         ),
//       ),
//     );
//   }
//
//   Widget _renderPrefix(AlgorithmParam param) {
//     return RichText(
//       text: TextSpan(
//         style: TextStyle(
//             color: iconColor, fontSize: 18, fontWeight: FontWeight.bold),
//         children: [
//           TextSpan(text: param.name),
//           TextSpan(
//             text: " (${param.des},${param.type}默认值: ${param.defaultValue})",
//             style: TextStyle(color: subtitleColor, fontSize: 12),
//           ),
//           TextSpan(
//             text: ' : ',
//           ),
//         ],
//       ),
//       overflow: TextOverflow.ellipsis,
//     );
//   }
// }
