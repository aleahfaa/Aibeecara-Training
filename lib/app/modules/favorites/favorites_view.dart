import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/favorites_controller.dart';
import '../../routes/app_pages.dart';

class FavoritesView extends GetView<FavoritesController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Favorite Quotes'), centerTitle: true),
      body: Obx(() {
        if (controller.favorites.isEmpty) {
          return Center(child: Text('No favorite quotes yet'));
        }
        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: controller.favorites.length,
          itemBuilder: (context, index) {
            final quote = controller.favorites[index];
            return Dismissible(
              key: Key(quote.text + quote.author),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(horizontal: 20),
                color: Colors.red,
                child: Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) => controller.removeFromFavorites(index),
              child: Card(
                elevation: 3,
                margin: EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quote.text,
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '- ${quote.author}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: Icon(Icons.favorite, color: Colors.red),
                            onPressed:
                                () => controller.removeFromFavorites(index),
                            tooltip: 'Remove from favorites',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Get.back();
              break;
            case 1:
              break;
            case 2:
              Get.offAndToNamed(Routes.TODO);
              break;
            case 3:
              Get.offAndToNamed(Routes.NOTES);
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.check_box), label: 'To-Do'),
          BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Notes'),
        ],
      ),
    );
  }
}
