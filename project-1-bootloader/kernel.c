#define PORT 0xbfe48000
#define test 0x8007b980


void __attribute__((section(".entry_function"))) _start(void)
{
	char s[] = "Hello_OS!\n";
	int (*print)(char*);
        print = (void*)(char*)0x8007b980;

	print(s);
//	while(1){};	// Call PMON BIOS printstr to print message "Hello OS!"
	return;
}

