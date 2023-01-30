# Pong-Game
Unforgettable ping pong game in assembly

The game has two player. You can control them with direction buttons on the screen. Whoever reaches to five, wins.

This game runs on Keil's ARM Cortex M0 simulator with LCD peripheral.
After you started the debug session, you must check the "INT" box to enable the interrupts.
Please refer to each folder's README files for further explanation.

P.S. I have problem with moving the rackets. Not every interrupt is occured and when the button is pressed consecutively, read permission error is occured. I don't know if the problem is with the code or the simulator. Any feedback is appreciated :)
