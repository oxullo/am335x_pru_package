.origin 0
.entrypoint START

#define PRU0_ARM_INTERRUPT 19
#define AM33XX

#define GPIO1 0x4804c000
#define GPIO_CLEARDATAOUT 0x190
#define GPIO_SETDATAOUT 0x194

#define CONST_PRUSHAREDRAM   C28
#define CONST_DDR            C31

// Address for the Constant table Block Index Register (CTBIR)
#define CTBIR          0x22020

// Address for the Constant table Programmable Pointer Register 0(CTPPR_0)
#define CTPPR_0         0x22028

// Address for the Constant table Programmable Pointer Register 1(CTPPR_1)
#define CTPPR_1         0x2202C

START:
// clear that bit
    LBCO r0, C4, 4, 4
    CLR r0, r0, 4
    SBCO r0, C4, 4, 4

    // Configure the programmable pointer register for PRU0 by setting c28_pointer[15:0]
    // field to 0x0120.  This will make C28 point to 0x00012000 (PRU shared RAM).
    MOV     r0, 0x00000120
    MOV       r1, CTPPR_0
    SBBO      r0, r1, 0, 4

    // Configure the programmable pointer register for PRU0 by setting c31_pointer[15:0]
    // field to 0x0010.  This will make C31 point to 0x80001000 (DDR memory).
    MOV     r0, 0x00100000
    MOV       r1, CTPPR_1
    SBBO      r0, r1, 0, 4

    LBCO    r1, CONST_DDR, 0, 4

BLINK:
    // turn on LED on USR1
    MOV r2, 1<<22
    MOV r3, GPIO1 | GPIO_SETDATAOUT
    SBBO r2, r3, 0, 4

    // Set r30.t1 (P9 pin 29 / pr1_pru0_pru_r30_1)
    // Clear r30.t2 (P9 pin 30 or pr1_pru0_pru_r30_2)
    SET     r30.t1
    CLR     r30.t2

    MOV r0, 0x00f00000
DELAY:
    SUB r0, r0, 1
    QBNE DELAY, r0, 0

    // turn off LED on USR1
    MOV r2, 1<<22
    MOV r3, GPIO1 | GPIO_CLEARDATAOUT
    SBBO r2, r3, 0, 4

    // Clear r30.t1 (P9 pin 29 / pr1_pru0_pru_r30_1)
    // Set r30.t2 (P9 pin 30 or pr1_pru0_pru_r30_2)
    CLR     r30.t1
    SET     r30.t2

    MOV r0, 0x00f00000
DELAY2:
    SUB r0, r0, 1
    QBNE DELAY2, r0, 0

    SUB r1, r1, 1
    QBNE BLINK, r1, 0

    CLR     r30.t1
    CLR     r30.t2

//#ifdef AM33XX
    // Send notification to Host for program completion
    MOV R31.b0, PRU0_ARM_INTERRUPT+16
//#else
//    MOV R31.b0, PRU0_ARM_INTERRUPT
//#endif

HALT
