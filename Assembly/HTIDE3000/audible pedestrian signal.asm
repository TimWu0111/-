;Port_C[6...0]=>[abcdefg]
;Port_D0=>com4
;Port_D1=>LED1
;Port_D2=>LED2
;Port_D3=>LED3
;Port_D4=>BUZZER
;Port_G[7-0]=>Keypad[7-0]

include HT66F70A.inc

ds	.section	'data'
DEL1  	     DB      ?              ;delay 1
DEL2  	     DB      ?              ;delay 2 
DEL3	     DB      ?		    ;delay 3
COUNT	     DB	     ?		    ;col
KEY	     DB	     ?		    ;button
TMP          DB      ?
AGAIN        DB      ?              ;sound repeat
GOCOUNT      DB      ?              
GCOUNT       DB      ?
GINDEX       DB      ?
RCOUNT       DB      ?
RINDEX       DB      ?
YCOUNT       DB      ?
YINDEX       DB      ?
GGCOUNT      DB      ?
GGINDEX      DB      ?
YYCOUNT      DB      ?
YYINDEX      DB      ?
RRCOUNT      DB      ?
RRINDEX      DB      ?

ROMBANK 0 cs
cs	.section	at  000h	'code'
        ORG     00H                    	
		CLR	PCC				;PORT_C output
		CLR     PDC
		CLR     PDC.4                   
		MOV	A,10101111B					
		MOV	WDTC,A
		MOV     A,00000001B
        	MOV     PD,A 
        	MOV     A,1
		MOV     TMP,A
		CALL	TRANS				;get Seven-segment 	
	    	MOV     PC,A				;display Seven-segment 
	    	CALL	DELAY	

MAIN1: 
        SET     PD.1
        SET     PD.2
		CLR     PD.3
		CALL   	READ_KEY		        ;call scan keyboard	
		MOV	A,16
		XOR	A,KEY					
		SZ	Z				;no key pressed(KEY=16,0010000 XOR 0010000=00000000)
		JMP    	MAIN1				;scan again
		
		MOV	A,KEY
		XOR	A,0				
		SZ	Z				;no key pressed(KEY=16,0010000 XOR 0010000=00000000)
		JMP    	LED1
		
		MOV	A,KEY
		XOR	A,0CH				
		SZ	Z				;no key pressed(KEY=16,0010000 XOR 0010000=00000000)
		JMP    	YES1
		JMP	MAIN1
 
MAIN2:		
        SET     PD.3
        CLR     PD.2
        CALL   	READ_KEY				;call scan keyboard	
		MOV	A,16
		XOR	A,KEY					
		SZ	Z				;no key pressed(KEY=16,0010000 XOR 0010000=00000000)
		JMP    	MAIN2				;scan again

        	MOV	A,KEY
		XOR	A,1				
		SZ	Z				;no key pressed(KEY=16,0010000 XOR 0010000=00000000)
		JMP    	LED2
		
		MOV	A,KEY
		XOR	A,0CH				
		SZ	Z				;no key pressed(KEY=16,0010000 XOR 0010000=00000000)
		JMP    	YES2
		JMP	MAIN2
		
MAIN3:	
        SET     PD.2
        CLR     PD.1	
        CALL   	READ_KEY				;call scan keyboard	
		MOV	A,16
		XOR	A,KEY					
		SZ	Z				;no key pressed(KEY=16,0010000 XOR 0010000=00000000)
		JMP    	MAIN3				;scan again

        	MOV	A,KEY
		XOR	A,2			
		SZ	Z				;no key pressed(KEY=16,0010000 XOR 0010000=00000000)
		JMP    	LED3
		
		MOV	A,KEY
		XOR	A,0CH				
		SZ	Z				;no key pressed(KEY=16,0010000 XOR 0010000=00000000)
		JMP    	YES3
		JMP	MAIN3
			
LED1:   MOV     A,TMP
        XOR     A,9
        SZ      Z
        JMP     PCLR1
        JMP     PLUSTART1
PLUSTART1:
       INC      TMP
       MOV      A,TMP
       CALL	TRANS					;get Seven-segment		
       MOV	PC,A					;display Seven-segment
       CALL	DELAY	
       JMP      MAIN1
