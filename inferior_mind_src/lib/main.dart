import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MasterMindApp());
}

class MasterMindApp extends StatelessWidget {
  const MasterMindApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Master Mind',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MasterMindGame(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MasterMindGame extends StatefulWidget {
  const MasterMindGame({Key? key}) : super(key: key);

  @override
  State<MasterMindGame> createState() => _MasterMindGameState();
}

class _MasterMindGameState extends State<MasterMindGame> {
  static const List<Color> availableColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
  ];

  late List<Color> secretCode;//late rimanda l’inizializzazione, ma assicura che la variabile sarà assegnata prima dell’uso
  
  
  List<Color> playerSequence = [
    Colors.grey,
    Colors.grey,
    Colors.grey,
    Colors.grey,
  ];

  
  List<int> colorIndices = [0, 0, 0, 0];

  
  String feedbackMessage = '';
  Color feedbackColor = Colors.black;

  
  int attempts = 0;

  
  List<Color>? lastAttempt;
  
  
  String lastFeedback = '';

  @override
  void initState() {
    super.initState();
    _generateSecretCode();
  }

  
  void _generateSecretCode() {
    final random = Random();
    secretCode = List.generate(
      4,
      (index) => availableColors[random.nextInt(availableColors.length)],
    );
  }

  
  void _changeButtonColor(int buttonIndex) {
    setState(() {
      colorIndices[buttonIndex] = 
          (colorIndices[buttonIndex] + 1) % availableColors.length;
      playerSequence[buttonIndex] = 
          availableColors[colorIndices[buttonIndex]];
      feedbackMessage = '';
    });
  }

  
  void _checkSequence() {
    setState(() {
      attempts++;
      if (playerSequence.any((color) => color == Colors.grey)) {
        feedbackMessage = 'Seleziona tutti i 4 colori!';
        feedbackColor = Colors.orange;
        return;
      }

      lastAttempt = List.from(playerSequence);

      bool isCorrect = true;
      int correctPosition = 0;
      int correctColor = 0;

      // Lista per tracciare i colori già contati
      List<Color> tempSecret = List.from(secretCode);
      List<Color> tempPlayer = List.from(playerSequence);

      
      for (int i = 0; i < 4; i++) {
        if (playerSequence[i] == secretCode[i]) {
          correctPosition++;
          tempSecret[i] = Colors.transparent;
          tempPlayer[i] = Colors.transparent;
        } else {
          isCorrect = false;
        }
      }

      //colori corretti ma nella posizione sbagliata
      for (int i = 0; i < 4; i++) {
        if (tempPlayer[i] != Colors.transparent) {
          int index = tempSecret.indexOf(tempPlayer[i]);
          if (index != -1) {
            correctColor++;
            tempSecret[index] = Colors.transparent;
          }
        }
      }

      if (isCorrect) {
        feedbackMessage = '🎉VITTORIA! Codice indovinato in $attempts tentativi!';
        feedbackColor = Colors.green;
        
        _showVictoryDialog();
      } else {
        feedbackMessage = 
            'Posizione corretta: $correctPosition | Colore corretto: $correctColor';
        feedbackColor = Colors.blue;
      }

      // Reset della sequenza a grigio
      _resetSequence();
    });
  }

  // Resetta la sequenza a grigio
  void _resetSequence() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          playerSequence = [Colors.grey, Colors.grey, Colors.grey, Colors.grey];
          colorIndices = [0, 0, 0, 0];
        });
      }
    });
  }

  // Mostra dialog di vittoria
  void _showVictoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 VITTORIA!🎉'),
        content: Text('Hai indovinato il codice segreto in $attempts tentativi!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
            },
            child: const Text('Nuova Partita'),
          ),
        ],
      ),
    );
  }

  
  void _resetGame() {
    setState(() {
      _generateSecretCode();
      playerSequence = [Colors.grey, Colors.grey, Colors.grey, Colors.grey];
      colorIndices = [0, 0, 0, 0];
      feedbackMessage = '';
      attempts = 0;
      lastAttempt = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inferior Mind'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetGame,
            tooltip: 'Nuova Partita',
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              Text(
                'Indovina la sequenza di 4 colori!',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Premi i bottoni per cambiare colore',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tentativi: $attempts',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 48),

              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GestureDetector(
                      onTap: () => _changeButtonColor(index),
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: playerSequence[index],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 48),

              // Bottone di verifica
              ElevatedButton(
                onPressed: _checkSequence,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('VERIFICA'),
              ),

              const SizedBox(height: 32),

              // Feedback
              SizedBox(
                height: 60,
                child: feedbackMessage.isNotEmpty
                    ? Text(
                        feedbackMessage,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: feedbackColor,
                        ),
                        textAlign: TextAlign.center,
                      )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),

              // Legenda colori disponibili
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: availableColors.map((color) {
                  return Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Text(
                'Colori disponibili',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ),
      
      // Ultimo tentativo in basso a destra
      if (lastAttempt != null)
        Positioned(
          bottom: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ultimo tentativo:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(4, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: lastAttempt![index],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
    );
  }
}