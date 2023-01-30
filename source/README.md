Add these files into your preject's source group.

In "main.s" there is code for plotting the interface and moving the ball.
The C files are hex code of scoreboard numbers etc. which are too complex to draw in assembly. 
In "startup_ARMCM0.s" there is an interrupt handler for button press. When button is pressed, interrupt is ocurred and it checks which button is pressed. Then rackets' coordinates are updated.