PCLR1:
       MOV      A,1
       MOV      TMP,A
       CALL	TRANS					;get Seven-segment		
       MOV	PC,A					;display Seven-segment
       CALL	DELAY
       JMP      MAIN1
	   
LED2:  MOV      A,TMP
       XOR      A,9
       SZ       Z
       JMP      PCLR2
       JMP      PLUSTART2
PLUSTART2:
       INC      TMP
       MOV      A,TMP
       CALL	TRANS					;get Seven-segment		
       MOV	PC,A					;display Seven-segment
       CALL	DELAY	
       JMP      MAIN2
PCLR2:
       MOV      A,1
       MOV      TMP,A
       CALL	TRANS					;get Seven-segment		
       MOV	PC,A					;display Seven-segment
       CALL	DELAY
       JMP      MAIN2

LED3:  MOV      A,TMP
       XOR      A,9
       SZ       Z
       JMP      PCLR3
       JMP      PLUSTART3
       
PLUSTART3:
       INC      TMP
       MOV      A,TMP
       CALL	TRANS					;get Seven-segment		
       MOV	PC,A					;display Seven-segment
       CALL	DELAY	
       JMP      MAIN3
PCLR3:
       MOV      A,1
       MOV      TMP,A
       CALL	TRANS					;get Seven-segment		
       MOV	PC,A					;display Seven-segment
       CALL	DELAY
       JMP      MAIN3
	   
YES1:  
       MOV      A,TMP
       MOV      GINDEX,A
       MOV      GINDEX,A
       ADD      A,1
       MOV      GCOUNT,A 
       MOV      A,1
       MOV      TMP,A
       CALL	TRANS					;get Seven-segment		
       MOV	PC,A					;display Seven-segment
       CALL	DELAY
       JMP      MAIN2

YES2:  
       MOV      A,TMP
       MOV      RINDEX,A
       MOV      RINDEX,A
       ADD      A,1
       MOV      RCOUNT,A 
       MOV      A,1
       MOV      TMP,A
       CALL	TRANS					;get Seven-segment		
       MOV	PC,A					;display Seven-segment
       CALL	DELAY
       JMP      MAIN3
	   
YES3:  
       MOV  	A,TMP
       MOV  	YINDEX,A
       MOV  	YINDEX,A
       ADD  	A,1
       MOV  	YCOUNT,A 
       MOV  	A,0
       MOV      TMP,A
       CALL	TRANS					;get Seven-segment		
       MOV	PC,A					;display Seven-segment
       CALL	DELAY
       JMP      INIT
	   
INIT:
       SET  	PD.1
       MOV  	A,GINDEX
       MOV  	GGINDEX,A
       MOV  	A,GCOUNT
       MOV  	GGCOUNT,A
       MOV  	A,YINDEX
       MOV  	YYINDEX,A
       MOV  	A,YCOUNT
       MOV  	YYCOUNT,A
       MOV  	A,RINDEX
       MOV  	RRINDEX,A
       MOV  	A,RCOUNT
       MOV  	RRCOUNT,A
GREEN:
       SET  	PD.2
       CLR  	PD.3
       MOV  	A,GGINDEX
       CALL 	TRANS
       MOV  	PC,A  
       MOV  	A,1
       MOV  	AGAIN,A
       CALL 	GO
       MOV  	A,200
       CALL 	STRDELAY
       DEC  	GGINDEX
       SDZ  	GGCOUNT
       JMP  	GREEN    

 YELLOW:
 	   SET  PD.3
	   CLR  PD.1
	   MOV  A,YYINDEX
 	   CALL TRANS
	   MOV  PC,A
 	   MOV  A,3
 	   MOV  AGAIN,A
 	   CALL GO
 	   MOV  A,200
 	   CALL STRDELAY
 	   DEC  YYINDEX
 	   SDZ  YYCOUNT
 	   JMP  YELLOW
 
 RED:
 	   SET  PD.1
 	   CLR  PD.2
 	   MOV  A,RRINDEX
 	   CALL TRANS
 	   MOV  PC,A  
 	   MOV  A,200
 	   CALL STRDELAY
 	   DEC  RRINDEX
 	   SDZ  RRCOUNT
 	   JMP  RED
 	   JMP  INIT
