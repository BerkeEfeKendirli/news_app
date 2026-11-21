import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ArticleView extends StatefulWidget {
  final String blogUrl;
  final String urlToImage;
  final String source;
  final String title;

  const ArticleView({
    super.key,
    required this.blogUrl,
    required this.source,
    required this.title,
    required this.urlToImage,
  });

  @override
  State<ArticleView> createState() => _ArticleViewState();
}

class _ArticleViewState extends State<ArticleView> {
  bool _isBookmarked = false;
  bool _isProcessing = false; // To track if a process is already running
  Timer? _debounceTimer;
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.blogUrl));
    _checkBookmarkStatus();
  }

  Future<void> _checkBookmarkStatus() async {
    bool isBookmarked = await _isBookmarkedAsync(widget.blogUrl);
    if (!mounted) return;
    setState(() {
      _isBookmarked = isBookmarked;
    });
  }

  Future<bool> _isBookmarkedAsync(String newsId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    var query = await FirebaseFirestore.instance
        .collection('bookmarks')
        .where('userId', isEqualTo: user.uid)
        .where('newsId', isEqualTo: newsId)
        .get();
    return query.docs.isNotEmpty;
  }

  Future<void> _toggleBookmark(
    String blogUrl,
    String urlToImage,
    String title,
    String source,
  ) async {
    if (_isProcessing) return; // Return if a process is already running

    setState(() {
      _isProcessing = true;
    });

    try {
      var bookmarksCollection = FirebaseFirestore.instance.collection(
        'bookmarks',
      );
      var query = await bookmarksCollection
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where('newsId', isEqualTo: blogUrl)
          .get();

      if (query.docs.isEmpty) {
        await bookmarksCollection.add({
          'userId': FirebaseAuth.instance.currentUser!.uid,
          'newsId': blogUrl,
          'imageFire': urlToImage,
          'sourceFire': source,
          'titleFire': title,
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Bookmark added.')));
      } else {
        for (var doc in query.docs) {
          await doc.reference.delete();
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Bookmark removed.')));
      }
      _checkBookmarkStatus();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to toggle bookmark: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _onBookmarkButtonPressed() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _toggleBookmark(
        widget.blogUrl,
        widget.urlToImage,
        widget.title,
        widget.source,
      );
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Beykoz',
              style: GoogleFonts.ptSerif(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 22,
              ),
            ),
            const SizedBox(width: 1),
            Text(
              'News',
              style: GoogleFonts.ptSerif(
                color: const Color.fromARGB(255, 255, 58, 68),
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: SafeArea(child: WebViewWidget(controller: _webViewController)),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: widget.blogUrl));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied to clipboard.')),
                );
              },
              icon: const Icon(Icons.link),
            ),
            IconButton(
              onPressed: () async {
                var url = Uri.parse(widget.blogUrl);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not launch URL.')),
                  );
                }
              },
              icon: const Icon(Icons.travel_explore),
            ),
            IconButton(
              onPressed: () {
                SharePlus.instance.share(ShareParams(text: widget.blogUrl));
              },
              icon: const Icon(Icons.share),
            ),
            IconButton(
              onPressed: _onBookmarkButtonPressed,
              icon: Icon(
                Icons.bookmark,
                color: _isBookmarked
                    ? const Color.fromARGB(255, 255, 58, 68)
                    : null, // Use null to inherit default color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
