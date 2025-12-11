namespace Sunaba.Engine.Config;

public class DataBoolean(bool b): IData
{
    public bool ToBool()
    {
        return b;
    }
}