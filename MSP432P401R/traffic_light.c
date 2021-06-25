#include "msp.h"
#include <stdlib.h>
#define BUTTON1   BIT1 // Port 1.1
#define BUTTON2   BIT4 // Port 1.4
#define LED2_RED   BIT0 // Port 2.0
#define LED2_GREEN   BIT1 // Port 2.1
#define LED2_BLUE   BIT2 // Port 2.2
#define G G_sec-'0'
#define Y Y_sec-'0'
#define R R_sec-'0'

char time_m[]="GYR";
char END[]="END";
int position=0;         ////address of sending string
int B1_cnt=0;
int B2_cnt=0;

int Y_cnt=0;			//count sec
int G_cnt=0;
int R_cnt=0;
char G_sec='1';         //default 1 sec
char Y_sec='1';         
char R_sec='1';         
char G_duty[3]="10";    //default 10%
char Y_duty[3]="10";    
char R_duty[3]="10";    

int G_pos=0;           //address of receiving string
int Y_pos=0;
int R_pos=0;

int test;

int B1_flag=1;         // button1 enable flag 
int B2_flag=0;         // button2 enable flag

void BUTTON_Init(void){

     P1->DIR &=~BUTTON1;                              // P1.1 as input
     P1->OUT |= BUTTON1;                              // pull-up resistor
     P1->REN |= BUTTON1;                              // resistor enabled

     P1->DIR &=~BUTTON2;                              // P1.4 as input
     P1->OUT |= BUTTON2;                              // pull-up resistor
     P1->REN |= BUTTON2;                              // resistor enabled

     P1->IE |= BUTTON1;                               // P1.1 as interrupt
     P1->IES |= BUTTON1;
     P1->IFG &= ~BUTTON1;

     P1->IE |= BUTTON2;                               // P1.4 as interrupt
     P1->IES |= BUTTON2;
     P1->IFG &= ~BUTTON2;
}

void LED2_Init(void){
    // P2.0 P2.1 P2.2 set LED as output
    P2->DIR |= LED2_RED;
    P2->DIR |= LED2_GREEN;
    P2->DIR |= LED2_BLUE;

    P2->OUT &=~ LED2_RED;
    P2->OUT &=~ LED2_GREEN;
    P2->OUT &=~ LED2_BLUE;
}

void Uart_Init(void){
    // Configure UART pins
    P1->SEL0 |= BIT2 | BIT3;                // set 2-UART pin as secondary function

    // Configure UART
    EUSCI_A0->CTLW0 |= EUSCI_A_CTLW0_SWRST;     // Put eUSCI in reset
    EUSCI_A0->CTLW0 = EUSCI_A_CTLW0_SWRST |     // Remain eUSCI in reset
                      EUSCI_B_CTLW0_SSEL__SMCLK;// Configure eUSCI clock source for SMCLK
    // Baud Rate calculation
    // 12000000/(16*9600) = 78.125
    // Fractional portion = 0.125
    // User's Guide Table 21-4: UCBRSx = 0x10
    // UCBRFx = int ( (78.125-78)*16) = 2
    EUSCI_A0->BRW = 78;                     // 12000000/16/9600
    EUSCI_A0->MCTLW = 0x0002 |
                      EUSCI_A_MCTLW_OS16;

    EUSCI_A0->CTLW0 &= ~EUSCI_A_CTLW0_SWRST; // Initialize eUSCI

}

void Timer_A1(void){

    TIMER_A1->CCTL[0] &= ~TIMER_A_CCTLN_CCIFG;       //no interrupt pending
    TIMER_A1->CCTL[0] = TIMER_A_CCTLN_CCIE;          // TACCR0 interrupt enabled
    TIMER_A1->CCR[0] = (32768) - 1;                  //1 sec
    TIMER_A1->CTL |= TIMER_A_CTL_CLR |
                     TIMER_A_CTL_TASSEL_1 |          // ACLK
                     TIMER_A_CTL_MC_1;               // Up mode
}

void Timer_A2()
{

    TIMER_A2->CCTL[0] &= ~TIMER_A_CCTLN_CCIFG;       //no interrupt pending
    TIMER_A2->CCTL[0] = TIMER_A_CCTLN_CCIE;          // TACCR0 interrupt enabled
    TIMER_A2->CCR[0] = 100 - 1;                     //period

    TIMER_A2->CCTL[1] &= ~TIMER_A_CCTLN_CCIFG;       //no interrupt pending
    TIMER_A2->CCTL[1] = TIMER_A_CCTLN_CCIE;          // TACCR1 interrupt enabled

    TIMER_A2->CTL |= TIMER_A_CTL_CLR |
                     TIMER_A_CTL_TASSEL_1 |          // ACLK
                     TIMER_A_CTL_MC_1;               // Up mode
}


