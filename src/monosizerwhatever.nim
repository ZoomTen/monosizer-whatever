import ./datatype/vst
import ./debug

proc dispatch(
    effect: AEffect,
    opcode: DispatcherCallbackKind,
    index: cint,
    value: cint,
    ptrTarget: pointer,
    opt: cfloat,
): cint {.cdecl.} =
  result = 0
  debugMessage(
    "Dispatch called with " & opcode.repr & " index " & $index & " value " & $value &
      " ptr " & ptrTarget.repr & " opt " & $opt
  )
  case opcode
  of GetVendorVersion:
    result = 1000
  of GetEffectName:
    let name = "Monosizer Whatever".cstring
    # +1 to include the terminating \x00 ??
    ptrTarget.copyMem(name[0].addr, name.len + 1)
    result = 1
  of GetProductString:
    let product = "VST Nim Test".cstring
    ptrTarget.copyMem(product[0].addr, product.len + 1)
    result = 1
  of GetVendorString:
    let vendor = "Zumi".cstring
    ptrTarget.copyMem(vendor[0].addr, vendor.len + 1)
    result = 1
  of GetPlugCategory:
    result = Effect.ord
  of GetVstVersion:
    result = 2400
  of CanDo:
    let canDoStr = $(cast[cstring](ptrTarget))
    debugMessage("Query: " & canDoStr)
    result = (
      case canDoStr
      of "receiveVstEvents": No
      else: No
    ).ord
  of Close:
    discard
  else:
    discard
  debugMessage("Result: " & $result)
  return result

proc process(
    effect: AEffect,
    inputs: UncheckedArray[ptr cfloat],
    outputs: UncheckedArray[ptr cfloat],
    sampleFrames: clong,
): void {.cdecl.} =
  var
    inL = inputs[0]
    inR = inputs[1]
    outL = outputs[0]
    outR = outputs[1]
  for i in 0 ..< sampleFrames:
    # For some reason, using UncheckedArray[UncheckedArray[ptr cfloat]] for `inputs`
    # and `outputs` and then using `let whichInL = inL[i]` makes the thing crash, and
    # I'm not sure why.
    let
      whichInL = cast[ptr cfloat](cast[int](inL) + (i * sizeof(pointer)))
      whichInR = cast[ptr cfloat](cast[int](inR) + (i * sizeof(pointer)))
      whichOutL = cast[ptr cfloat](cast[int](outL) + (i * sizeof(pointer)))
      whichOutR = cast[ptr cfloat](cast[int](outR) + (i * sizeof(pointer)))
      singleVolume =
        if abs(whichInR[]) <= 0.001:
          # Could use == 0, but then there's a weird audio glitch sometimes
          whichInL[]
        else:
          whichInR[]
    whichOutL[] = singleVolume
    whichOutR[] = singleVolume

when not defined(clang):
  proc NimMain() {.importc, cdecl.}

proc VSTPluginMain(
    master: ptr AudioMasterCallback
): ptr AEffect {.exportc, dynlib, cdecl.} =
  when not defined(clang):
    NimMain()
  result = newAeffect()
  result.dispatcher = dispatch
  result.processReplacing = process
  result.flags = {CanReplacing}
  result.nParams = 0
  result.nInputs = 2
  result.nOutputs = 2
  result.version = 1
  result.uniqueId = 0x6d6d6d6d # TODO this is a 4CC
  return result
