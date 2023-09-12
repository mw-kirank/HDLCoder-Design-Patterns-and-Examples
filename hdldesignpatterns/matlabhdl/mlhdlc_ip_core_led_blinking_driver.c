#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/mman.h>

#include "mlhdlc_ip_core_led_blinking_driver.h"
#include "mlhdlc_ip_core_led_blinking_fixpt_pcore_addr.h"


int main()
{

	int choice = 0;
	int value = 0;

	do
	{
		printf("\n-------------  MLHDLC LED Blinking IP:  --------------------\n\n");
		printf("1 -> Change blinking frequency\n");
		printf("2 -> Change blinking direction\n");
		printf("0 -> Exit\n\n");

		printf("\nEnter your choice :");
		choice = getInput();

		switch(choice)
		{
		case 0:	// break;
			printf("\n <== BYE BYE ==>\n");
			break;
		case 1: // Select TPG Pattern
			do
			{
				printf("Please enter the frequency index [0:15]\n");
				value = getInput();

				if(value < 0 || value > 15)
				{
					printf("### Invalid frequency index.\n");
				}
			}while(value < 0 || value > 15);
				

			setFPGARegister(Blink_frequency_1_Data_mlhdlc_ip_core_led_blinking_fixpt_pcore, value);
			break;
		case 2:
			do
			{
				printf("Please specify the blinking direction? (1 - up, 0 - down)\n");
				value = getInput();
				if(value <0 || value >1)
				{
					printf("### Invalid input.\n");
				}
			}while(value <0 || value >1);
			setFPGARegister(Blink_direction_Data_mlhdlc_ip_core_led_blinking_fixpt_pcore, value);
			break;
		default:
			printf("\n\n ********* Invalid input, Please try Again ***********\n");
			break;
		}
		if (choice <=2 && choice > 0)
			printf("\n\n Possible choices: 0, 1, 2\n");
	}while(choice);




	return 0;
}

void setFPGARegister(int addr, int value)
{
	//-------------------------------------------------
	unsigned long int PhysicalAddress = LED_BLINKING;
	int map_len = 0xFF;
	int fd = open( "/dev/mem", O_RDWR);

	unsigned char *test_base = (unsigned char*)mmap(NULL, map_len, PROT_READ | PROT_WRITE, MAP_SHARED, fd, (off_t)PhysicalAddress);

	if(test_base == MAP_FAILED)
	{
	perror("Mapping memory for absolute memory access failed -- Test Try\n");
	return;
	}

	REG_WRITE(test_base, addr, value);

	munmap((void *)test_base, map_len);
	close(fd);
	//-------------------------------------------------
}

int getInput(void)
{
	char ch;
	int ret = -1;
	ch = getchar();
	if (ch >= '0' && ch <= '9')
	{
		ret = ch - '0';
	}
	while ((ch = getchar()) != '\n' && ch != EOF)
	{
		if (ch >= '0' && ch <= '9')
		{
			ret = ret*10 + ch - '0';
		}
	}
	return ret;
}
