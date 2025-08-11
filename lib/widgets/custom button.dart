import 'package:flutter/material.dart';

class CustomBtn extends StatelessWidget {
  final String text;
  final bool outlineBtn;
  final bool isLoading;
  const CustomBtn({required this.text, required this.isLoading, required this.outlineBtn});



  @override
  Widget build(BuildContext context) {
    bool _outlineBtn = outlineBtn;
    bool _isLoading = isLoading;

    return Container(
      height: 65.0,

      decoration: BoxDecoration(
          color: _outlineBtn ? Colors.transparent : Colors.black,
          border: Border.all(
            color: Colors.black,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(12.0)
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 8.0,
      ),

      child: Stack(
        children: [
          Visibility(
            visible: _isLoading ? false : true,
            child: Center(
              child: Text(
                text,
                style: TextStyle(fontSize: 16,
                  color: _outlineBtn ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          Visibility(
            visible:  _isLoading,
            child: Center(
              child: SizedBox(
                  height: 30.0,
                  width: 30.0,
                  child: CircularProgressIndicator()
              ),
            ),
          ),
        ],
      ),
    );
  }
}