;========================================================================================
;   scan 4*4 
;	no key pressed，KEY=16.
;========================================================================================
READ_KEY	PROC
		MOV		A,11110000B
		MOV		PGC,A					;set PORT_D high 4bits are inputs； low 4bits are outputs
		MOV		PGPU,A					;high 4bits pull-up resistance
		SET		PG					;set PORT_D low 4bits is 1111
		CLR		KEY					;clear
		MOV		A,04					
		MOV		COUNT,A					;set col
		CLR 		C					;set carry is 0
SCAN_KEY:
		RLC		PG					;旋轉掃描碼1111 0 => 1110 1
		SET 		C					;set carry is 1
		SNZ    		PG.4					;row 0?
		JMP		END_KEY					;yes, done
		INC		KEY					;no, next key 	
		SNZ    		PG.5					;row 1?
		JMP		END_KEY					
		INC		KEY						 	
		SNZ    		PG.6					;row 2?
		JMP		END_KEY					
		INC		KEY						
		SNZ    		PG.7					;row 3?
		JMP		END_KEY					
		INC		KEY						 	
		SDZ		COUNT					;scan done?
		JMP		SCAN_KEY				;no, next row
END_KEY:
		RET
READ_KEY    ENDP 
;********************************************************************
;   		button delay 
;********************************************************************
DELAY	PROC
		MOV		A,50
		MOV		DEL1,A						
DEL_1:  MOV		A,60		        	                   	
		MOV		DEL2,A				
DEL_2:	MOV		A,110
		MOV		DEL3,A					
DEL_3:	SDZ		DEL3                  
		JMP		DEL_3                      
		SDZ		DEL2                  	
		JMP		DEL_2                   
		SDZ		DEL1				
		JMP		DEL_1
		RET
DELAY	ENDP
;********************************************************************
;   		delay 
;********************************************************************
STRDELAY	PROC
		MOV		DEL1,A						
DEL_5:  MOV		A,30		        	                   	
		MOV		DEL2,A				
DEL_6:	MOV		A,110
		MOV		DEL3,A					
DEL_7:	SDZ		DEL3                  
		JMP		DEL_7                      
		SDZ		DEL2                  	
		JMP		DEL_6                   
		SDZ		DEL1				
		JMP		DEL_5
		RET
STRDELAY	ENDP
;********************************************************************
;   		利用累加器傳回建表值 
;********************************************************************
TRANS	PROC
		ADDM	A,PCL
		RET  	A,11111110B				;0
		RET	A,10110000B				;1		
		RET	A,11101101B				;2
		RET  	A,11111001B				;3
		RET  	A,10110011B				;4
		RET	A,11011011B				;5
		RET  	A,10011111B				;6
		RET  	A,11110000B				;7
		RET  	A,11111111B				;8
		RET  	A,11111011B				;9
		RET	A,11110111B				;a
		RET	A,10011111B				;b
		RET	A,11001110B				;c
		RET	A,10111101B				;d
		RET	A,11001111B				;E
		RET	A,11000111B				;F
TRANS	ENDP
;********************************************************************
;   		  BUZZER delay
;********************************************************************
BUZDELAY PROC
      MOV DEL1,A
DEL_4:NOP        ;one 0.5us ; total 10
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      SDZ  DEL1
      JMP  DEL_4
      RET
BUZDELAY ENDP
;********************************************************************
;   		BUZZER sound
;********************************************************************
GO PROC
 
  GOINIT:
        	MOV		A,50					;set Pitch length(250*2*0.5uS)
		MOV		GOCOUNT,A
  LOOP:
		SET	    	PD.4					;set PORT_C.4 1
    		MOV		A,50					;4KHz sound(F=1/(500*0.5uS))
		CALL 		BUZDELAY				;call buzzer delay
		CLR 		PD.4					;set PORT_C.4 0
	        MOV		A,50
		CALL 		BUZDELAY				;call buzzer delay
		SDZ		GOCOUNT
		JMP	    	LOOP
		MOV		A,50
		MOV		GOCOUNT,A
  WAIT:
		MOV		A,50					;set mute(250*0.5u)
		CALL		BUZDELAY
		SDZ		GOCOUNT
		JMP		WAIT
		SDZ     	AGAIN
		JMP     	GOINIT		
  RET
GO ENDP
		END
