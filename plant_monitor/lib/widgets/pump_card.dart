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
            children: [
              Text(
                'Pump',
                style: TextStyle(
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.pumpState ? 'ON' : 'OFF',
                style: TextStyle(
                  color: widget.pumpState ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
