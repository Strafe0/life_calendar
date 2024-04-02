import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:life_calendar/utils/snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

class ThanksScreen extends StatefulWidget {
  const ThanksScreen({super.key});

  @override
  State<ThanksScreen> createState() => _ThanksScreenState();
}

class _ThanksScreenState extends State<ThanksScreen> {
  final Uri _url = Uri.parse('mailto:<vg01spare@gmail.com>');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Обратная связь'),
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Если вам понравилось приложение,\n напишите положительный отзыв!', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) => const Icon(Icons.star, color: Colors.yellow, size: 32)),
              ),
              const SizedBox(height: 24),
              Text('Для предложений и сообщениях об ошибках\n пишите на почту.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge,),
              const SizedBox(height: 8.0),
              ElevatedButton(onPressed: _writeButton, child: const Text('Написать')),
              // const SizedBox(height: 24),
              // Text('Также вы можете угостить разработчика.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge,),
              // const SizedBox(height: 8.0),
              // const Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Icon(Icons.currency_ruble, color: Colors.green,),
              //     Icon(Icons.coffee, color: Colors.brown,),
              //   ],
              // ),
              // const SizedBox(height: 8.0),
              // ElevatedButton(onPressed: _donateButton, child: const Text('Поблагодарить')),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _writeButton() async {
    if (!await launchUrl(_url)) {
      if (!mounted) return;
      showSnackBar(context, 'Упс... Возникла неизвестная проблема');
    }
  }
}
