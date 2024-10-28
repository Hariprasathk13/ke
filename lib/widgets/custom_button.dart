import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final String localizedText;
  final Function() onTap; // This will be triggered after a successful drag
  final Color onColor;
  final Color offColor;
  final bool isActive;

  const CustomButton({
    super.key,
    required this.text,
    required this.localizedText,
    required this.onTap,
    required this.onColor,
    required this.offColor,
    required this.isActive,
  });

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool isHovered = false;
  double dragPosition = 0.0; // Track the position of the drag
  double maxDragDistance = 0.0; // The maximum distance the circle can be dragged (dynamically calculated)
  bool isDragging = false; // Track if the user is currently dragging

  @override
  Widget build(BuildContext context) {
    // Calculate the max drag distance dynamically based on the button's width and the circle's size
    double buttonWidth = MediaQuery.of(context).size.width * 0.9;
    double circleDiameter = 50;
    maxDragDistance = buttonWidth - circleDiameter;

    return GestureDetector(
      onPanUpdate: (details) {
        // Update the position of the drag
        setState(() {
          dragPosition += details.delta.dx;
          if (dragPosition < 0) dragPosition = 0; // Restrict left drag
          if (dragPosition > maxDragDistance) dragPosition = maxDragDistance; // Restrict right drag
        });
      },
      onPanEnd: (_) {
        // Trigger the action when the drag is past the threshold
        if (dragPosition >= maxDragDistance * 0.8) {
          widget.onTap(); // Navigate to the respective page
        }
        // Reset the position after the drag ends
        setState(() {
          dragPosition = 0.0;
        });
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: isHovered ? 90 : 80,
          width: buttonWidth,
          decoration: BoxDecoration(
            color: widget.isActive ? widget.onColor : widget.offColor,
            borderRadius: BorderRadius.circular(40),
            boxShadow: isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.text,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: isHovered ? 20 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.localizedText,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: isHovered ? 16 : 14,
                    ),
                  ),
                ],
              ),
              // Circle for dragging
              AnimatedPositioned(
                duration: const Duration(milliseconds: 100),
                left: dragPosition, // Update position based on the drag
                child: GestureDetector(
                  child: Container(
                    width: circleDiameter,
                    height: circleDiameter,
                    decoration: BoxDecoration(
                      color: widget.isActive ? widget.offColor : widget.onColor,
                      shape: BoxShape.circle,
                      boxShadow: widget.isActive
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}