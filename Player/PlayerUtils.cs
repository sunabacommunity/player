using System;
using System.Reflection;
using Godot;

namespace Sunaba.Player;

public partial class PlayerUtils: Node
{
    public string GetAssemblyDirectory()
    {
        var asmLoc = AppDomain.CurrentDomain.BaseDirectory;
        var asmDir = asmLoc;
        if (asmDir.EndsWith(".dll"))
            asmDir = asmDir.GetBaseDir();
        return asmDir;
    }
}