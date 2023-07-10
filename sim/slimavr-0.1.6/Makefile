SRC             = src
OBJ             = obj
DEFS            = -DDEBUG=0 # debug level
CFLAGS          = -O2 -finline-functions -finline -flto -Wall -Wextra

src_models      = $(wildcard $(SRC)/models/*.c)
src_models_o    = $(patsubst $(SRC)/%.c, $(OBJ)/%.o, $(src_models))
src             = $(wildcard $(SRC)/*.c)
src_o           = $(patsubst $(SRC)/%.c, $(OBJ)/%.o, $(src))

all: objdirs libslimavr.a

objdirs:
	mkdir -p $(OBJ)/models

libslimavr.a: $(src_models_o) $(src_o)
	$(AR) rcs $@ $^

$(OBJ)/models/%.o: $(SRC)/models/%.c
	$(CC) $(DEFS) $(CFLAGS) $^ -c -o $@

$(OBJ)/%.o: $(SRC)/%.c
	$(CC) $(DEFS) $(CFLAGS) $^ -c -o $@

clean:
	rm -f $(src_models_o) $(src_o)
