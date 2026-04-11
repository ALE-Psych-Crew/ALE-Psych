package core.enums;

enum abstract PlotFormatType(cpp.UInt8) from cpp.UInt8 to cpp.UInt8
{
    var Number = 0;
    var Memory = 1;
    var Percentage = 2;
}