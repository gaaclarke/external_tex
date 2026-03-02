import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter External Texture',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'External Texture iOS'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = MethodChannel('com.example.external_tex/texture');
  int? _textureId;

  @override
  void initState() {
    super.initState();
    _getTextureId();
  }

  Future<void> _getTextureId() async {
    int? textureId;
    try {
      textureId = await platform.invokeMethod<int>('getTextureId');
    } on PlatformException catch (e) {
      debugPrint("Failed to get texture ID: '${e.message}'.");
    }

    if (mounted) {
      setState(() {
        _textureId = textureId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: _textureId == null
            ? const CircularProgressIndicator()
            : SizedBox(
                width: 200,
                height: 200,
                child: Texture(textureId: _textureId!),
              ),
      ),
    );
  }
}
