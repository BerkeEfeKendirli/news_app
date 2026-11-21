import 'package:news_app/models/slider_model.dart';
import 'package:news_app/services/news_api.dart';

class Sliders {
  List<SliderModel> sliders = [];

  Future<void> getSlider() async {
    final jsonData = await NewsApi().get('top-headlines', {
      'country': 'us',
      'pageSize': '100',
    });
    sliders.clear();

    if (jsonData['status'] == 'ok') {
      jsonData["articles"].forEach((element) {
        if (element["title"] != "[Removed]") {
          String description =
              element["description"] ??
              ""; // Provide a default value if description is null
          String imageUrl =
              element["urlToImage"] ??
              "https://i.ibb.co/q7bYPKN/placeholder-image21.png"; // Use a default image URL if urlToImage is null
          SliderModel slidermodel = SliderModel(
            title: element["title"],
            description: description,
            url: element["url"],
            urlToImage: imageUrl,
            content: element["content"],
            author: element["author"],
            source: element["source"]["name"],
          );
          sliders.add(slidermodel);
        }
      });
    }
  }
}
