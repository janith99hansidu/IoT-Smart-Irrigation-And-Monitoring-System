import 'package:flutter/material.dart';

class PumpCard extends StatefulWidget {
  final bool pumpState;

  const PumpCard({
    Key? key,
    required this.pumpState,
  }) : super(key: key);

  @override
  State<PumpCard> createState() => _PumpCardState();
}

class _PumpCardState extends State<PumpCard> {
  final double titleFontSize = 16.0;
  final double valueFontSize = 20.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(0),
      ),
      padding: const EdgeInsets.all(16),
      child: Container(
        // height: 60, // Adjust to match other cards
        child: Row(
          children: [
            Icon(
              widget.pumpState ? Icons.power : Icons.power_off,
              size: 40,
              color: widget.pumpState ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center, // Align vertically
              children: [
                Text(
                  'Pump',
                  style: TextStyle(
                    fontSize: 16.0, // Match SensorCard
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.pumpState ? 'ON' : 'OFF',
                  style: TextStyle(
                    fontSize: 20.0, // Match SensorCard
                    color: widget.pumpState ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
