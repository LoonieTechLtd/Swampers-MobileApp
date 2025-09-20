import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  const GoogleSignInButton({
    super.key,
    required this.isLoading,
    required this.onTap,
  });


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
            side: BorderSide(color: Colors.black, width: 1),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              )
            else ...[
              Row(
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CachedNetworkImage(
                      imageUrl:
                          "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/Google_Favicon_2025.svg/1024px-Google_Favicon_2025.svg.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text("Login with Google"),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
