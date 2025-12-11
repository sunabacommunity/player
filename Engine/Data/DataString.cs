namespace Sunaba.Engine.Config;

public class DataString(string s) : IData
{
    public override string ToString()
    {
        return s;
    }
}