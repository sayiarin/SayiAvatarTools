struct EmptyData
{
};
EmptyData VertexFunction(EmptyData meshData)
{
    return meshData;
}
void FragmentFunction(EmptyData empty)
{
    discard;
}