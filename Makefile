all:$(INSTALL_PATH)/lib/libjpeg.a 


$(INSTALL_PATH)/lib/libjpeg.a:
	cd jpeg-9; ./configure CC=$(SDK_CC) CFLAGS="-isysroot $(SDK_PATH)" --host=$(HOST) --disable-shared --enable-static --prefix=$(INSTALL_PATH)
	make -C jpeg-9
	make -C jpeg-9 install

clean:
	make -C jpeg-9 clean
	rm $(INSTALL_PATH)/lib/libjpeg.a
