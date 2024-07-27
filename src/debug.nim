import winim

when not defined(release) and not defined(danger):
  var textFile = open("plugindebug.log", fmAppend)

template debugMessage*(msg: string) =
  when not defined(release) and not defined(danger):
    textFile.writeLine(msg & "\r")
