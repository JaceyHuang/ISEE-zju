TOOL_CHAIN = /opt/riscv/bin
CROSS_COMPILE = $(TOOL_CHAIN)/riscv32-unknown-linux-gnu-gcc

mytest: mytest.c
    $(CROSS_COMPILE) -static -O3 -o $@ $<
clean:
    rm -f mytest
