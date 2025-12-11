using Godot;

namespace Sunaba.Engine.Config;

public class DataColor : IData
{
    private string _html;

    public DataColor(Color color)
    {
        _html = color.ToHtml();
    }

    public Color ToColor()
    {
        return Color.FromHtml(_html);
    }

    public override string ToString()
    {
        return _html;
    }
}