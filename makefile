CC=nvcc
CFLAGS=-c
LDFLAGS=-lpthread -lcrypto
EXECUTABLE=generator

all: generator

generator: main.o md5.o table_row.o reduction_function.o
	$(CC) $(LDFLAGS) $^ -o $(EXECUTABLE)

main.o: main.cu table_row.h md5.h reduction_function.h
	$(CC) $(CFLAGS) main.cu -o $@

md5.o: md5.cu md5.h
	$(CC) $(CFLAGS) md5.cu -o $@

table_row.o: table_row.cu table_row.h
	$(CC) $(CFLAGS) table_row.cu -o $@

reduction_function.o: reduction_function.cu reduction_function.h
	$(CC) $(CFLAGS) reduction_function.cu -o $@ 

clean:
	rm -f *.o generator 
