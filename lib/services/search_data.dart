import 'package:news_app/models/search_model.dart';
import 'package:news_app/services/news_api.dart';

class Search {
  List<SearchModel> search = [];

  Future<void> getSearchNews(String query) async {
    final jsonData = await NewsApi().get('everything', {
      'q': query,
      'language': 'en',
    });
    search.clear();

    if (jsonData['status'] == 'ok') {
      jsonData["articles"].forEach((element) {
        if (element["title"] != "[Removed]") {
          String description =
              element["description"] ??
              ""; // Provide a default value if description is null
          String imageUrl =
              element["urlToImage"] ??
              "https://i.ibb.co/q7bYPKN/placeholder-image21.png"; // Use a default image URL if urlToImage is null
          SearchModel searchModel = SearchModel(
            title: element["title"],
            description: description,
            url: element["url"],
            urlToImage: imageUrl,
            content: element["content"],
            author: element["author"],
            source: element["source"]["name"],
          );
          search.add(searchModel);
        }
      });
    }
  }
}