int main(void)
{
    WDT_A->CTL = WDT_A_CTL_PW |             // Stop watchdog timer
            WDT_A_CTL_HOLD;

    CS->KEY = CS_KEY_VAL;                   // Unlock CS module for register access
    CS->CTL0 = 0;                           // Reset tuning parameters
    CS->CTL0 = CS_CTL0_DCORSEL_3;           // Set DCO to 12MHz (nominal, center of 8-16MHz range)
    CS->CTL1 = CS_CTL1_SELA_2 |             // Select ACLK = REFO
            CS_CTL1_SELS_3 |                // SMCLK = DCO
            CS_CTL1_SELM_3;                 // MCLK = DCO
    CS->KEY = 0;                            // Lock CS module from unintended accesses

	// Initialization
    BUTTON_Init();
    LED2_Init();
    Uart_Init();
    Timer_A1();
    Timer_A2();

    // Enable global interrupt
    __enable_irq();

    // Enable interrupt in NVIC module
    NVIC->ISER[0] = 1 << ((TA1_0_IRQn) & 31);
    NVIC->ISER[0] = 1 << ((TA2_0_IRQn) & 31);
    NVIC->ISER[0] = 1 << ((TA2_N_IRQn) & 31);
    NVIC->ISER[0] = 1 << ((EUSCIA0_IRQn) & 31);
    NVIC->ISER[1] = 1 << ((PORT1_IRQn) & 31);


    // Enable sleep on exit from ISR
    SCB->SCR |= SCB_SCR_SLEEPONEXIT_Msk;

    // Ensures SLEEPONEXIT occurs immediately
    __DSB();

    // Enter LPM0
    __sleep();
    __no_operation();                       // For debugger
}

// UART interrupt service routine
void EUSCIA0_IRQHandler(void)
{
    int set_B1=color_B1;
    int set_B2=color_B2;
//----send string
    if (EUSCI_A0->IFG & EUSCI_A_IFG_TXCPTIFG)
    {
      //send END string
      if((B2_flag==1)&&(B1_flag==1))
      {
        if (position == sizeof(END)-1)
        {
            EUSCI_A0->IE &=~ EUSCI_A_IE_TXCPTIE;
            position=0;
        }
        else{
            position++;
            EUSCI_A0->TXBUF =END[position];//send END

        }
      }
    }

//----receive string
    if ((EUSCI_A0->IFG & EUSCI_A_IFG_RXIFG))
    {// receive sec
        if(B1_flag==1){
            if(set_B1==0)
            {
                G_sec=(EUSCI_A0->RXBUF);
                EUSCI_A0->TXBUF = G_sec;
            }
            else if(set_B1==1)
            {
                Y_sec=(EUSCI_A0->RXBUF);
                EUSCI_A0->TXBUF = Y_sec;
            }
            else if(set_B1==2)
            {
                R_sec=(EUSCI_A0->RXBUF);
                EUSCI_A0->TXBUF = R_sec;
            }

        }
        else if(B2_flag==1)
        {//receive duty
           if(set_B2==0)
           {
               G_duty[G_pos]=(EUSCI_A0->RXBUF);
               EUSCI_A0->TXBUF = G_duty[G_pos];
               G_pos++;
           }
           else if(set_B2==1)
           {
               Y_duty[Y_pos]=(EUSCI_A0->RXBUF);
               EUSCI_A0->TXBUF = Y_duty[Y_pos];
               Y_pos++;
           }
           else if(set_B2==2)
           {
               R_duty[R_pos]=(EUSCI_A0->RXBUF);
               EUSCI_A0->TXBUF = R_duty[R_pos];
               R_pos++;
            }
        }

    }

    EUSCI_A0->IFG &=~ EUSCI_A_IFG_RXIFG;
    EUSCI_A0->IFG &=~ EUSCI_A_IFG_TXCPTIFG;
}

