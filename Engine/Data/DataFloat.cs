namespace Sunaba.Engine.Config;

public class DataFloat(float f): IData
{
    public DataFloat(double d) : this((float)d)
    {
    }

    public float ToFloat32()
    {
        return f;
    }

    public double ToFloat64()
    {
        return (double)f;
    }
}