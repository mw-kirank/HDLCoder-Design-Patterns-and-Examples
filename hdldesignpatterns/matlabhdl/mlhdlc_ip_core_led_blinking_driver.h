#ifndef MLHDLC_LED_BLINKING_H_
#define MLHDLC_LED_BLINKING_H_

#define LED_BLINKING	0x40010000

#define REG_WRITE(addr, off, val) (*(volatile int*)(addr+off)=(val))
#define REG_READ(addr,off) (*(volatile int*)(addr+off))

void setFPGARegister(int addr, int value);
int getInput(void);
#endif /* MLHDLC_LED_BLINKING_H_ */
