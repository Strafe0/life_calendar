import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionTextWidget extends StatelessWidget {
  const AppVersionTextWidget({super.key, this.textStyle});

  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: PackageInfo.fromPlatform(),
      builder: (context, AsyncSnapshot<PackageInfo> snapshot) {
        if (snapshot.hasData) {
          return Text("Версия ${snapshot.data!.version}", style: textStyle,);
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
