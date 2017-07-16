/**
 * 
 * MOUSE2Go - an Arduino based 6502 computer
 * 
 * Author: Mario Keller
 * 
 * 
 * 
 */

#define UNDOCUMENTED

// set this to a proper value for your Arduino 
#define RAM_SIZE 1536 // Uno, mini or any other 328P
//#define RAM_SIZE 6144 //Mega 2560
//#define RAM_SIZE 32768 //Due

uint8_t curkey = 0;

extern "C" {
  uint16_t getpc();
  uint8_t getop();
  void exec6502(int32_t tickcount);
  void reset6502();
 
  void serout(uint8_t val) {
    if (val == 10) {
      Serial.println();
      }
    else {
      Serial.write(val);
      }  
  }

  
  uint8_t getkey() {
    return(curkey);
  }

  void clearkey() {
    curkey = 0;
  }
  
 void printhex(uint16_t val) {
    Serial.print(val, HEX);
    Serial.println();
  }
}

void handle_transfer() {
    Serial.println("Filetransfer detected:");
}

void setup () {
  Serial.begin (9600);
  Serial.println ();

  reset6502();
}

void loop () {
  exec6502(100); //if timing is enabled, this value is in 6502 clock ticks. otherwise, simply instruction count.
  if (Serial.available()) {
    curkey = Serial.read() & 0x7F;
    //check if external transfer of data is initiated
    if(curkey == 0) handle_transfer();
  } 
}

