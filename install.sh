#!/bin/bash -e
#title       : install.sh
#description : This script installs the tools needed to write code to PM PCB,
#              makes a makefile, source code as example, a script to upload the
#              code to microcontroller. The program that uploads the code will
#              be installed in current directory.
#author      : Eusebiu Boghici
#date        : 11.05.2018
#version     : 0.1
#usage       : ./install


# install needed tools
sudo apt-get -q=2 update
sudo apt-get -q=2 install gcc-avr avr-libc libusb-dev wget unzip


# get bootloader and unzip
wget -q "http://cs.curs.pub.ro/wiki/pm/_media/bootloader_2015.zip"

zip_file=bootloader_2015.zip

unzip -q "$zip_file"

rm "$zip_file"


# add rule in /etc/udev/rules.d in order to use go.sh script without 
# superuser privileges
group=$(id -gn)

cat > 50-placa-pm.rules << EOF
SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="05df", GROUP="$group", MODE="0660"
EOF

sudo chown root:root 50-placa-pm.rules
sudo mv 50-placa-pm.rules /etc/udev/rules.d
sudo udevadm control --reload

echo "If device is connected, you need to replug."


# script that compiles and uploads the code to the microcontroller
bin="$(pwd)/bootloadHID.2014-03-29/commandline/bootloadHID"

cat > go.sh << EOF
#!/bin/bash -e

bin="$bin"

make

"\$bin" -r main.hex ||
	echo "Make sure device is in bootloader mode" &&
	false
EOF

chmod 700 go.sh


# Makefile
cat > Makefile << EOF
all: main.hex

main.hex: main.elf
	avr-objcopy -j .text -j .data -O ihex \$^ \$@
	avr-size $^

main.elf: main.c
	avr-g++ -mmcu=atmega324p -DF_CPU=16000000 -Os -Wall -o \$@ \$^

clean:
	rm -rf main.elf main.hex
EOF


# simple example: blink
cat > main.c << EOF
#include <avr/io.h>
#include <util/delay.h>

void setup() {
	/* set output pin */
	DDRD |= (1 << PD7);

	/* turn off led */
	PORTD &= ~(1 << PD7);
}

void loop() {
	/* Toggle LED */
	PORTD ^= (1 << PD7);

	_delay_ms(1000);
}

int main(void) {
	setup();

	while(1) {
		loop();
	}

	return 0;
}
EOF

echo "You can move main.c, Makefile and go.sh to your project directory"
