@ECHO OFF
"C:\Program Files (x86)\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "E:\AVRprojects\Temperature\labels.tmp" -fI -W+ie -o "E:\AVRprojects\Temperature\Temperature.hex" -d "E:\AVRprojects\Temperature\Temperature.obj" -e "E:\AVRprojects\Temperature\Temperature.eep" -m "E:\AVRprojects\Temperature\Temperature.map" "E:\AVRprojects\Temperature\Temperature.asm"
