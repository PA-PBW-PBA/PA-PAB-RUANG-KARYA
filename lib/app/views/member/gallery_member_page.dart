import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/gallery_controller.dart';
import '../visitor/gallery_visitor_page.dart';
import '../widgets/member_bottom_nav.dart';

class GalleryMemberPage extends StatelessWidget {
  const GalleryMemberPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(GalleryController());
    return Scaffold(
      body: const GalleryVisitorPage(),
      bottomNavigationBar: MemberBottomNav(currentIndex: 2),
    );
  }
}
