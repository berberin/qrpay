import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

showNormalDialog(
    {BuildContext context, Widget widget, usePreDialog: true}) async {
  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: null,
    transitionDuration: const Duration(milliseconds: 150),
    pageBuilder: (
      BuildContext dialogContext,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
    ) {
      return usePreDialog
          ? Dialog(
              insetPadding: EdgeInsets.symmetric(vertical: 100, horizontal: 25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: widget,
            )
          : widget;
    },
  );
}

void showLoadingDialog(BuildContext context) {
  AlertDialog alert = AlertDialog(
    backgroundColor: Colors.transparent,
    elevation: 0.0,
    content: Container(
      child: AsyncSpinKit(),
    ),
  );
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => alert);
}

class AsyncSpinKit extends StatelessWidget {
  const AsyncSpinKit({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(30),
      child: Center(
        child: Center(
          child: SpinKitChasingDots(
            color: Colors.red[800],
            size: 35,
          ),
        ),
      ),
    );
  }
}
