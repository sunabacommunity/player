using Godot;

namespace Sunaba.Engine;

public partial class HxDnsAddrInfo: RefCounted
{
    public string Ip;
    public string Addr;
    public int Port;
    public string Family;
    public string Socktype;
}