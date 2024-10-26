// PC-emul of uart16550, similar to iob_uart

#include "iob-uart16550.h"

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

static bool wasInit = false;

static uint16_t div_value;
static int base;

static FILE *cnsl2soc_fd;
static FILE *soc2cnsl_fd;

void CheckWasInit(){
   if(!wasInit){
      fprintf(stderr,"Trying to use uart16550 without calling uart16550_init beforehand\n");
      exit(0);
   }
}

void uart16550_init(int base_address, uint16_t div){
   wasInit = true;

  // wait for console to create communication files
  while ((cnsl2soc_fd = fopen("./cnsl2soc", "rb")) == NULL);

  fclose(cnsl2soc_fd);
  soc2cnsl_fd = fopen("./soc2cnsl", "wb");

  base = base_address;
  return;
}

int uart16550_base(int base_address){
   // TODO: For now do nothing
}

void uart16550_finish(){
   uart16550_putc(EOT);
}

char uart16550_txready(){
   return false; // TODO:
}

void uart16550_txwait(){
   // TODO;
}

//RX FUNCTIONS
//Check if rx is ready
char uart16550_rxready(){
   return false; // TODO;
}

//Wait for rx to be ready
void uart16550_rxwait(){
   // TODO;
}

//Print char
void uart16550_putc(char value){
  fwrite(&value, sizeof(char), 1, soc2cnsl_fd);
  fflush(soc2cnsl_fd);      
}

//Print string
void uart16550_puts(const char *s){
   while(*s){
      uart16550_putc(*s);
      ++s;
   }
}

void uart16550_sendstr(char *name){
   uart16550_puts(name);
   uart16550_putc('\0');
}

//Send file
void uart16550_sendfile(char* file_name, int file_size, char *mem){
  uart16550_puts(UART_PROGNAME);
  uart16550_puts(": requesting to send file\n");

  // send file transmit command
  uart16550_putc(FTX);

  // send file name
  uart16550_sendstr(file_name);

  // send file size
  uart16550_putc((char)(file_size & 0x0ff));
  uart16550_putc((char)((file_size & 0x0ff00) >> 8));
  uart16550_putc((char)((file_size & 0x0ff0000) >> 16));
  uart16550_putc((char)((file_size & 0x0ff000000) >> 24));

  // send file contents
  for (int i = 0; i < file_size; i++)
    uart16550_putc(mem[i]);

  uart16550_puts(UART_PROGNAME);
  uart16550_puts(": file sent\n");
}

//Get char
char uart16550_getc(){
  // get byte from console
  uint8_t c;
  int nbytes;

  while (1) {
    cnsl2soc_fd = fopen("./cnsl2soc", "rb");
    if (!cnsl2soc_fd)
      fclose(soc2cnsl_fd);

    nbytes = fread(&c, sizeof(char), 1, cnsl2soc_fd);
    if (nbytes == 1) {
      fclose(cnsl2soc_fd);

      // the following removes file contents
      cnsl2soc_fd = fopen("./cnsl2soc", "wb");
      fclose(cnsl2soc_fd);

      break;
    }
    fclose(cnsl2soc_fd);
  }
  return c;   
}

//Receive file
int uart16550_recvfile(char* file_name, char *mem){
  uart16550_puts(UART_PROGNAME);
  uart16550_puts(": requesting to receive file\n");

  // send file receive request
  uart16550_putc(FRX);

  // send file name
  uart16550_sendstr(file_name);

  // receive file size
  uint32_t file_size = uart16550_getc();
  file_size |= ((uint32_t)uart16550_getc()) << 8;
  file_size |= ((uint32_t)uart16550_getc()) << 16;
  file_size |= ((uint32_t)uart16550_getc()) << 24;

  // send ACK before receiving file
  uart16550_putc(ACK);

  // write file to memory
  for (uint32_t i = 0; i < file_size; i++) {
    mem[i] = uart16550_getc();
  }

  uart16550_puts(UART_PROGNAME);
  uart16550_puts(": file received\n");

  return file_size;   
}