import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  final Completer<bool> _controller = Completer();
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Privacy Policy'),
          elevation: 8,
        ),
        body: Stack(
          children: [
            WebView(
              initialUrl: "https://hangr-canada.com/privacypolicy/",
              zoomEnabled: false,
              onPageFinished: (_) => _controller.complete(true),
            ),
            FutureBuilder(
              future: _controller.future,
              builder: (_, snapshot) =>
                  snapshot.connectionState == ConnectionState.waiting
                      ? Center(
                          child: SpinKitFoldingCube(
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 90.0,
                          ),
                        )
                      : const SizedBox.shrink(),
            )
          ],
        ),
      );
}
