CC=nvcc
CFLAGS=-c
LDFLAGS=-lpthread -lcrypto
EXECUTABLE=generator

all: generator

generator: main.o
	$(CC) $(LDFLAGS) $^ -o $(EXECUTABLE)

main.o: main.cu
	$(CC) $(CFLAGS) $^

md5.o: md5.c md5.h
	$(CC) $(CFLAGS) md5.c

table_row.o: table_row.c table_row.h
	$(CC) $(CFLAGS) table_row.c
