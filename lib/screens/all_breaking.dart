import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:news_app/methods/blog_tile.dart';
import 'package:news_app/models/slider_model.dart';
import 'package:news_app/services/slider_data.dart';

class BreakingPage extends StatefulWidget {
  const BreakingPage({super.key});

  @override
  State<BreakingPage> createState() => _BreakingPageState();
}

class _BreakingPageState extends State<BreakingPage> {
  bool isLoading = true;
  String? _loadError;
  List<SliderModel> sliders = [];

  @override
  void initState() {
    super.initState();
    getSlider();
  }

  Future<void> getSlider() async {
    Sliders slider = Sliders();
    try {
      await slider.getSlider();
    } catch (error) {
      _loadError = error.toString();
    }
    if (!mounted) return;
    sliders = slider.sliders;
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(_loadError!)),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Breaking',
                style: GoogleFonts.ptSerif(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 1),
              Text(
                'News',
                style: GoogleFonts.ptSerif(
                  color: const Color.fromARGB(255, 255, 58, 68),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 255, 58, 68),
              ),
            )
          : sliders.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: buildBreakingNews(),
            )
          : Center(
              child: Text(
                'No breaking news found.',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
    );
  }

  Widget buildBreakingNews() {
    return ListView.builder(
      physics: const ClampingScrollPhysics(),
      shrinkWrap: true,
      itemCount: sliders.length,
      itemBuilder: (context, index) {
        return BlogTile(
          sourceName: sliders[index].source!,
          imageUrl: sliders[index].urlToImage!,
          title: sliders[index].title!,
          url: sliders[index].url!,
        );
      },
    );
  }
}
