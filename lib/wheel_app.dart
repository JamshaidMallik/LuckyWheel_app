import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:google_fonts/google_fonts.dart';

class SpinnerScreen extends StatefulWidget {
  const SpinnerScreen({super.key});
  @override
  _SpinnerScreenState createState() => _SpinnerScreenState();
}

class _SpinnerScreenState extends State<SpinnerScreen>
    with SingleTickerProviderStateMixin {
  final player = AudioPlayer();
  bool isSoundEnabled = true; // Sound toggle
  final List<String> names = ['Malik', 'Jamshaid'];
  final List<String> winners = [];
  final TextEditingController nameController = TextEditingController();
  final StreamController<int> selected = StreamController<int>();
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void spinWheel() {
    if (names.isNotEmpty) {
      final index = Random().nextInt(names.length);
      selected.add(index);
      Future.delayed(const Duration(seconds: 4), () {
        setState(() {
          winners.add(names[index]);
        });
        _showWinnerDialog(names[index]);
        playSound();
      });
    }
  }

  void _showWinnerDialog(String winner) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Winner!',
          style: GoogleFonts.orbitron(
            color: Colors.amber,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '$winner wins!',
          style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              player.stop();
              Navigator.pop(context);
            },
            child: Text('OK', style: GoogleFonts.orbitron(color: Colors.amber)),
          ),
        ],
      ),
    );
  }

  Color _getColor(int index) {
    const colors = [
      Color(0xFFFF2D55), // Neon Red
      Color(0xFF00C4B4), // Neon Cyan
      Color(0xFFFFAA00), // Neon Orange
      Color(0xFF5856D6), // Neon Purple
      Color(0xFFFF9500), // Neon Yellow
      Color(0xFF4CD964), // Neon Green
      Color(0xFFFF3B30), // Bright Red
      Color(0xFF007AFF), // Bright Blue
      Color(0xFFFFCC00), // Bright Yellow
      Color(0xFF34C759), // Bright Green
    ];
    return colors[index % colors.length];
  }

  Future<void> playSound() async {
    try {
      if (isSoundEnabled) {
        await player.play(
          AssetSource('sound/claps.wav'),
          position: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  void toggleSound() {
    if (isSoundEnabled) {
      isSoundEnabled = false;
    } else {
      isSoundEnabled = true;
    }
    setState(() {});
  }

  @override
  void dispose() {
    player.dispose();
    selected.close();
    nameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Lucky Spin',
          style: GoogleFonts.orbitron(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 5),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isSoundEnabled ? Icons.volume_up : Icons.volume_off,
              color: Colors.amber,
            ),
            onPressed: toggleSound,
            tooltip: isSoundEnabled ? 'Mute sound' : 'Unmute sound',
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt, color: Colors.amber),
            onPressed: () {
              setState(() {
                winners.clear();
                names.clear();
                names.addAll(['Jamshaid', 'Malik']);
              });
            },
            tooltip: 'Reset',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.8,
            colors: [
              Colors.black,
              Colors.blueGrey[900]!,
              Colors.blueGrey[800]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Input Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber.withOpacity(0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: nameController,
                          style: GoogleFonts.orbitron(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter Player Name',
                            hintStyle: GoogleFonts.orbitron(
                              color: Colors.white54,
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          if (nameController.text.trim().isNotEmpty) {
                            setState(() {
                              names.add(nameController.text.trim());
                            });
                            nameController.clear();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.amber, Colors.orangeAccent],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Text(
                            'ADD',
                            style: GoogleFonts.orbitron(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Spinner Section
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ScaleTransition(
                          scale: _pulseAnimation,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: FortuneWheel(
                              selected: selected.stream,
                              duration: const Duration(seconds: 4),
                              hapticImpact: HapticImpact.heavy,
                              physics: CircularPanPhysics(
                                duration: const Duration(seconds: 4),
                                curve: Curves.decelerate,
                              ),
                              indicators: [
                                FortuneIndicator(
                                  alignment: Alignment.topCenter,
                                  child: Transform.translate(
                                    offset: const Offset(0, -30),
                                    child: Container(
                                      width: 40,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.amber,
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.vertical(
                                          bottom: Radius.circular(50),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.5,
                                            ),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.arrow_drop_down,
                                        size: 40,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              items: names.isEmpty
                                  ? [
                                      FortuneItem(
                                        child: Text(
                                          'No Players',
                                          style: GoogleFonts.orbitron(
                                            color: Colors.white54,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        style: FortuneItemStyle(
                                          color: Colors.blueGrey[700]!,
                                          borderColor: Colors.white,
                                          borderWidth: 3,
                                        ),
                                      ),
                                    ]
                                  : [
                                      for (int i = 0; i < names.length; i++)
                                        FortuneItem(
                                          child: Text(
                                            names[i],
                                            style: GoogleFonts.orbitron(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                  blurRadius: 3,
                                                  offset: const Offset(1, 1),
                                                ),
                                              ],
                                            ),
                                          ),
                                          onLongPress: () {
                                            if (names.length <= 2) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'At least 2 players required to spin!',
                                                    style: GoogleFonts.orbitron(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  backgroundColor: Colors
                                                      .redAccent
                                                      .withOpacity(0.9),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  margin: const EdgeInsets.all(
                                                    10,
                                                  ),
                                                ),
                                              );
                                              return;
                                            }

                                            showDialog(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: Text('Remove Player?'),
                                                content: Text(
                                                  'Do you want to remove "${names[i]}"?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(ctx),
                                                    child: Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(ctx);
                                                      setState(() {
                                                        names.removeAt(i);
                                                      });
                                                    },
                                                    child: Text(
                                                      'Remove',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },

                                          style: FortuneItemStyle(
                                            color: _getColor(i),
                                            borderColor: Colors.white,
                                            borderWidth: 3,
                                            textStyle: GoogleFonts.orbitron(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: names.length >= 2 ? spinWheel : null,
                          child: ScaleTransition(
                            scale: _pulseAnimation,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [Colors.amber, Colors.orangeAccent],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.amber.withOpacity(0.5),
                                    blurRadius: 15,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  'SPIN',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Winners Section
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.withOpacity(0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hall of Fame',
                          style: GoogleFonts.orbitron(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: winners.isEmpty
                              ? Center(
                                  child: Text(
                                    'Awaiting Champions...',
                                    style: GoogleFonts.orbitron(
                                      fontSize: 16,
                                      color: Colors.white54,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: winners.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.amber.withOpacity(0.3),
                                        ),
                                      ),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.amber
                                              .withOpacity(0.2),
                                          child: Text(
                                            '${index + 1}',
                                            style: GoogleFonts.orbitron(
                                              color: Colors.amber,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          winners[index],
                                          style: GoogleFonts.orbitron(
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        trailing: const Icon(
                                          Icons.emoji_events,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
