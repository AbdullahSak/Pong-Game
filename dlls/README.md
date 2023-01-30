These files are for LCD peripheral. 

Add these file in Keil's ...\Core\ARM\BIN directory.  
After that, go to options for target. On the bottom left side of the "Debug" tab, go to "Parameter:" box next to "Dialog DLL:" box. Write "-dLCDDLL.dll". Hit OK.   
After you started the debug session, you must check the "INT" box to enable the interrupts.   

The virtual LCD has the following registers at the given addresses:   
0x40010000 LCD row register     
0x40010004 LCD column register    
0x40010008 LCD color register   
0x4001000C LCD control register (bit 0: refresh, bit 1: clear)    
0x40010010 Button register (bit 31: pending, bit 7: right, bit 6: left, bit 5: down, bit 4: up, bit 3: B, bit 2: A)   

Reading control register bits have no effect. Writing 1 to those bits causes the appropriate action. Note that
writing 1 to clear bit clears internal buffer of the LCD, but does not clear the screen. In order to clear the screen,
you need to execute an LCD refresh after clear.

Each button press or release generates an IRQ#0 at index 16 of the interrupt vector table. The generated interrupt sets the pending bit (bit 31) as well as the bit corresponding
to the pressed button in button register to 1 (only if the button is pressed). In the interrupt service routine, you
need to clear the pending bit to prevent nested interrupts from occurring. If the button is released, none of
the bits corresponding to button positions will be 1.

LCD is made up of a pixel matrix display with rows and columns. It has a total size of 320x240 pixels. Starts with 0. 
The color information of an LCD pixel is encoded in ARGB format. Each component has a range between 0-255.
