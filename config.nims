switch("define", "nomain")
switch("define", "release")
switch("define", "lto")
switch("define", "useMalloc")
switch("os", "windows")
switch("cpu", "i386")
switch("app", "lib")
switch("threads", "off")

when false:
  switch("cc", "clang")
  switch("passC", "-target i686-w64-mingw32")
  switch("passL", "-target i686-w64-mingw32")
  switch("clang.options.linker", "-static-libgcc")
else:
  switch("cc", "gcc")
  switch("gcc.exe", "i686-w64-mingw32-gcc")
  switch("gcc.linkerexe", "i686-w64-mingw32-gcc")
  switch("gcc.options.linker", "-static-libgcc")
