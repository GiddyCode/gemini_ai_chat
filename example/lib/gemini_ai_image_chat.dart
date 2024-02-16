import 'dart:io';

import 'package:example/env.dart';
import 'package:flutter/material.dart';
import 'package:gemini_ai_chat/gemini_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:svg_flutter/svg.dart';

class GeminiImageChat extends StatefulWidget {
  const GeminiImageChat({super.key});

  @override
  State<GeminiImageChat> createState() => _GeminiImageChatState();
}

class _GeminiImageChatState extends State<GeminiImageChat> {
  bool loading = false;
  List textAndImageChat = [];
  List textWithImageChat = [];
  File? imageFile;

  final ImagePicker picker = ImagePicker();

  final TextEditingController _textController = TextEditingController();
  final ScrollController _controller = ScrollController();

  // Create Gemini Instance
  final geminiAI = GeminiAI(
    apiKey: Env.key,
  );

  // Text only input
  void fromTextAndImage({required String query, required File image}) {
    setState(() {
      loading = true;
      textAndImageChat.add({
        "role": "User",
        "text": query,
        "image": image,
      });
      _textController.clear();
      imageFile = null;
    });
    scrollToTheEnd();

    geminiAI
        .generateTextFromQueryAndImages(query: query, image: image)
        .then((value) {
      setState(() {
        loading = false;
        textAndImageChat
            .add({"role": "Gemini", "text": value.text, "image": ""});
      });
      scrollToTheEnd();
    }).onError((error, stackTrace) {
      setState(() {
        loading = false;
        textAndImageChat
            .add({"role": "Gemini", "text": error.toString(), "image": ""});
      });
      scrollToTheEnd();
    });
  }

  void scrollToTheEnd() {
    _controller.jumpTo(_controller.position.maxScrollExtent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gemini AI"),
        elevation: 2,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              child: Image.asset("assets/images/user.png"),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _controller,
              itemCount: textAndImageChat.length,
              padding: const EdgeInsets.only(bottom: 20),
              itemBuilder: (context, index) {
                bool isMyText =
                    textAndImageChat[index]["role"] == "User" ? true : false;
                return ListTile(
                  isThreeLine: true,
                  leading: !isMyText
                      ? CircleAvatar(
                          child: SvgPicture.asset("assets/svgs/gemini_bg.svg"),
                        )
                      : null,
                  trailing: !isMyText
                      ? null
                      : CircleAvatar(
                          child: Image.asset("assets/images/user.png"),
                        ),
                  title: Align(
                      alignment: !isMyText
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Text(
                        !isMyText ? "Gemini AI" : "Me",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )),
                  subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(textAndImageChat[index]["text"]),
                        const SizedBox(
                          height: 7,
                        ),
                        textAndImageChat[index]["image"] == ""
                            ? const SizedBox.shrink()
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    20.0), // Set your desired border radius
                                child: Image.file(
                                  textAndImageChat[index]["image"],
                                  height: 180,
                                  width: 200,
                                  fit: BoxFit.fill,
                                ),
                              ),
                      ]),
                );
              },
            ),
          ),
          Container(
            alignment: Alignment.bottomRight,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.only(left: 15.0, right: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100.0),
              border: Border.all(color: Colors.grey.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: "Ask me Anything!",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none),
                      fillColor: Colors.transparent,
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 9),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.primaries[5].shade50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.photo),
                        onPressed: () async {
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery);
                          setState(() {
                            imageFile = image != null ? File(image.path) : null;
                          });
                        },
                      ),
                      IconButton(
                        icon: loading
                            ? const CircularProgressIndicator()
                            : const Icon(Icons.send),
                        onPressed: () {
                          if (imageFile == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Please select an image")));
                            return;
                          }
                          fromTextAndImage(
                              query: _textController.text, image: imageFile!);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: imageFile != null
          ? Container(
              margin: const EdgeInsets.only(bottom: 80),
              height: 150,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.file(imageFile ?? File(""))),
            )
          : null,
    );
  }
}
