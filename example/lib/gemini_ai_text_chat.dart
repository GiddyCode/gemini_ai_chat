import 'package:example/env.dart';
import 'package:flutter/material.dart';
import 'package:gemini_ai_chat/gemini_ai.dart';
import 'package:svg_flutter/svg.dart';

class GeminiTextChat extends StatefulWidget {
  const GeminiTextChat({super.key});

  @override
  State<GeminiTextChat> createState() => _GeminiTextChatState();
}

class _GeminiTextChatState extends State<GeminiTextChat> {
  bool loading = false;
  List textChat = [];
  List textWithImageChat = [];

  final TextEditingController _textController = TextEditingController();
  final ScrollController _controller = ScrollController();

  // Create Gemini Instance
  final geminiAI = GeminiAI(
    apiKey: Env.key,
  );

  // Text only input
  void fromText({required String query}) {
    setState(() {
      loading = true;
      textChat.add({
        "role": "User",
        "text": query,
      });
      _textController.clear();
    });
    scrollToTheEnd();

    geminiAI.generateTextFromQuery(query).then((value) {
      setState(() {
        loading = false;
        textChat.add({
          "role": "Gemini",
          "text": value.text,
        });
      });
      scrollToTheEnd();
    }).onError((error, stackTrace) {
      setState(() {
        loading = false;
        textChat.add({
          "role": "Gemini",
          "text": error.toString(),
        });
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
                itemCount: textChat.length,
                padding: const EdgeInsets.only(bottom: 20),
                itemBuilder: (context, index) {
                   bool isMyText =
                      textChat[index]["role"] == "User" ? true : false;
                  return ListTile(
                    isThreeLine: true,
                    leading: !isMyText
                        ? CircleAvatar(
                            child:
                                SvgPicture.asset("assets/svgs/gemini_bg.svg"),
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
                    subtitle: Align(
                        alignment: !isMyText
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Text(textChat[index]["text"])),
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
                border: Border.all(color: Colors.grey),
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
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.primaries[5].shade50),
                    child: Center(
                      child: IconButton(
                        icon: loading
                            ? const CircularProgressIndicator()
                            : const Icon(Icons.send),
                        onPressed: () {
                          fromText(query: _textController.text);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }
}
