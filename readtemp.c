//*******************************************************
//* readtemp.c - Read an I2C temperature probe
//*
//* HISTORICAL INFORMATION -
//*
//*  2018-05-18  msipin  Added this header. Allowed user to specify
//*                      which I2C address to read from on the
//*                      command line.
//*******************************************************
#include <stdio.h>
#include <stdlib.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdint.h>
#include <errno.h>
#include <string.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <linux/i2c.h>
#include <linux/i2c-dev.h>


int main(int argc, char *argv[])
{
  int address=0x49;	// Default, if none specified on the command-line
  char bus=1;
  int temp = 0;
  unsigned char msb, lsb;

	int fd;// File descriptor
	char *fileName;
	unsigned char buf[10]; // Buffer for data being read/ written on the i2c bus


	int n = 0;
	int num = 0;
	if (argc > 1) {
		address = 0;
		num = sscanf(argv[1], "0x%02x%c", &address, &n);
		//printf("DEBUG: num=%d, n=%d, address %d [0x%02xh]\n", num, n, address, address);
		if ((num != 1) || (n != 0)) {
			printf("DEBUG: FAILURE!\n");
			exit(2);
		}
		//else {
		//	printf("DEBUG: GOOD!\n");
		//}
	}
	//exit(2); // FOR TESTING


	if (bus == 1)
		fileName = "/dev/i2c-1"; // Name of the port we will be using
	else
		fileName = "/dev/i2c-0";

	if ((fd = open(fileName, O_RDWR)) < 0) {
		printf("Failed to open i2c port\n");
		exit(1);
	}

	if (ioctl(fd, I2C_SLAVE, address) < 0) {  // Set the port options and set the address of the device we wish to speak to
		printf("Unable to get bus access to talk to slave\n");
		exit(1);
	}

	buf[0] = 0;                                // This is the register we wish to read from

	if ((write(fd, buf, 1)) != 1) {            // Send register to read from
		printf("Error writing to i2c slave\n");
		exit(1);
	}

	if (read(fd, buf, 1) != 1) {				// Read back data into buf[]
		printf("Unable to read from slave\n");
		exit(1);
	}
	else {
		temp = (int)buf[0];
		if (temp > 127) {
			temp = 0 - ((~temp) & 0x7f);
		}
		printf("%d,C,%d,F\n",temp,(temp * 9 / 5 + 32));
		return temp;
	}
}
