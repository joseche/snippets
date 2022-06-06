CC=g++
CFLAGS=-c -Wall
LDFLAGS=-lm -la
SOURCES=main.cpp library1.cpp library2.cpp library3.cpp
OBJECTS=$(SOURCES:.cpp=.o)
EXECUTABLE=main
 
all: $(SOURCES) $(EXECUTABLE)
 
$(EXECUTABLE): $(OBJECTS) 
	$(CC) $(LDFLAGS) $(OBJECTS) -o $@
 
.cpp.o:
	$(CC) $(CFLAGS) $< -o $@
 
clean:
	rm -rf *.o $(EXECUTABLE)
