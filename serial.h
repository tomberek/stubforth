#ifdef __cplusplus
extern "C" {
#endif
extern void setup();
extern void loop();
extern void serial_begin(unsigned long);
extern char serial_read();
extern int serial_write(char);
extern int serial_println(char*);
extern int serial_write_long(long);
static char readline_buffer[80];
static int readline_buffer_ind;
#ifdef __cplusplus
}
#endif
