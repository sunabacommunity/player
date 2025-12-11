namespace Sunaba.Engine.Config;

public class DataInteger(int i) : IData
{
    public int ToInt()
    {
        return i;
    }
}