void PORT1_IRQHandler(void){
    volatile uint32_t i;
    G_pos=0;
    Y_pos=0;
    R_pos=0;
	int color_B1=0;
	int color_B2=0;
//----button1
    if((P1->IFG & BIT1)&&(B1_flag==1)){
        for (i = 80000; i > 0; i--);

        EUSCI_A0->IE |= EUSCI_A_IE_TXCPTIE;     // Enable USCI_A0 RX interrupt
        EUSCI_A0->IFG &=~ EUSCI_A_IFG_TXCPTIFG;

        EUSCI_A0->IFG &= ~EUSCI_A_IFG_RXIFG;    // Clear eUSCI RX interrupt flag
        EUSCI_A0->IE |= EUSCI_A_IE_RXIE;        // Enable USCI_A0 RX interrupt

        TIMER_A1->CCTL[0] = ~TIMER_A_CCTLN_CCIE;//disable timer
        TIMER_A2->CCTL[0] = ~TIMER_A_CCTLN_CCIE;

        color_B1=B1_cnt%4;//circularly count
        //select G
        if (color_B1==0)
        {
            EUSCI_A0->TXBUF = time_m[0];//Send G
            B2_flag=0;
        }
        //select Y
        else if(color_B1==1)
        {
            EUSCI_A0->TXBUF = time_m[1];//Send Y
            B2_flag=0;
        }
        //select R
        else if(color_B1==2)
        {
            EUSCI_A0->TXBUF = time_m[2];//Send R
            B2_flag=0;
         }
        //select END
        else if(color_B1==3)
        {
           EUSCI_A0->TXBUF =END[position];
           TIMER_A1->CCTL[0] = TIMER_A_CCTLN_CCIE;//enable timer
           TIMER_A2->CCTL[0] = TIMER_A_CCTLN_CCIE;
           B2_flag=1;
         }

        B1_cnt++;

    }
//----button2
    if((P1->IFG & BIT4)&&(B2_flag==1)){
        for (i = 80000; i > 0; i--);

        EUSCI_A0->IE |= EUSCI_A_IE_TXCPTIE;        // Enable USCI_A0 RX interrupt
        EUSCI_A0->IFG &=~ EUSCI_A_IFG_TXCPTIFG;

        EUSCI_A0->IFG &= ~EUSCI_A_IFG_RXIFG;    // Clear eUSCI RX interrupt flag
        EUSCI_A0->IE |= EUSCI_A_IE_RXIE;        // Enable USCI_A0 RX interrupt

        TIMER_A1->CCTL[0] = ~TIMER_A_CCTLN_CCIE;//disable timer
        TIMER_A2->CCTL[0] = ~TIMER_A_CCTLN_CCIE;

        color_B2=B2_cnt%4;//circularly count

       if (color_B2==0)
        {//select duty
           EUSCI_A0->TXBUF = time_m[0];//Send G
           B1_flag=0;
        }
       else if (color_B2==1)
       {//select duty
          EUSCI_A0->TXBUF = time_m[1];//Send Y
          B1_flag=0;
       }
       else if (color_B2==2)
       {//select duty
          EUSCI_A0->TXBUF = time_m[2];//Send R
          B1_flag=0;
       }
       else if(color_B2==3)
       {//select END
           EUSCI_A0->TXBUF =END[position];
           TIMER_A1->CCTL[0] = TIMER_A_CCTLN_CCIE;
           TIMER_A2->CCTL[0] = TIMER_A_CCTLN_CCIE;
           B1_flag=1;

       }

       B2_cnt++;
    }
    P1->IFG &= ~BUTTON1;
    P1->IFG &= ~BUTTON2;

}

void TA1_0_IRQHandler(void) {
    volatile uint32_t i;

    TIMER_A1->CCTL[0] &= ~TIMER_A_CCTLN_CCIFG;
	//count each color
    if((G_cnt<G)&&(Y_cnt==0)&&(R_cnt==0)){
        G_cnt++;
    }
    else if((Y_cnt<Y)&&(G_cnt==G)&&(R_cnt==0)){
        Y_cnt++;
    }
    else if((R_cnt<R)&&(Y_cnt==Y)&&(G_cnt==G)){
        R_cnt++;
        if(R_cnt==R){
            G_cnt=0;
            Y_cnt=0;
            R_cnt=0;
        }
    }
    else{
        G_cnt=0;
        Y_cnt=0;
        R_cnt=0;
    }
}

void TA2_0_IRQHandler(void) {
    volatile uint32_t i;
    TIMER_A2->CCTL[0] &= ~TIMER_A_CCTLN_CCIFG;

	//turn on
    if((G_cnt<G)&&(Y_cnt==0)&&(R_cnt==0)){
       TIMER_A2->CCR[1] = (atoi(G_duty));                    //G_duty
       P2->OUT |= LED2_GREEN;
    }
    else if((Y_cnt<Y)&&(G_cnt==G)&&(R_cnt==0)){
       TIMER_A2->CCR[1] =  (atoi(Y_duty));                    //Y_duty
       P2->OUT |= (LED2_RED|LED2_GREEN);
    }
    else if((R_cnt<R)&&(Y_cnt==Y)&&(G_cnt==G)){
       TIMER_A2->CCR[1] = (atoi(R_duty));                    //R_duty
       P2->OUT |= LED2_RED;
    }

}

void TA2_N_IRQHandler(void) {
    volatile uint32_t i;
	//turn off
    TIMER_A2->CCTL[1] &= ~TIMER_A_CCTLN_CCIFG;
    P2->OUT &= ~(LED2_RED|LED2_GREEN);
}


