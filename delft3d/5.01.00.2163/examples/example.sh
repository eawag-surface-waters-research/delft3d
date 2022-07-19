cd "${0%/*}"
cd ..
mkdir -p examples/outputs/geneva_1.0.0
cp static/geneva_1.0.0/* examples/outputs/geneva_1.0.0
cp examples/inputs/geneva_1.0.0/* examples/outputs/geneva_1.0.0
cp config_flow2d3d.ini examples/outputs/geneva_1.0.0
cp config_flow2d3d.xml examples/outputs/geneva_1.0.0
cd examples/outputs/geneva_1.0.0
docker run -v $(pwd):/job jamesrunnalls/eawag-delft3d:latest