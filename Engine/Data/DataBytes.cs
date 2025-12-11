namespace Sunaba.Engine.Config;

public class DataBytes(byte[] bytes) : IData
{
    public byte[] ToBytes()
    {
        return bytes;
    }
}