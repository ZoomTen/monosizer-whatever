type
  AEffect* {.byref.} = object
    magic: cint
    dispatcher*: DispatcherProc
    process*: ProcessProc
    setParam*: SetParameterProc
    getParam*: GetParameterProc
    nPrograms*: cint
    nParams*: cuint
    nInputs*: cint
    nOutputs*: cint
    flags*: EffectFlags
    hostReserved1*: pointer
    hostReserved2*: pointer
    delay*: cint
    realQualities*: cint
    offQualities: cint
    ioRatio*: cfloat
    vstObject: pointer
    vstUser*: pointer
    uniqueId*: cint
    version*: cint
    processReplacing*: ProcessProc
    processDoubleReplacing*: ProcessDoubleProc

  DispatcherCallbackKind* {.size: sizeof(int32).} = enum
    Open = 0
    Close
    SetProgram
    GetProgram
    SetProgramName
    GetProgramName
    GetParamLabel
    GetParamDisplay
    GetParamName
    GetVu
    SetSampleRate
    SetBlockSize
    MainsChanged
    EditGetRect
    EditOpen
    EditClose
    EditDraw
    EditMouse
    EditKey
    EditIdle
    EditTop
    EditSleep
    Identify
    GetChunk
    SetChunk
    ProcessEvents
    CanBeAutomated
    StringToParameter
    GetNumProgramCategories
    GetProgramNameIndexed
    CopyProgram
    ConnectInput
    ConnectOutput
    GetInputProperties
    GetOutputProperties
    GetPlugCategory
    GetCurrentPosition
    GetDestinationBuffer
    OfflineNotify
    OfflinePrepare
    OfflineRun
    ProcessVarIo
    SetSpeakerArrangement
    SetBlockSizeAndSampleRate
    SetBypass
    GetEffectName
    GetErrorText
    GetVendorString
    GetProductString
    GetVendorVersion
    VendorSpecific
    CanDo
    GetTailSize
    Idle
    GetIcon
    SetViewPosition
    GetParameterProperties
    KeysRequired
    GetVstVersion
    EditKeyDown
    EditKeyUp
    SetEditKnobMode
    GetMidiProgramName
    GetCurrentMidiProgram
    GetMidiProgramCategory
    HasMidiProgramsChanged
    GetMidiKeyName
    BeginSetProgram
    EndSetProgram
    GetSpeakerArrangement
    ShellGetNextPlugin
    StartProcess
    StopProcess
    SetTotalSampleToProcess
    SetPanLaw
    BeginLoadBank
    BeginLoadProgram
    SetProcessPrecision
    GetNumMidiInputChannels
    GetNumMidiOutputChannels

  MasterCallbackKind* {.size: sizeof(int32).} = enum
    Automate = 0
    Version
    CurrentId
    Idle
    PinConnected
    WantMidi
    GetTime
    ProcessEvents
    SetTime
    TempoAt
    GetNumAutomatableParameters
    GetParameterQuantization
    IoChanged
    NeedIdle
    SizeWindow
    GetSampleRate
    GetBlockSize
    GetInputLatency
    GetOutputLatency
    GetPrevPlug
    GetNextPlug
    WillReplaceOrAccumulate
    GetCurrentProcessLevel
    GetAutomationState
    OfflineStart
    OfflineRead
    OfflineWrite
    OfflineGetCurPass
    OfflineGetCurMetaPass
    SetOutputSampleRate
    GetOutputSpeakerArrangement
    GetVendorString
    GetProductString
    GetVendorVersion
    VendorSpecific
    SetIcon
    CanDo
    GetLanguage
    OpenWindow
    CloseWindow
    GetDirectory
    UpdateDisplay
    BeginEdit
    EndEdit
    OpenFileSelector
    CloseFileSelector
    EditFile
    GetChunkFile
    GetInputSpeakerArrangement

  EffectFlag* {.size: sizeof(int32).} = enum
    HasEditor = 0
    HasClip
    HasVu
    CanMono
    CanReplacing
    ProgramChunks
    IsSynth
    NoSoundInStop
    ExtIsAsync
    ExtHasBuffer
    CanDoubleReplacing

  EffectFlags = set[EffectFlag]

  AudioMasterCallback* = proc(
    effect: AEffect,
    opcode: MasterCallbackKind,
    index: cint,
    value: cint,
    what: pointer,
    opt: cfloat,
  ): cint {.cdecl.}

  DispatcherProc* = proc(
    effect: AEffect,
    opcode: DispatcherCallbackKind,
    index: cint,
    value: cint,
    what: pointer,
    opt: cfloat,
  ): cint {.cdecl.}

  ProcessProc* = proc(
    effect: AEffect,
    inputs: UncheckedArray[ptr cfloat],
    outputs: UncheckedArray[ptr cfloat],
    sampleFrames: clong,
  ): void {.cdecl.}

  ProcessDoubleProc* = proc(
    effect: AEffect,
    inputs: UncheckedArray[ptr cdouble],
    outputs: UncheckedArray[ptr cdouble],
    sampleFrames: clong,
  ): void {.cdecl.}

  SetParameterProc* = proc(effect: AEffect, index: cint, param: cfloat): void {.cdecl.}

  GetParameterProc* = proc(effect: AEffect, index: cint): float {.cdecl.}

  PluginKind* {.size: sizeof(int32).} = enum
    Unknown = 0
    Effect
    Synth
    Analysis
    Mastering
    Spacializer
    RoomFx
    SurroundFx
    Restoration
    OfflineProcess
    Shell
    Generator

  CanDoResponses* = enum
    No = -1
    Maybe = 0
    Yes = 1

proc newAeffect*(): ptr AEffect =
  # The assumption here is that the caller is the one freeing the struct
  result = cast[ptr AEffect](alloc0Impl(sizeof(AEffect)))
  result.magic = 0x56737450 # "VstP"
