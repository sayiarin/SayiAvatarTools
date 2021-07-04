// very weird toic and somewhat difficult to understand, these two resourced helped me
// understand it a bit more though and arrived at this solution
// https://gpfault.net/posts/perlin-noise.txt.html
// http://www.sci.utah.edu/~leenak/IndStudy_reportfall/PNoiseCode.txt
// and interestingly enough this webpage in chinese (I think) helped a lot too, google translate works wonders
// https://blog.csdn.net/candycat1992/article/details/50346469

// https://stackoverflow.com/questions/12964279/whats-the-origin-of-this-glsl-rand-one-liner
float2 PseudoRandom(float2 value)
{
    return frac(sin(dot(value, float2(12.9898, 78.233))) * 43758.5453);
}

float2 Fade(float2 value)
{
    return value * value * value * (value * (value * 6.0 - 15.0) + 10.0);
}

float PerlinNoise(float2 value)
{
    float2 pointFloor = floor(value);
    float2 pointFrac = frac(value);

    float2 fade = Fade(pointFrac);

    return lerp(lerp(dot(PseudoRandom(pointFloor + float2(0.0, 0.0)), pointFrac - float2(0.0, 0.0)),
                    dot(PseudoRandom(pointFloor + float2(1.0, 0.0)), pointFrac - float2(1, 0.0)), fade.x),
                lerp(dot(PseudoRandom(pointFloor + float2(0.0, 1.0)), pointFrac - float2(0.0, 1.0)),
                    dot(PseudoRandom(pointFloor + float2(1.0, 1.0)), pointFrac - float2(1.0, 1.0)), fade.x), fade.y);
}

float GeneratePerlinNoise(uint3 id, int scale)
{
    float2 pt = float2(id.xy / scale);
    float2x2 m = float2x2(1.6, 1.2, -1.2, 1.6);

    float result = 0;
    pt *= 8;
    result += PerlinNoise(pt);
    pt = mul(m, pt);
    result += 0.5 * PerlinNoise(pt);
    pt = mul(m, pt);
    result += 0.25 * PerlinNoise(pt);
    pt = mul(m, pt);
    result += 0.125 * PerlinNoise(pt);
    pt = mul(m, pt);
    result += 0.0625 * PerlinNoise(pt);

    result = result * 0.5 + 0.5;

    return result;
}

float2 hash22(float2 p)
{
    p = float2(dot(p, float2(127.1, 311.7)), dot(p, float2(269.5, 183.3)));
    return -1.0 + 2.0 * frac(sin(p) * 43758.5453123);
}
			
float2 hash21(float2 p)
{
    float h = dot(p, float2(127.1, 311.7));
    return -1.0 + 2.0 * frac(sin(h) * 43758.5453123);
}

float Perlin(float2 p)
{
    float2 pi = floor(p);
    float2 pf = frac(p);
    
    //float2 w = pf * pf * (3.0 - 2.0 * pf);
    float2 w = pf * pf * pf * (6 * pf * pf - 15 * pf + 10);
     
    return lerp(lerp(dot(hash22(pi + float2(0.0, 0.0)), pf - float2(0.0, 0.0)),
                    dot(hash22(pi + float2(1.0, 0.0)), pf - float2(1, 0.0)), w.x),
                lerp(dot(hash22(pi + float2(0.0, 1.0)), pf - float2(0.0, 1.0)),
                    dot(hash22(pi + float2(1.0, 1.0)), pf - float2(1.0, 1.0)), w.x), w.y);
}

float PerlinSum(float2 p)
{
    float f = 0;
    p = p * 8;
    float2x2 m = float2x2(1.6, 1.2, -1.2, 1.6);

    int State = 0;
    
    f += 1.0 * (State > 0 ? abs(Perlin(p)) : Perlin(p));
    p = mul(m, p);
    f += 0.5 * (State > 0 ? abs(Perlin(p)) : Perlin(p));
    p = mul(m, p);
    f += 0.25 * (State > 0 ? abs(Perlin(p)) : Perlin(p));
    p = mul(m, p);
    f += 0.125 * (State > 0 ? abs(Perlin(p)) : Perlin(p));
    p = mul(m, p);
    f += 0.0625 * (State > 0 ? abs(Perlin(p)) : Perlin(p));
    
    p = mul(m, p);
    if (State > 1)
        f = sin(f + p.x / 32.0);
    return f;
}