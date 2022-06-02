mkdir -p ../data/outputs/meteolakes_geneva
cp ../data/static/meteolakes_geneva/* ../data/outputs/meteolakes_geneva
cp ../data/inputs/testing/meteolakes_geneva/* ../data/outputs/meteolakes_geneva
cp config_flow2d3d.ini ../data/outputs/meteolakes_geneva
cp config_flow2d3d.xml ../data/outputs/meteolakes_geneva
cd ../data/outputs/meteolakes_geneva
docker run -v $(pwd):/job jamesrunnalls/eawag-delft3d:latest