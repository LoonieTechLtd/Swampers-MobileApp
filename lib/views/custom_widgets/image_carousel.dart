 import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Widget buildImageCarousel(PageController pageController, ValueNotifier<int> currentPage, List<String> images) {
    return Stack(
      children: [
        SizedBox(
          height: 280,
          width: double.infinity,
          child: PageView.builder(
            controller: pageController,
            itemCount: images.length,
            onPageChanged: (index) => currentPage.value = index,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: images[index],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.error, color: Colors.grey),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<int>(
              valueListenable: currentPage,
              builder: (context, page, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    images.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: page == index 
                            ? Colors.white 
                            : Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }